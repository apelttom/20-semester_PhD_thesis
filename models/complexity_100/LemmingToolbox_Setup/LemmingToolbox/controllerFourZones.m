function [RL, FRL] = controllerFourZones(t, phi_is, phi_sh) %#ok<INUSL>
% Controller Design Competition contribution of George Rosenberger
%
% Working with
% *) Controlled species concentration: 20
% *) Anker protein concentration 50
% *) Anker concentration 65
%
% Evaluation: 0.8196

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


% define global variables: current repeat amount for RL / FRL light pulse
global rRL rFRL;

if isempty(rRL)
    rRL = 0;
end
if isempty(rFRL)
    rFRL = 0;
end

% define factor threshold (ft == 1 => 15°)
ftr = 4;
ftt = 5;
ftw = 8;

% calculate angular difference
if ((2*pi - phi_is) + phi_sh) < abs(phi_is - phi_sh)
    dphi = ((2*pi - phi_is) + phi_sh);
elseif ((2*pi - phi_sh) + phi_is) < abs(phi_is - phi_sh)
    dphi = ((2*pi - phi_sh) + phi_is);
else
    dphi = abs(phi_is - phi_sh);
end

if rRL == 0 && rFRL == 0
% Check direction & setup repeating pulses
    factor = floor(dphi / (pi/12)); % divide dphi by 15° and create factor.
    if factor <= ftr
        rRL = 1;
        rFRL = 0;
    elseif factor <= ftt
        rRL = 0;
        rFRL = 0;
    elseif factor < ftw
        rRL = 0;
        rFRL = ftw - factor;
    else
        rRL = 0;
        rFRL = 1;
    end
end

RL = false;
FRL = false; 

if rRL > 0 || rFRL > 0
% Emitt light pulses
    if rRL > 0
        RL = true;
        rRL = rRL - 1;
    end
    if rFRL > 0
        FRL = true;
        rFRL = rFRL - 1;
    end
end