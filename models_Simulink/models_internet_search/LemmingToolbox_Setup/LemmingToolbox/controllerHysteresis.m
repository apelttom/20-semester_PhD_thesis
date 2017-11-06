function [RL, FRL] = controllerHysteresis(t, phi_is, phi_sh)
% Controller Design Competition contribution of Moritz Lang
%
% Working with
% *) Controlled species concentration: 42
% *) Anker protein concentration 57
% *) Anker concentration 80
%
% Evaluation: 0.7727


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

persistent isRunningState pulseLength
if isempty(isRunningState)
    isRunningState = false;
    pulseLength = 0;
end
    

angleDiff = mod(phi_is-phi_sh, 2*pi);
if angleDiff > pi
    angleDiff = 2*pi - angleDiff;
end

if isRunningState
    if abs(angleDiff) > pi / 2
        isRunningState = false;
        pulseLength = 2.1;
    end
else
    if abs(angleDiff) < pi / 3
        isRunningState = true;
        pulseLength = 2.4;
    end
end

RL = false;
FRL = false;

if pulseLength > 0
    if isRunningState
        RL = true;
    else
        FRL = true;
    end
    pulseLength = pulseLength - 0.3;
end