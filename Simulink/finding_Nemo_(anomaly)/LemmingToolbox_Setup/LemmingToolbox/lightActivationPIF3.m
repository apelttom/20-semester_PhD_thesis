function [dx, dCheProtein] = lightActivationPIF3(t, x, cheProteins, p, redLightFct, farRedLightFct)
% Model for the light activation, when the Che protein is fused to PIF3.
% The rows in cheProteins represent the different Che species which are
% fused to PIF3. The model accept any amount of species and does not take
% care which proteins and possibly phosphorylation states they represent,
% since the binding and unbinding to PhyB is the same for all these
% proteins.
% The columns in cheProteins represent the following:
%    1st column: The CheX-PIF3 mutatant is not bound to PhyB.
%    2nd column: The CheX-PIF3 mutant is bound to PhyB, however it is still
%                free since PhyB is not bound to the DNA.
%    3rd column: The CheX-PIF3 species is bound to PhyB which is bound to
%                the DNA. Thus, the Che protein is localized.
%
% Inputs:
% t ... time
% x ... state vector
% cheProtein ... Amount of Che proteins in muM in the three different
%                states (see above).
% p ... parameter structure.
% redLightFct(t) ... A function  giving as return value a value in between zweo
%                    and one, where one is red light fully on and zero red light fully off.
% farRedLightFct ... Same as redLightFct, only for far red light.


% Copyright 2010 Moritz Lang
% This file is part of the E. lemming Matlab / Simulink Toolbox and was
% developed for the iGEM 2010 project of ETH Zurich. For further information, please
% visit http://2010.igem.org/Team:ETHZ_Basel
% 
% The Lemming Toolbox is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% The Lemming Toolbox is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with the Lemming Toolbox.  If not, see
% <http://www.gnu.org/licenses/>.

%% Return initial conditions if requested
if nargin == 1
    p = t;
    dx = [p.AnkerProt_tot, 0, 0, 0, p.Anker_tot];
    dCheProtein = zeros(0, 3);
    return;
end

%% States
% PhyB in Pr form neither bound to PIF3 nor to the anker
Pr_free = x(1);
% PhyB in Pfr form neither bound to PIF3 nor to the anker
Pfr_free = x(2);
% PhyB in Pr form not bound to PIF3, but to the anker
Pr_bound = x(3);
% PhyB in Pfr form not bound to PIF3, but to the anker
Pfr_bound = x(4);
% Amount of ankers (e.g. Operons) in muM not bound to PhyB
Anker_free = x(5);

% Free PIF3
PIF3_free = cheProteins(:, 1);
% PhyB in Pfr form bound to PIF3, but not to the anker
Pfr_PIF3_free = cheProteins(:, 2);
% PhyB in Pfr form bound to PIF3 and to the anker
Pfr_PIF3_bound = cheProteins(:, 3);

%% Light inputs
% Red light
if isa(redLightFct, 'function_handle')
    RL = redLightFct(t);
else
    RL = redLightFct;
end
% Far-red light
if isa(farRedLightFct, 'function_handle')
    FRL = farRedLightFct(t);
else
    FRL = farRedLightFct;
end

%% Parameters
k_act_RL=6.64046; % [1/s] Calculated with LED, Filter and cross-section data.
k_inact_RL=1.01624; % [1/s] 
k_act_FRL=0.101506;  % [1/s]
k_inact_FRL=5.67745; % [1/s]
intensity_RL = 1; % [-] Only used to not change the formulas when switching between Sorokina and this data.
intensity_FRL = 1; % [-] Only used to not change the formulas when switching between Sorokina and this data.

% Dissociation constant TetA/Operator, from Kamionka 2003.
K_anker = 0.00018;    % [mu M];
kB_anker = 0.5; % [1/ muM / s] Value chosen so that timescale is approximately the same as in other reactions since value unknown.
kUB_anker = K_anker * kB_anker;

% Dissociation constant PhyB/PIF3
K_PhyBPIF = 500 / 1000; % [mu M] from (Levskaya 2009)
kB_PhyBPIF = 0.5; % 1/mu M/s. 
kUB_PhyBPIF = K_PhyBPIF * kB_PhyBPIF;

%% Derived variables
% Reaction rate constant from Pr -> Pfr
k_act = k_act_RL * intensity_RL * RL + k_act_FRL * intensity_FRL * FRL;
% Reaction rate constant from Pfr -> Pr
k_inact = k_inact_RL * intensity_RL * RL + k_inact_FRL * intensity_FRL * FRL;

