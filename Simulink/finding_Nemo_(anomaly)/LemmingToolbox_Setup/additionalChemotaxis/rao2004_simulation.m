% This function plots the variation of CheYp when an attactant is added at
% 500s and removed at 1000s. Demonstrates adaptation

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

function rao2004_simulation()

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


%% equilibrating the model to get sensible intial conditions

x0 = zeros(10,1);
%x0(7) = 5;
x0(8) = 5;
t = [-1000:0];
[t,x] = ode15s(@model_rao2004,t,x0);

%% get steady state conditions
x0 = x(end,:);

%% actual simulation
t = [0;1500];
[t,x] = ode15s(@model_rao2004,t,x0);

%% plots
figure(1)

h = plot(t,x(:,2));
xlabel('Time (sec)')
ylabel('CheYp (\mu M)')
end