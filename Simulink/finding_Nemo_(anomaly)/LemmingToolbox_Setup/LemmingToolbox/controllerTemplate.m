function [RL, FRL] = controllerTemplate(t, phi_is, phi_sh)
% This is the template for your controller. Every 0.3 seconds (simulation time) this function
% is called. You get 3 inputs:
% t         ... the current simulation time
% phi_is    ... the current angle where the E. lemming travells. Be carefull,
%               to make the task a little bit more realistic, I added a
%               little bit of noise on the angle. Furthermore you will not
%               get the current direction of the E. lemming, but the
%               direction it had 1s before (simulates delay of microscope & image
%               analysis).
% phi_sh    ... the angle where the E. lemming should go. As a tip: This
%               angle is given so, that in the optimal case your lemming
%               travells clockwise on a square with 5 units edge length.
%               The next direction is activated when the distance to the
%               current corner is smaller than 0.5. However, probably you
%               can ignore this and just travel in the supposed direction.
%               To make cheating harder the exact shape of the square might
%               be changed lateron.
%
% Now, you have to build a smart algorithm so that you generate the best
% path by setting the outputs:
% RL        ... true, if red light should be on the next 0.3s, false otherwise.
% FRL       ... the same for far-red light
%
% Be aware that RL and FRL are boolean variables. Setting them to any other
% value then {true, false} or {1, 0} may cause problems.
%
% Now: good luck!
% Moritz


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

RL = false;
FRL = false;
