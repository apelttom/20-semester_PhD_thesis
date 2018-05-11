function dx = model_rao2004(t,x)
% Returns the ODEs for the chemotaxis model proposed by Rao et al. (2004)
% Reference: Design and Diversity in Bacterial Chemotaxis. Rao et al. (2004). PLoS
% Biol 2004;2;2;239-252.

% Copyright 2010 Thanuja Ambegoda
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

%% key (chemical species modeled)
% x1 - Ap
% x2 - Yp
% x3 - YpM - CheM
% x4 - Bp
% x5 - T0
% x6 - T1
% x7 - T2
% x8 - T3
% x9 - T4

dx = zeros(size(x));

%% Parameters


%% defining ligand concentration L = 1 when 500<t<1000 for our simulations
if (t<500)
  L = 0;
elseif (t<1000)
  L = 1;
else
  L = 0;
end

%% species concentrations & conserved relations 
CheATot = 5;
CheYTot = 17.9;
CheMTot = 5.8;
CheBTot = 2;
R = 0.3;

CheA = CheATot - x(1);                    
Y = CheYTot - x(2) - x(3);
CheM = CheMTot - x(3);
B = CheBTot - x(4);


%% activation probabilities
% defining constants
alpha11 = 0.0;
alpha12 = 0.1;
alpha13 = 0.5;
alpha01 = 0.1;
alpha02 = 0.5;
alpha03 = 0.75;

% calculationg of activtion probabilities for different methylation states
a1 = alpha11*L/(1+L) + alpha01*1/(1+L);      % prob that T1 is active @ [L]
a2 = alpha12*L/(1+L) + alpha02*1/(1+L);      % prob that T2 is active @ [L] 
a3 = alpha13*L/(1+L) + alpha03*1/(1+L);      % prob that T3 is active @ [L]

%% Active & inactive receptors
active = a1*x(6) + a2*x(7) + a3*x(8) + x(9);               % active receptor concentration
inactive = x(5) + (1-a1)*x(6) + (1-a2)*x(7) + (1-a3)*x(8); % inactive receptor concentration

%% Parameters
KmR  = (1+0.255)/5;
kr = 0.255*R/(KmR + inactive);
KmB = (5+0.5)/1;
kb  = 0.5*x(4)/(KmB + active); 

%% ODEs for Che species
% Ap

dx(1) = active*50*CheA - 100*Y*x(1) - 30*B*x(1);
% Yp
dx(2) = 100*Y*x(1) - 0.1*x(2) - 5*CheM*x(2) + 19*x(3) - 30*x(2);
% YpM
dx(3) = 5*CheM*x(2) - 19*x(3);
% Bp
dx(4) = 30*B*x(1) - x(4);

%% ODEs for receptors (for different methylation levels)

% T0
dx(5) = -kr*x(5) + kb*a1*x(6);
% T1
dx(6) = kr*x(5) - kr*(1-a1)*x(6)+ kb*a2*x(7) - kb*a1*x(6);
% T2
dx(7) = kr*(1-a1)*x(6) - kr*(1-a2)*x(7)+ kb*a3*x(8) - kb*a2*x(7);
% T3
dx(8) = kr*(1-a2)*x(7) - kr*(1-a3)*x(8)+kb*x(9) - kb*a3*x(8);
% T4
dx(9) = kr*(1-a3)*x(8) - kb*x(9);

end