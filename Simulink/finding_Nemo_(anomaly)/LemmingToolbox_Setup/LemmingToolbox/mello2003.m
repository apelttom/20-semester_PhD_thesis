function [xp, pCheProteins] = mello2003(t, x, cheProteins, p, aspFunc)
% Model of chemotaxis in E-Coli.
% Based on Mello et al. (2003). "Perfect and Near-Perfect Adaptation in a

% Model of Bacterial Chemotaxis", Biophysical Journal Vol. 84 2943-2956
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
% [xp, pCheProteins] = mello2003(t, x, cheProteins, p, aspFunc)
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

%% Return valid initial conditions if requested
if nargin == 1
    p = t;
    xp = [p.T_tot; 0; 0; 0; 0; p.T_tot; 0; 0; 0; 0; 0; 0; 0; 0; 0];
    pCheProteins = [p.R_tot; p.B_tot/2; p.B_tot/2; p.Y_tot/2; p.Y_tot/2; p.Z_tot];
    return;
end

%% Rescale mu M -> M
x = x * 10^-6;
cheProteins = cheProteins * 10^-6;

%% get current Aspartate concentration
if isa(aspFunc, 'function_handle')
    Asp = aspFunc(t);
else
    Asp = aspFunc;
end
% In the Mello model, binding and unbinding of the ligand to the receptors
% is assumed to be a fast reaction and thus is approximated by the quasi
% steady state assumption. The variable L in the model is only describing
% the percentage of receptors which are bound to the ligand. To come from
% the absolute ligand concentration to the percentage of receptors bound to
% the ligand, we use the binding and unbinding reaction rate constants of
% the Spiro model and calculate for them the QSSA. When doing so, we
% obtain the following Michaelis Menten kinetic:
L = Asp / (p.KDAsp + Asp);
%% Species

% Free receptors in the paper defined by an algebraic equation. To solve
% the differential algebraic equations, we include them as  
% additional states with a stable equilibrium where the algebraic equation
% is fullfilled (standard trick for DAEs).
TF_0 = x(1);
TF_1 = x(2);
TF_2 = x(3);
TF_3 = x(4);
TF_4 = x(5);

% Total receptors with respective methylation level.
T_0 = x(6);
T_1 = x(7);
T_2 = x(8);
T_3 = x(9);
T_4 = x(10);

% Phosphorylated receptors with respective methylation levels.
TP_0 = x(11);
TP_1 = x(12);
TP_2 = x(13);
TP_3 = x(14);
TP_4 = x(15);

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
Z_active = sum(Z_all(1:end-1)); %#ok<NASGU>

%% Reactions
% The comment behind the reaction states the number of the reaction in the
% figure in the Spiro paper. More than one elementary reaction may
% correspond to the respective reaction in the Spiro paper (e.g. forward
% and backward reachtions).

%% Methylation and demythylation receptors
% (Eq. 10 and relations)
% Dissociation rates for binding CheR and TAR
% The dissociation rate depends on the amound of ligands bound (=L) and are
% calculated according to the equation directly below Eq. 6.
% The values for K_nv^E and K_no^E with E={R,B} are calculated according to
% the second condition for perfect adaptation on page 2947. The relative
% activities used in this formula are from Table 3.
KR_0 = ((1-L)*(p.KR)^-1 * (p.P_4v - p.P_0v) + L*(p.KR)^-1 * (p.P_4o - p.P_0o))^-1;
KR_1 = ((1-L)*(p.KR)^-1 * (p.P_4v - p.P_1v) + L*(p.KR)^-1 * (p.P_4o - p.P_1o))^-1;
KR_2 = ((1-L)*(p.KR)^-1 * (p.P_4v - p.P_2v) + L*(p.KR)^-1 * (p.P_4o - p.P_2o))^-1;
KR_3 = ((1-L)*(p.KR)^-1 * (p.P_4v - p.P_3v) + L*(p.KR)^-1 * (p.P_4o - p.P_3o))^-1;
KR_4 = ((1-L)*(p.KR)^-1 * (p.P_4v - p.P_4v) + L*(p.KR)^-1 * (p.P_4o - p.P_4o))^-1;

% Dissociation rates for binding CheB and TAR
KB_0 = ((1-L)*(p.KB)^-1 * (p.P_0v - p.P_0v) + L*(p.KB)^-1 * (p.P_0o - p.P_0v))^-1;
KB_1 = ((1-L)*(p.KB)^-1 * (p.P_1v - p.P_0v) + L*(p.KB)^-1 * (p.P_1o - p.P_0v))^-1;
KB_2 = ((1-L)*(p.KB)^-1 * (p.P_2v - p.P_0v) + L*(p.KB)^-1 * (p.P_2o - p.P_0v))^-1;
KB_3 = ((1-L)*(p.KB)^-1 * (p.P_3v - p.P_0v) + L*(p.KB)^-1 * (p.P_3o - p.P_0v))^-1;
KB_4 = ((1-L)*(p.KB)^-1 * (p.P_4v - p.P_0v) + L*(p.KB)^-1 * (p.P_4o - p.P_0v))^-1;

