function [xp, pCheProteins] = spiro1997(t, x, cheProteins, p, aspFunc)
% Model of chemotaxis in E-Coli.
% Based on Spiro et al. (1997). "A model of excitation and adaptation in
% bacterial chemotaxis", PNAS Vol. 94.
% Changed to accept different activation levels of one or more Che protein.
% In general the last column represent the amount of localized proteins,
% whereas the other columns represent the amount of free proteins, where
% only the state of the PhyB or the PIF3 protein changed. Thus, all but the
% last column have to be treated normally, whereas for the last column only
% the reactions occur which take place although the protein is localized
% (e.g. CheB can be dephosphorylated, but not phosphorylated when
% localized).
%
% Usage
% --------
% [x0, cheProteins0] = model(p)
%                    ... Return valid initial conditions.
% [xp, pCheProteins] = spiro1997(t, x, cheProteins, p, aspFunc)
%                    ... Used for simulations.
%
% Parameters:
% -----------------------
% t ... current time in integration.
% x ... current state.
% cheProteins ... The rows represent the different Che
%                 species (but possibly two species represent the same protein in the
%                 phosphorylated and unphosphorylated state), columns represent the
%                 different activation levels. The number and meaning of the columns change
%                 depending on which light model is chosen. For a documentation please
%                 refer to the respective light model.
% p ... parameter structure.
% aspFunc(t) ... Function returning the asp concentration at time t (in M).


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

%% Return valid initial conditions if requested
if nargin == 1
    p = t;
    xp = [p.T_tot; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0];
    pCheProteins = [p.R_tot; p.B_tot/2; p.B_tot/2; p.Y_tot/2; p.Y_tot/2; p.Z_tot];
    return;
end

%% Rescale mu M -> M
x = x * 10^-6;
cheProteins = cheProteins * 10^-6;

%% get current Aspartate concentration
if isa(aspFunc, 'function_handle')
    L = aspFunc(t);
else
    L = aspFunc;
end

%% get current Species concentrations
% Receptor complex, not ligand bound, 2-4 fold methylated, not physphorylated
T2 = x(1);
T3 = x(2);
T4 = x(3);

% Receptor complex, not ligand bound, 2-4 fold methylated, physphorylated
T2p = x(4);
T3p = x(5);
T4p = x(6);

% Receptor complex, ligand bound, 2-4 fold methylated, not
% physphorylated
LT2 = x(7);
LT3 = x(8);
LT4 = x(9);

% Receptor complex, ligand bound, 2-4 fold methylated, physphorylated
LT2p = x(10);
LT3p = x(11);
LT4p = x(12);

% CheR
R_all = cheProteins(1, :);
R_active = sum(R_all(1:end-1));

% CheB, unphosphorylated and phosphorylated
B_all  = cheProteins(2, :);
B_active = sum(B_all(1:end-1));
Bp_all = cheProteins(3, :);
Bp_active = sum(Bp_all(1:end-1));

% CheY, unphosphorylated and phosphorylated
Y_all  = cheProteins(4, :);
Y_active = sum(Y_all(1:end-1));
Yp_all = cheProteins(5, :);
Yp_active = sum(Yp_all(1:end-1)); %#ok<NASGU>

% CheZ
Z_all = cheProteins(6, :);
Z_active = sum(Z_all(1:end-1));

%% Reactions
% The comment behind the reaction states the number of the reaction in the
% figure in the Spiro paper. More than one elementary reaction may
% correspond to the respective reaction in the Spiro paper (e.g. forward
% and backward reachtions).

% Methylations of the receptor.
T2_to_T3 = p.k1c * R_active * T2 / (p.KR + T2); % R1
T3_to_T4 = p.k2c * R_active * T3 / (p.KR + T3);% R2
LT2_to_LT3 = p.k3c * R_active * LT2 / (p.KR + LT2);% R3
LT3_to_LT4 = p.k4c * R_active * LT3 / (p.KR + LT3);% R4