%% Reactions
% Behind each reaction there is the number of educts and products in
% brackets to simplify debugging.

% All light activations
Pr2Pfr_free = k_act * Pr_free; % (1E, 1P)
Pr2Pfr_bound = k_act * Pr_bound; % (1E, 1P)

% All light inactivations
Pfr2Pr_free = k_inact * Pfr_free; % (1E, 1P)
Pfr2Pr_bound = k_inact * Pfr_bound; % (1E, 1P)
Pfr2Pr_PIF3_free = k_inact * Pfr_PIF3_free; % (1E, 2P)
Pfr2Pr_PIF3_bound = k_inact * Pfr_PIF3_bound; % (1E, 2P)

% Binding to anker
unbound2bound_Pr = kB_anker * Anker_free * Pr_free; % (2E, 1P)
unbound2bound_Pfr = kB_anker * Anker_free * Pfr_free; % (2E, 1P)
unbound2bound_Pfr_PIF3 = kB_anker * Anker_free * Pfr_PIF3_free; % (2E, 1P)

% Unbinding anker/PhyB
bound2unbound_Pr = kUB_anker * Pr_bound; % (1E, 2P)
bound2unbound_Pfr = kUB_anker * Pfr_bound; % (1E, 2P)
bound2unbound_Pfr_PIF3 = kUB_anker * Pfr_PIF3_bound; % (1E, 2P)

% Binding PhyB to Che/PIF3
PhyBPIFBinding_free = kB_PhyBPIF * Pfr_free * PIF3_free; % (2E, 1P)
PhyBPIFBinding_bound = kB_PhyBPIF * Pfr_bound * PIF3_free; % (2E, 1P)

% Unbinding PhyB PIF3 complex
PhyBPIFUnbinding_free = kUB_PhyBPIF * Pfr_PIF3_free; % (1E, 2P)
PhyBPIFUnbinding_bound = kUB_PhyBPIF * Pfr_PIF3_bound; % (1E, 2P)

%% Differential equations
% PhyB in Pr form neither bound to PIF3 nor to the anker
dPr_free = - Pr2Pfr_free + Pfr2Pr_free + sum(Pfr2Pr_PIF3_free) - unbound2bound_Pr + bound2unbound_Pr;
% PhyB in Pfr form neither bound to PIF3 nor to the anker
dPfr_free = + Pr2Pfr_free - Pfr2Pr_free - unbound2bound_Pfr + bound2unbound_Pfr - sum(PhyBPIFBinding_free) + sum(PhyBPIFUnbinding_free);
% PhyB in Pr form not bound to PIF3, but to the anker
dPr_bound = - Pr2Pfr_bound + Pfr2Pr_bound + sum(Pfr2Pr_PIF3_bound) + unbound2bound_Pr - bound2unbound_Pr;
% PhyB in Pfr form not bound to PIF3, but to the anker
dPfr_bound = + Pr2Pfr_bound - Pfr2Pr_bound + unbound2bound_Pfr - bound2unbound_Pfr - sum(PhyBPIFBinding_bound) + sum(PhyBPIFUnbinding_bound);
% Amount of ankers (e.g. Operons) in muM not bound to PhyB
dAnker_free = - unbound2bound_Pr - unbound2bound_Pfr - sum(unbound2bound_Pfr_PIF3) + bound2unbound_Pr + bound2unbound_Pfr + sum(bound2unbound_Pfr_PIF3);

dx = [dPr_free, dPfr_free, dPr_bound, dPfr_bound, dAnker_free];


% PhyB in Pfr form bound to PIF3, but not to the anker
dPfr_PIF3_free = - Pfr2Pr_PIF3_free - unbound2bound_Pfr_PIF3 + bound2unbound_Pfr_PIF3 + PhyBPIFBinding_free - PhyBPIFUnbinding_free;
% PhyB in Pfr form bound to PIF3 and to the anker
dPfr_PIF3_bound = - Pfr2Pr_PIF3_bound + unbound2bound_Pfr_PIF3 - bound2unbound_Pfr_PIF3 + PhyBPIFBinding_bound - PhyBPIFUnbinding_bound;
% Free PIF3
dPIF3_free = + Pfr2Pr_PIF3_free + Pfr2Pr_PIF3_bound - PhyBPIFBinding_free - PhyBPIFBinding_bound + PhyBPIFUnbinding_free + PhyBPIFUnbinding_bound;

dCheProtein = [dPIF3_free, dPfr_PIF3_free, dPfr_PIF3_bound];
