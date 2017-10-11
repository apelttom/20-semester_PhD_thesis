function [dx, running, tumblingSpeed] = movementModel(t, x, dt, running, tumblingSpeed, bias)
% Simulation of the movement of an E-coli.
%
% Parameters:
% running: running or tumbling
%   running == 1 ... running state
%   running == 0 ... tumbling state
%
%tumblingCCW: tumbling direction
%   tumblingCCW == true  ... counter clock wise
%   tumblingCCW == false ... clock wise

% Copyright 2010 Thanuja Ambegoda, Simona Constantiescu, Christoph Hold, Moritz Lang
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

% define constants
MEAN_TUMBLING_LENGTH = 0.14; % [1]
V = 14.2; % [1] average velocity of running

% Define Probability of tumbling when in tumbling state
p2 = 1 - dt/MEAN_TUMBLING_LENGTH;

% check state variable
if running 
    %running state
    %differential equations for running
    dx = runAStep(t, x, V, dt);        % phi should be obtained %%%%%%%%%%%%%%%%%
    
    % Probability of running when in running state
    p1 = calculatep1(dt, MEAN_TUMBLING_LENGTH, bias);
    
    %check probability to change the state
    if(rand() > p1)
        running = false;       % change state to tumbling
        % Determine speed for the tumbling
        tumblingSpeed = sign(rand() - 0.5) * (randn()*0.6 + 1.4) / MEAN_TUMBLING_LENGTH;
    end
    
else
    % tumbling state
    dx = tumbleAStep(t, x, tumblingSpeed);%, MEAN_TUMBLING_LENGTH, dt);
    
    %check probability to change state
    if(rand() > p2)        % check probability to change the state
        running = true;       % change state to running
    end
    
end
end
%% function to calculate p1
function p1 = calculatep1(dt, MEAN_TUMBLING_LENGTH, bias)

MEAN_RUN_LENGTH = (bias * MEAN_TUMBLING_LENGTH)/(1-bias);
p1 = 1 - dt/MEAN_RUN_LENGTH;
end

%% ODE function for x y for the running state
function dX = runAStep(t, x, v, dt) %#ok<INUSL>
    MEAN_RUN_LENGTH_0 = 0.86; %[s]
    MEAN_ANGLE_RUN = 23 / 180 * pi; % [rad]
    dX = [v * cos(x(3)); v * sin(x(3)); MEAN_ANGLE_RUN * sqrt(pi/2) / sqrt(MEAN_RUN_LENGTH_0 * dt) * randn()];
end
%% ODE function for x y for the tumbling state
% the timestep dt and the current angle phi0 should be passed when calling
% for the solver
%function dX = tumbleAStep(t, X, tumblingCCW, MEAN_TUMBLING_LENGTH, dt)
function dX = tumbleAStep(t, x, tumblingSpeed) %#ok<INUSL>
    dX = [0; 0; tumblingSpeed];
end

%% References:
% [1] - Chemotaxis in E. Coli analysed by 3D Tracking. H.C. Berg & D.A. Brown.
% Nature: Oct 1972