T2p_to_T3p = p.k1c * R_active * T2p / (p.KR + T2p); % R1
T3p_to_T4p = p.k2c * R_active * T3p / (p.KR + T3p);% R2
LT2p_to_LT3p = p.k3c * R_active * LT2p / (p.KR + LT2p);% R3
LT3p_to_LT4p = p.k4c * R_active * LT3p / (p.KR + LT3p);% R4

% Demethylations of the receptor
T3_to_T2 = p.k_1 * Bp_active * T3;% R1
T4_to_T3 = p.k_2 * Bp_active * T4;% R2
LT3_to_LT2 = p.k_3 * Bp_active * LT3;% R3
LT4_to_LT3 = p.k_4 * Bp_active * LT4;% R4

T3p_to_T2p = p.k_1 * Bp_active * T3p;% R1
T4p_to_T3p = p.k_2 * Bp_active * T4p;% R2
LT3p_to_LT2p = p.k_3 * Bp_active * LT3p;% R3
LT4p_to_LT3p = p.k_4 * Bp_active * LT4p;% R4

% Ligand binding
T2_to_LT2 = p.k5 * L * T2;% R5
T3_to_LT3 = p.k6 * L * T3;% R6
T4_to_LT4 = p.k7 * L * T4;% R7

T2p_to_LT2p = p.k5 * L * T2p;% R5
T3p_to_LT3p = p.k6 * L * T3p;% R6
T4p_to_LT4p = p.k7 * L * T4p;% R7

% Ligand unbinding
LT2_to_T2 = p.k_5 * LT2;% R5
LT3_to_T3 = p.k_6 * LT3;% R6
LT4_to_T4 = p.k_7 * LT4;% R7

LT2p_to_T2p = p.k_5 * LT2p;% R5
LT3p_to_T3p = p.k_6 * LT3p;% R6
LT4p_to_T4p = p.k_7 * LT4p;% R7

% Auto-phosphorylations
T2_to_T2p = p.k8 * T2;% R8
T3_to_T3p = p.k9 * T3;% R9
T4_to_T4p = p.k10* T4;% R10

LT2_to_LT2p = p.k11 * LT2;% R11
LT3_to_LT3p = p.k12 * LT3;% R12
LT4_to_LT4p = p.k13 * LT4;% R13

% Phosphotransfer to CheB
B_to_Bp_T2p = p.kb * B_active * T2p; % R8
B_to_Bp_T3p = p.kb * B_active * T3p; % R9
B_to_Bp_T4p = p.kb * B_active * T4p; % R10

B_to_Bp_LT2p = p.kb * B_active * LT2p; % R11
B_to_Bp_LT3p = p.kb * B_active * LT3p; % R12
B_to_Bp_LT4p = p.kb * B_active * LT4p; % R113

% Phosphotransfer to CheY
Y_to_Yp_T2p = p.ky * Y_active * T2p; % R8
Y_to_Yp_T3p = p.ky * Y_active * T3p; % R9
Y_to_Yp_T4p = p.ky * Y_active * T4p; % R10

Y_to_Yp_LT2p = p.ky * Y_active * LT2p; % R11
Y_to_Yp_LT3p = p.ky * Y_active * LT3p; % R12
Y_to_Yp_LT4p = p.ky * Y_active * LT4p; % R13

% Dephosphorysation
Bp_to_B = p.k_b * Bp_all;
Yp_to_Y = p.k_y * Yp_all * Z_active;

%% Change in the concentrations
% This describes how the concentration of the species change due to the
% reactions. The "p" in front of the respective species name stands for the
% derivative operator.

% Receptor complex, not ligand bound, 2-4 fold methylated, not physphorylated
pT2 =            - T2_to_T3 + T3_to_T2            - T2_to_LT2 + LT2_to_T2 - T2_to_T2p + B_to_Bp_T2p + Y_to_Yp_T2p;
pT3 = + T2_to_T3 - T3_to_T4 + T4_to_T3 - T3_to_T2 - T3_to_LT3 + LT3_to_T3 - T3_to_T3p + B_to_Bp_T3p + Y_to_Yp_T3p;
pT4 = + T3_to_T4                       - T4_to_T3 - T4_to_LT4 + LT4_to_T4 - T4_to_T4p + B_to_Bp_T4p + Y_to_Yp_T4p;

