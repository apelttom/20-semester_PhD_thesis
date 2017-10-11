function p = spiro1997_getParameters(attachedCheSpecies)
% Returns the nominal parameter structure of the model of chemotaxis in E-Coli.
% Based on Spiro et al. (1997). "A model of excitation and adaptation in
% bacterial chemotaxis", PNAS Vol. 94.


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

%% We store all parameter values in the structure p.
p = {};

%% Model parameters
% For the respective description, see Spiro (1997).
p.k1c = 0.17; % [s^-1]
p.k2c = 0.1 * p.k1c; % [s^-1]
p.k3c = 30 * p.k1c; % [s^-1]
p.k4c = 30 * p.k2c; % [s^-1]

p.KR = 1.7e-6; %[M], denoted as k1b/k1a, ..., k4b/k4a in paper.

p.k_1 = 4e5; % [M^-1 * s^-1]
p.k_2 = 3e4;  % [M^-1 * s^-1]
p.k_3 = p.k_1; % [M^-1 * s^-1]
p.k_4 = p.k_2;  % [M^-1 * s^-1]

p.k5 = 7e7; % [M^-1 * s^-1]
p.k6 = p.k5; % [M^-1 * s^-1]
p.k7 = p.k5; % [M^-1 * s^-1]
p.k_5 = 70; % [s^-1]
p.k_6 = p.k_5; % [s^-1]
p.k_7 = p.k_5; % [s^-1]

p.k8 = 15; % [s^-1]
p.k9 = 3 * p.k8;
p.k10= 3.2 * p.k8;
p.k11= 0;
p.k12= 1.1 * p.k8;
% This variable is changed from original paper to fit the data
p.k13= 1.3 * p.k8;%0.72 * p.k10;

p.kb = 8e5; % [M^-1 * s^-1]
p.ky = 3e7; % [M^-1 * s^-1]
p.k_b = 0.35; % [s^-1]
p.k_y = 5e5; % [M^-1 * s^-1]

%% Total concentrations of species
p.T_tot = 8; % [mu M], total receptor.
p.R_tot = 0.3; % [mu M], total CheR.
p.B_tot = 1.7; % [mu M], total CheB.
p.Y_tot = 20; % [mu M], total CheY.
p.Z_tot = 40; % [mu M], total CheZ.

if nargin == 0
    p.AnkerProt_tot = 100; %[mu M], total concentration of anker protein (e.g. Tet-PhyB, when the Che protein is bound to PIF3, otherwise Tet-PIF3).
else
    switch attachedCheSpecies
        case 'CheR'
            p.AnkerProt_tot = 10;
        case 'CheB'
            p.AnkerProt_tot = 10;
        case 'CheY'
            p.AnkerProt_tot = 50;
        case 'CheZ'
            p.AnkerProt_tot = 60;
        otherwise
            error('ETH:NotSupportedSpecies', 'Species not supported/implemented.');
    end
end
p.Anker_tot = 1.3 * p.AnkerProt_tot; %[mu M], total amount of binding sides (e.g. Operons)