% The additional states for the receptor, which are necessary to solve the
% DAE (eq. 9). They represent the free receptors.
pTF_0 = p.CorrectionTF * ((1 + R_active/KR_0 + Bp_active/KB_0) * TF_0 - T_0);
pTF_1 = p.CorrectionTF * ((1 + R_active/KR_1 + Bp_active/KB_1) * TF_1 - T_1);
pTF_2 = p.CorrectionTF * ((1 + R_active/KR_2 + Bp_active/KB_2) * TF_2 - T_2);
pTF_3 = p.CorrectionTF * ((1 + R_active/KR_3 + Bp_active/KB_3) * TF_3 - T_3);
pTF_4 = p.CorrectionTF * ((1 + R_active/KR_4 + Bp_active/KB_4) * TF_4 - T_4);

% Net flux from methylation level n to level (n+1) (eq. 11)
% TODO: Maybe kR and kB are dependent on n. Check it!
J_0 = (p.kR)*(R_active*TF_0)/KR_0 - (p.kB)*(Bp_active*TF_1)/KB_1;
J_1 = (p.kR)*(R_active*TF_1)/KR_1 - (p.kB)*(Bp_active*TF_2)/KB_2; 
J_2 = (p.kR)*(R_active*TF_2)/KR_2 - (p.kB)*(Bp_active*TF_3)/KB_3; 
J_3 = (p.kR)*(R_active*TF_3)/KR_3 - (p.kB)*(Bp_active*TF_4)/KB_4; 

% Kinetic equation, receptor unphosphorylated (eq. 10)
pT_0 =     - J_0;
pT_1 = J_0 - J_1;
pT_2 = J_1 - J_2;
pT_3 = J_2 - J_3;
pT_4 = J_3 ;

%% Autophosphorylation and Phosphotransfer
% (Eq. 17 - 19 and relations)

% The rates are from the equations in between Eq 19 and 20.
% The rates for kP_{n,lambda} originate from Eq. 1
% Autophosphorylation CheA (Used in Eq. 19)
kP_0 = L * (p.kP*p.P_0o) + (1-L) * (p.kP*p.P_0v);
kP_1 = L * (p.kP*p.P_1o) + (1-L) * (p.kP*p.P_1v);
kP_2 = L * (p.kP*p.P_2o) + (1-L) * (p.kP*p.P_2v);
kP_3 = L * (p.kP*p.P_3o) + (1-L) * (p.kP*p.P_3v);
kP_4 = L * (p.kP*p.P_4o) + (1-L) * (p.kP*p.P_4v);

% Phosphotransfer from CheA to CheY (used in Eqs. 17 and 19)
% The values for kPY_{n, lambda} are given in the 5th condition for perfect
% adaptation, p. 2947)
kPY_0 = L*(p.kPY*p.P_0o)+(1-L)*(p.kPY*p.P_0v);
kPY_1 = L*(p.kPY*p.P_1o)+(1-L)*(p.kPY*p.P_1v);
kPY_2 = L*(p.kPY*p.P_2o)+(1-L)*(p.kPY*p.P_2v);
kPY_3 = L*(p.kPY*p.P_3o)+(1-L)*(p.kPY*p.P_3v);
kPY_4 = L*(p.kPY*p.P_4o)+(1-L)*(p.kPY*p.P_4v);

% Phosphotransfer from CheA to CheB (used in Eqs. 18 and 19)
% The values for kPB_{n, lambda} are given in the 5th condition for perfect
% adaptation, p. 2947)
kPB_0 = L*(p.kPB*p.P_0o)+(1-L)*(p.kPB*p.P_0v);
kPB_1 = L*(p.kPB*p.P_1o)+(1-L)*(p.kPB*p.P_1v);
kPB_2 = L*(p.kPB*p.P_2o)+(1-L)*(p.kPB*p.P_2v);
kPB_3 = L*(p.kPB*p.P_3o)+(1-L)*(p.kPB*p.P_3v);
kPB_4 = L*(p.kPB*p.P_4o)+(1-L)*(p.kPB*p.P_4v);

% Amount of unphosphorylated receptors with n methylation sites
TU_0 = T_0 - TP_0;
TU_1 = T_1 - TP_1;
TU_2 = T_2 - TP_2;
TU_3 = T_3 - TP_3;
TU_4 = T_4 - TP_4;