% Receptor complex, not ligand bound, 2-4 fold methylated, physphorylated
pT2p =              - T2p_to_T3p + T3p_to_T2p              - T2p_to_LT2p + LT2p_to_T2p + T2_to_T2p - B_to_Bp_T2p - Y_to_Yp_T2p;
pT3p = + T2p_to_T3p - T3p_to_T4p + T4p_to_T3p - T3p_to_T2p - T3p_to_LT3p + LT3p_to_T3p + T3_to_T3p - B_to_Bp_T3p - Y_to_Yp_T3p;
pT4p = + T3p_to_T4p                           - T4p_to_T3p - T4p_to_LT4p + LT4p_to_T4p + T4_to_T4p - B_to_Bp_T4p - Y_to_Yp_T4p;

% Receptor complex, ligand bound, 2-4 fold methylated, not
% physphorylated
pLT2 =              - LT2_to_LT3 + LT3_to_LT2              + T2_to_LT2 - LT2_to_T2 - LT2_to_LT2p + B_to_Bp_LT2p + Y_to_Yp_LT2p;
pLT3 = + LT2_to_LT3 - LT3_to_LT4 + LT4_to_LT3 - LT3_to_LT2 + T3_to_LT3 - LT3_to_T3 - LT3_to_LT3p + B_to_Bp_LT3p + Y_to_Yp_LT3p;
pLT4 = + LT3_to_LT4                           - LT4_to_LT3 + T4_to_LT4 - LT4_to_T4 - LT4_to_LT4p + B_to_Bp_LT4p + Y_to_Yp_LT4p;

% Receptor complex, ligand bound, 2-4 fold methylated, physphorylated
pLT2p =                - LT2p_to_LT3p + LT3p_to_LT2p                + T2p_to_LT2p - LT2p_to_T2p + LT2_to_LT2p - B_to_Bp_LT2p - Y_to_Yp_LT2p;
pLT3p = + LT2p_to_LT3p - LT3p_to_LT4p + LT4p_to_LT3p - LT3p_to_LT2p + T3p_to_LT3p - LT3p_to_T3p + LT3_to_LT3p - B_to_Bp_LT3p - Y_to_Yp_LT3p;
pLT4p = + LT3p_to_LT4p                               - LT4p_to_LT3p + T4p_to_LT4p - LT4p_to_T4p + LT4_to_LT4p - B_to_Bp_LT4p - Y_to_Yp_LT4p;

% CheR
pR = zeros(size(R_all));

% CheB, unphosphorylated and phosphorylated
pB  = [B_all(1:end-1), 0] / B_active * (- B_to_Bp_T2p - B_to_Bp_T3p - B_to_Bp_T4p - B_to_Bp_LT2p - B_to_Bp_LT3p - B_to_Bp_LT4p) ...
    + Bp_to_B;
pBp = [B_all(1:end-1), 0] / B_active * (+ B_to_Bp_T2p + B_to_Bp_T3p + B_to_Bp_T4p + B_to_Bp_LT2p + B_to_Bp_LT3p + B_to_Bp_LT4p) ... 
    - Bp_to_B;

% CheY, unphosphorylated and phosphorylated
pY  = [Y_all(1:end-1), 0] / Y_active * (- Y_to_Yp_T2p - Y_to_Yp_T3p - Y_to_Yp_T4p - Y_to_Yp_LT2p - Y_to_Yp_LT3p - Y_to_Yp_LT4p) ...
    + Yp_to_Y;
pYp = [Y_all(1:end-1), 0] / Y_active * (+ Y_to_Yp_T2p + Y_to_Yp_T3p + Y_to_Yp_T4p + Y_to_Yp_LT2p + Y_to_Yp_LT3p + Y_to_Yp_LT4p)...
    - Yp_to_Y;

% CheZ
pZ = zeros(size(Z_all));

%% Build up the return variable.
xp = [pT2; pT3; pT4; pT2p; pT3p; pT4p; pLT2; pLT3; pLT4; pLT2p; pLT3p; pLT4p] * 10^6;
pCheProteins = [pR; pB; pBp; pY; pYp; pZ] * 10^6;