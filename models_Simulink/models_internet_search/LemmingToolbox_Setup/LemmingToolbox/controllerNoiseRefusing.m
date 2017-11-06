function [RL, FRL] = controllerNoiseRefusing(t, phi_is, phi_sh) %#ok<INUSL>
% Controller Design Competition contribution of Christoph Hold
%
% Working with
% *) Controlled species concentration: 20
% *) Anker protein concentration 60
% *) Anker concentration 80
%
% Evaluation 0.8089

% Copyright 2010 Christoph Hold
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

% conversion of angles into degrees
angle_is = phi_is*180/pi;
if angle_is > 180
    angle_is = angle_is - 360;
end
angle_so = phi_sh*180/pi;
if angle_so > 180
    angle_so = angle_so - 360;
end

% store last state
persistent angle_is_old RL_old FRL_old

if isempty(angle_is_old)
    angle_is_old = angle_is;
    RL_old = false;
    FRL_old = false;
end


% controller
winkel_tol = 28;
winkel_eng = 45;
winkel_weit = 65;

da_new_old = abs(angle_is_old - angle_is);
da = abs(angle_so - angle_is);

if da_new_old < winkel_tol && da < (winkel_tol+winkel_weit)% nur Rauschen
    RL = RL_old; % Eingang beibehalten
    FRL = FRL_old;
else % Regler anschmeissen

    if da < winkel_weit
        RL = true; % run, bias = 1
        FRL = true;
    %     disp('kleiner')
    else
        RL = false;
        FRL = true;
    %     disp('groesser')
    end

    if da < winkel_eng
        RL = true; % run, bias = 1
        FRL = false;
    end    
end

% store last state
angle_is_old = angle_is;
RL_old = RL;
FRL_old = FRL;

