function [RL, FRL] = controllerMajorityVote(t, phi_is, phi_sh)
% Controller Design Competition contribution of Thanuja Ambegoda
%
% Working with
% *) Controlled species concentration: 20
% *) Anker protein concentration 50
% *) Anker concentration 65
%
% Evaluation: 0.8379


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


%% Thresholds
error_threshold = pi*45/180;          % 45 degrees
error_threshold_upper = pi*60/180;    % 60 degrees
error_rate_threshold = pi*7/180;      % 10 degrees
accuracy_threshold = pi*30/180;       % 30 degrees

%% calculate the error
% 0 ~ 2*pi
phi_sh = mod(phi_sh,2*pi);
phi_is = mod(phi_is,2*pi);

% mirror angle
if(phi_sh > pi)
    phi_sh = phi_sh - 2*pi;
end

if(phi_is > pi)
    phi_is = phi_is - 2*pi;
end

% calculate the error
error = abs(phi_sh - phi_is);

% error log
i = t/0.3 + 1;
i = fix(i);
persistent error_log;
error_log(i) = error;

if(i<7)
    check_error = sum(error_log);
else
    check_error = error_log((i-6):i);
end


%% control algorithm
% initializing controller
persistent tumbling;
persistent running;

if(t < 2.4)
    RL = true;
    FRL = false;
    
    tumbling = 0;
    running = 0;
else
 
% Error rate                                              condition (1)
% check_error
% check the last 7 points
% check the rate of increase of error over the last 7 points
% if the rate of increase of error is over the threshold make it tumble

error_rate = size((find((diff(diff(check_error)))>error_rate_threshold)),2); % exceeding rate threshold out of 5


% Majority Vote                                            condition (2)
mistakes = find(check_error>error_threshold);
mistake_count=size(mistakes,2);                     % mistakes out of 7


if(error_rate>=3 && mistake_count>=4 && tumbling==0)
    % tumble for 8 frames & run for 8 frames
    tumbling = 8;
end

% Majority Vote 2                                           condition (3)
mistakes_upper = find(check_error>error_threshold_upper);
mistake_count_upper=size(mistakes_upper,2);                     % mistakes out of 7

if(mistake_count_upper>=5)
    %tumble
    tumbling = 10;
end


% make it tumble for 8 frames (2.4 seconds)
if(tumbling > 0)
    RL = false;
    FRL = true;
    tumbling = tumbling -1;
    if(tumbling==0 || check_error(end)>error_threshold_upper)
        tumbling = 8;
    end
        
    if(tumbling==0 || check_error(end)<accuracy_threshold)
        running=8;
        tumbling=0;
    end
end

if(running>0)
    RL = true;
    FRL = false;
    running = running -1;
    
end

if(tumbling==0 && running==0)
    RL = false;
    FRL = false;
end
    

% end of control algo for t > 3
end

