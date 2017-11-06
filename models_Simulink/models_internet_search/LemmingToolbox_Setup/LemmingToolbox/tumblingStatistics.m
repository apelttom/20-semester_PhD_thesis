% This block generates some statistics about the tumbling behaviour of the
% model where the data feeded in this function is from.

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

% Find tumbling start and end times
running = tumblingData.signals.values(:, 2);
phi =  tumblingData.signals.values(:, 1);
t = tumblingData.time;
dRunning = diff(running);
tumblingStarts = find(dRunning < 0) + 1;
tumblingEnds = find(dRunning > 0) + 1;
while tumblingStarts(1) > tumblingEnds(1)
    tumblingEnds(1) = [];
end
tumblingStarts(tumblingStarts > length(dRunning)) = [];
tumblingEnds(tumblingEnds > length(dRunning)) = [];

% Now calculate changes in angles during tumbling
deltaPhi = zeros(1, length(tumblingEnds));
for i=1:length(deltaPhi)
    deltaPhi(i) = mod(phi(tumblingEnds(i)) - phi(tumblingStarts(i)), 2 * pi);
    deltaPhi(i) = min(deltaPhi(i), 2 * pi - deltaPhi(i));
end
% Calculate tumbling times
tumblingTimes = zeros(1, length(tumblingEnds));
for i=1:length(tumblingTimes)
    tumblingTimes(i) = t(tumblingEnds(i)) - t(tumblingStarts(i));
end
% Calculate straight times
straightTimes = zeros(1, length(tumblingStarts) - 1);
for i=1:length(straightTimes)
    straightTimes(i) = t(tumblingStarts(i + 1)) - t(tumblingEnds(i));
end

% Now calculate changes in angles during straight
deltaPhiStraight = zeros(1, length(tumblingStarts) - 1);
for i=1:length(deltaPhiStraight)
    deltaPhiStraight(i) = mod(phi(tumblingStarts(i + 1)) - phi(tumblingEnds(i)), 2 * pi);
    deltaPhiStraight(i) = min(deltaPhiStraight(i), 2 * pi - deltaPhiStraight(i));
end

%% plot result
figure();
hist(deltaPhi * 180 / pi, 30);
xlabel('Change in angle [°]');
ylabel('density');

title(sprintf('Mean angle change during tumbling: %g° +- %g°', mean(deltaPhi * 180 / pi), std(deltaPhi * 180 / pi)));

%%
figure();
hist(deltaPhiStraight * 180 / pi, 30);
xlabel('Change in angle [°]');
ylabel('density');

title(sprintf('Mean angle change during straight: %g° +- %g°', mean(deltaPhiStraight * 180 / pi), std(deltaPhiStraight * 180 / pi)));
%%
figure();
hist(tumblingTimes, 30);
xlabel('Tumbling times [s]');
ylabel('density');
title(sprintf('Mean tumbling times: %g° +- %g°', mean(tumblingTimes), std(tumblingTimes)));
%%
figure();
hist(straightTimes, 30);
xlabel('Straight times [s]');
ylabel('density');
title(sprintf('Mean straight times: %g° +- %g°', mean(straightTimes), std(straightTimes)));