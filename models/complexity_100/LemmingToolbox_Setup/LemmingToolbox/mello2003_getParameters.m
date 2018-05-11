function p = mello2003_getParameters(attachedCheSpecies)
% Returns the nominal parameter structure of the model of chemotaxis in E-Coli.
% Based on Mello et al. (2003). "Perfect and Near-Perfect Adaptation in a
% Model of Bacterial Chemotaxis", Biophysical Journal Vol. 84 2943-2956

% Copyright 2010 George Rosenberger
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

%% Relative activities
p.P_0v = 0; % [-]
p.P_1v = 0.125; % [-]
p.P_2v = 0.5; % [-]
p.P_3v = 0.874; % [-]
p.P_4v = 1; % [-]

p.P_0o = 0; % [-]
p.P_1o = 0.017; % [-]
p.P_2o = 0.125; % [-]
p.P_3o = 0.5; % [-]
p.P_4o = 1; % [-]

%% Constants
p.KR = 0.364e-6; % [M]
p.KB = 1.405e-6; % [M]
p.kR = 0.819; % [s^-1]
p.kB = 0.155; % [s^-1]

%% Reaction rate constants
p.kP = 15.5; % [s^-1]
p.kPY = 5e+6; % [M^-1*s^-1]
p.kPB = 5e+6; % [M^-1*s^-1]
% Since CheZ is not part of the Mello model, we assumed the same
% concentration of CheZ as in the Spiro model (40 mu M) and adjusted the respective
% reaction.
p.kHY = 14.15/40e-6; % [M^-1*s^-1]
p.kHB = 0.35; % [s^-1]

%% Dissociation rate between the receptors and the ligand.
% This dissociation rate is obtained by assuming the quasi steady state
% assumptions for the respective reactions in the Spiro model, since this
% reaction is not part of the Mello model.
p.KDAsp =  70 / 7e7; % [M]
%% Artificial reaction rates to transform the algebraic differential
%% equation system into an ODE (for eq. 7-9)
p.CorrectionRF = -500; % [s^-1]
p.CorrectionTF = -500; % [s^-1]

%% Total concentrations of species
p.T_tot = 2.5; % [mu M], total receptor.
p.R_tot = 0.176; % [mu M], total CheR.
p.B_tot = 2.27; % [mu M], total CheB.
p.Y_tot = 18; % [mu M], total CheY.
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