% Conservation relation for unbound, but phosphorylated, receptors. As
% written in the paper between Eq. 19 and Eq 20, the equations for the
% phosphorylated receptors are similar to Eq. 9.
TFP_0 = TP_0 / (1+R_active/KR_0+Bp_active/KB_0);
TFP_1 = TP_1 / (1+R_active/KR_1+Bp_active/KB_1);
TFP_2 = TP_2 / (1+R_active/KR_2+Bp_active/KB_2);
TFP_3 = TP_3 / (1+R_active/KR_3+Bp_active/KB_3);
TFP_4 = TP_4 / (1+R_active/KR_4+Bp_active/KB_4);

% Net flux from methylation level n to level (n+1)
JP_0 = (p.kR)*(R_active*TFP_0)/KR_0 - (p.kB)*(Bp_active*TFP_1)/KB_1;
JP_1 = (p.kR)*(R_active*TFP_1)/KR_1 - (p.kB)*(Bp_active*TFP_2)/KB_2; 
JP_2 = (p.kR)*(R_active*TFP_2)/KR_2 - (p.kB)*(Bp_active*TFP_3)/KB_3; 
JP_3 = (p.kR)*(R_active*TFP_3)/KR_3 - (p.kB)*(Bp_active*TFP_4)/KB_4; 

% Rates for the phosphorylated receptors (see Eq. 19): Autophosphorylation,
% the two phosphotransfers and the methylation flux.
pTP_0 = kP_0 * TU_0 - kPY_0 * TP_0 * Y_active - kPB_0 * TP_0 * B_active +      - JP_0;
pTP_1 = kP_1 * TU_1 - kPY_1 * TP_1 * Y_active - kPB_1 * TP_1 * B_active + JP_0 - JP_1;
pTP_2 = kP_2 * TU_2 - kPY_2 * TP_2 * Y_active - kPB_2 * TP_2 * B_active + JP_1 - JP_2;
pTP_3 = kP_3 * TU_3 - kPY_3 * TP_3 * Y_active - kPB_3 * TP_3 * B_active + JP_2 - JP_3;
pTP_4 = kP_4 * TU_4 - kPY_4 * TP_4 * Y_active - kPB_4 * TP_4 * B_active + JP_3;

% Additional rates to make it compatible to LightActivation

% The following differential equation is introduced to account for the
% algebraic equation (Eq. 7). Since we cannot solve the DAE directly, we
% intoduced a new state R^F which represents the amount of free (not bound
% to Tar) CheR proteins. The differential equation is formulized so that it
% has a stable steady state at a point where Eq. 7 is fullfilled. 
% Conservation equations. This is just done by a simple linear DGL:
% d/dt R = k * (R_should - R),
% with k high enough to obtain a separation of time scales.
pR = [R_all(1:end-1), 0] / R_active * p.CorrectionRF * ((sum(R_all) + R_active * (TF_0/KR_0 + TF_1/KR_1 + TF_2/KR_2 + TF_3/KR_3 + TF_4/KR_4)) - p.R_tot * 1e-6);
% CheB, unphosphorylated and phosphorylated
pB  = [B_all(1:end-1), 0] / B_active * (- kPB_0 * TP_0 * B_active...
                                        - kPB_1 * TP_1 * B_active...
                                        - kPB_2 * TP_2 * B_active...
                                        - kPB_3 * TP_3 * B_active...
                                        - kPB_4 * TP_4 * B_active)...
                                        + p.kHB * Bp_all; % dephosphorylation

pBp  = [B_all(1:end-1), 0] / B_active * (+ kPB_0 * TP_0 * B_active...
                                         + kPB_1 * TP_1 * B_active...
                                         + kPB_2 * TP_2 * B_active...
                                         + kPB_3 * TP_3 * B_active...
                                         + kPB_4 * TP_4 * B_active)...
                                         - p.kHB * Bp_all; % dephosphorylation
                                    
% CheY, unphosphorylated and phosphorylated
pY = [Y_all(1:end-1), 0] / Y_active * (- kPY_0 * TP_0 * Y_active...
                                       - kPY_1 * TP_1 * Y_active...
                                       - kPY_2 * TP_2 * Y_active...
                                       - kPY_3 * TP_3 * Y_active...
                                       - kPY_4 * TP_4 * Y_active)...
                                       + p.kHY * Z_active * Yp_all;

pYp = [Y_all(1:end-1), 0] / Y_active * (+ kPY_0 * TP_0 * Y_active...
                                        + kPY_1 * TP_1 * Y_active...
                                        + kPY_2 * TP_2 * Y_active...
                                        + kPY_3 * TP_3 * Y_active...
                                        + kPY_4 * TP_4 * Y_active)...
                                        - p.kHY * Z_active * Yp_all;

% CheZ
pZ = zeros(size(Z_all));
%% Build up the return variable.
xp = [pTF_0; pTF_1; pTF_2; pTF_3; pTF_4; pT_0; pT_1; pT_2; pT_3; pT_4; pTP_0; pTP_1; pTP_2; pTP_3; pTP_4] * 10^6;
pCheProteins = [pR; pB; pBp; pY; pYp; pZ] * 10^6;