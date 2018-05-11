function [RL, FRL] = controllerThresholdOptimized(t, phi_is, phi_sh) %#ok<INUSL>
% Controller Design Competition contribution of Simona Constantinescu
%
% Working with
% *) Controlled species concentration: 45
% *) Anker protein concentration 60
% *) Anker concentration 80
%
% Evaluation: 0.7703


% Copyright 2010 Simona Constantinescu
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

if phi_is>2*pi
    phi_is = 2*pi;
end

if phi_is<0
    phi_is = 0;
end

min = 1.5;
max = 4.7;
error = mod(phi_is - phi_sh, 2*pi);

if (error<min || error>max)
    RL = true;
    FRL = false;
else
    RL = false;
    FRL = true;
end