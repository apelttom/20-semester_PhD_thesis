function experimentalDesign(modus)
% Experimental Design: Evaluation of suitable parameters for wet laboratory and
% information processing. This script allows to calculate response of the
% system and plot the results.
%
% Usage
% --------
% Evaluation of suitable parameters for wet laboratory and information processing.
% This script allows to calculate the response of the system and plot the
% results. It requires Lemming Toolbox to be installed.
%
% Parameters:
% -----------------------
% 0: Analysis of the system
% 1: Determine relative amplitude
% 2: Determine optimal parameter set for wet laboratory
% 3: Determine RL/FRL time constants for information processing

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

if nargin == 0
    fprintf('Experimental Design\n-------------------\n');
    fprintf('Evaluation of suitable parameters for wet laboratory and\ninformation processing. This script allows to calculate\nthe response of the system and plot the results.\n\n');
    fprintf('Change experimental setup in this script.\n\n');
    fprintf('Modi of operation:\n0: Analysis of the system\n1: Determine relative amplitude\n2: Determine optimal parameter set for wet laboratory\n3: Determine RL/FRL time constants for information processing\n');

    while 1
        modus = input('Please choose your modus [0]: ', 's');
        if isempty(modus)
            modus = 0;
            break
        elseif strcmpi(modus, '0')
            modus = 0;
            break
        elseif strcmpi(modus, '1')
            modus = 1;
            break
        elseif strcmpi(modus, '2')
            modus = 2;
            break
        elseif strcmpi(modus, '3')
            modus = 3;
            break
        else
            fprintf('This input is not valid. Please try again.\n');
            continue
        end
    end
    fprintf('\n');
end
%% Configuration: Basics
% Name of Che protein attached to PIF3/CheB: {'CheR', 'CheB', 'CheY',
% 'CheZ'}
cheSpecies = 'CheY';

% The LSP1 fused to the Che protein: {PhyB = 1, PIF3 = 0}
attachedToPhyBOrPIF3 = 0;

% The chemotaxis model to use: {'spiro', 'mello'}.
chemotaxisModel = 'spiro';

% Define aspartate concentration: {'small', 'medium', 'high'}
asplevel = 'medium';

% Setup time span
t_0 = 0; %[s]
t_final = 580; % [s]
t_span = [t_0 t_final];

%% Configuration: Red and Far-Red Light pulse
% Helper function: activates the light at t=<start> for <duration> seconds
lightOnOff = @(t, start, duration) smoothedStep(t, start,  1/60^2) ...
     - smoothedStep(t, start + duration,  1/60^2);

% Temporal evolution of light pulses
rlfunc = @(t) lightOnOff(t, 10, 0.3) + lightOnOff(t, 200, 0.3) + lightOnOff(t, 390, 0.3);
frlfunc = @(t) lightOnOff(t, 50, 10) + lightOnOff(t, 250, 10) + lightOnOff(t, 440, 10);

% Timepoints of light changes (required for modus 3)
rlt = [10 200 390 t_final];
frlt = [0 50 250 440 t_final];

% Get parameters
% Get aspartate concentration
asp = aspConcentration(chemotaxisModel, asplevel);

% Get parameter structure
p = getParameters(chemotaxisModel);

%% Question 0: Analysis of the system
if modus == 0
    % Simulation
    [t_out, cheProteins, CheY, CheY_free, CheYp, CheYp_free] = simulation(t_span, p, chemotaxisModel, cheSpecies, attachedToPhyBOrPIF3, asp, rlfunc, frlfunc);
    
    % Plot results
    plotSimulation(t_out, cheProteins, CheY, CheY_free, CheYp, CheYp_free, attachedToPhyBOrPIF3, p);
end

%% Question 1: What is the time with the highest CheYp amplitude?
if modus == 1
    % Simulation
    [t_out, cheProteins, CheY, CheY_free, CheYp, CheYp_free] = simulation(t_span, p, chemotaxisModel, cheSpecies, attachedToPhyBOrPIF3, asp, rlfunc, frlfunc);

    % Calculate relative amplitude
    A_max = relative_amplitude(CheYp_free, t_out);
    
    fprintf('The relative amplitude is: %g\n', A_max);
end

%% Question 2: What is the optimal amount of Anker_tot and AnkerProt_tot to
% achieve maximum amplitude?

if modus == 2
    % Variable parameters
    AnkerProt = (1:10:100)'; %[mu M]
    Anker = (1:10:100)'; %[mu M]

    % Combinations of different parameters
    for c = 1:4 % cheSpecies (CheR, CheB, CheY, CheZ)
    for b = 0:1 % cheSpeciesAttachedToPhyB
    for a = 1:3 % aspInput (Small, Medium, High)
    for m = 1:2 % chemotaxisModel (Spiro, Mello)

    wbh = waitbar(0, 'Start of evaluation');
    for k = 1:length(AnkerProt)
        for l = 1: length(Anker)
            iteration = sprintf('Iteration: C_%d-B_%d-A_%d-M_%d-AP_%d-A_%d', c, b, a, m, k, l);
            wbh = waitbar(((k-1)*length(AnkerProt)+l)/(length(AnkerProt)*length(Anker)), wbh, iteration);

            if c == 1
                cheSpecies = 'CheR';
            elseif c == 2
                cheSpecies = 'CheB';
            elseif c == 3
                cheSpecies = 'CheY';
            elseif c == 4
                cheSpecies = 'CheZ';
            end

            if a == 1
                asplevel = 'small';
            elseif a == 2
                asplevel = 'medium';
            elseif a == 3
                asplevel = 'high';
            end

            if m == 1
                chemotaxisModel = 'spiro';
            elseif m == 2
                chemotaxisModel = 'mello';
            end

            % Get aspartate concentration
            asp = aspConcentration(chemotaxisModel, asplevel);

            % Get parameter structure
            p = getParameters(chemotaxisModel);

            attachedToPhyBOrPIF3 = b;
            p.AnkerProt_tot = AnkerProt(k);
            p.Anker_tot = Anker(l);

            % Simulation
            [t_out, cheProteins, CheY, CheY_free, CheYp, CheYp_free] = simulation(t_span, p, chemotaxisModel, cheSpecies, attachedToPhyBOrPIF3, asp, rlfunc, frlfunc);

            A(k,l) = relative_amplitude(CheYp_free, t_out);
        end
    end
    close(wbh);

    % Plot figures
    h = figure();
    if b
        contourf(Anker,AnkerProt, A);
        colormap(bone);
        colorbar();
        tit = sprintf('Amplitude(AP:PIF3_{tot},anchor_{tot}) C_%d-B_%d-A_%d-M_%d', c, b, a, m);
        title(tit);
        xlabel('anchor_{tot} [\mu M]');
        ylabel('AP:PIF3_{tot} [\mu M]');
        zlabel('A []');
    else
        contourf(Anker,AnkerProt, A);
        colormap(bone);
        colorbar();
        tit = sprintf('Amplitude(AP:PhyB_{tot},anchor_{tot}) C_%d-B_%d-A_%d-M_%d', c, b, a, m);
        title(tit);
        xlabel('anchor_{tot} [\mu M]');
        ylabel('AP:PhyB_{tot} [\mu M]');
        zlabel('A []');
    end

    fig = sprintf('saveas(h,''Amplitude-C_%d-B_%d-A_%d-M_%d.fig'');', c, b, a, m);
    eval(fig);

    png = sprintf('saveas(h,''Amplitude-C_%d-B_%d-A_%d-M_%d.png'');', c, b, a, m);
    eval(png);

    close(h);

    mat = sprintf('save Amplitude-C_%d-B_%d-A_%d-M_%d.mat;', c, b, a, m);
    eval(mat);

    end
    end
    end
    end

    close all;
end

%% Question 3: Determine rate constant for RL/FRL activation?
if modus == 3
    for m = 1:2 % chemotaxisModel (Spiro, Mello)
        for c = 1:2 % lightConstant (RL, FRL)
            if m == 1
                chemotaxisModel = 'spiro';
            elseif m == 2
                chemotaxisModel = 'mello';
            end
            
            % Get aspartate concentration
            asp = aspConcentration(chemotaxisModel, asplevel);

            % Get parameter structure
            p = getParameters(chemotaxisModel);
            
            % Simulation
            [t_out, cheProteins, CheY, CheY_free, CheYp, CheYp_free] = simulation(t_span, p, chemotaxisModel, cheSpecies, attachedToPhyBOrPIF3, asp, rlfunc, frlfunc);
            
            A_max = absolute_amplitude(CheYp_free, t_out, c, rlt, frlt);
            A_th = [A_max(:,1)/(2^(1/2)), A_max(:,3), A_max(:,4)];

            tc = time_const(CheYp_free, A_th, t_out, c, rlt, frlt);
            
            if c == 1
                fprintf('The RL time constant predicted by the %s model is: %g\n', chemotaxisModel, tc(3));
            elseif c == 2
                fprintf('The FRL time constant predicted by the %s model is: %g\n', chemotaxisModel, tc(3));
            end
        end
    end
end

%% Analysis & Interworking algorithms
function asp = aspConcentration(chemotaxisModel, asplevel)
if strcmpi(asplevel, 'small')
	asp = 0; % [M]
elseif strcmpi(asplevel, 'medium')
	asp = 1e-6; % [M]
elseif strcmpi(asplevel, 'high')
	asp = 1e-3; % [M]
end

function p = getParameters(chemotaxisModel)
if strcmpi(chemotaxisModel, 'spiro')
    p = spiro1997_getParameters();
elseif strcmpi(chemotaxisModel, 'mello')
    p = mello2003_getParameters();
end

function [t_out, cheProteins, CheY, CheY_free, CheYp, CheYp_free] = simulation(t_span, p, chemotaxisModel, cheSpecies, attachedToPhyBOrPIF3, asp, rlfunc, frlfunc)
% Setup initial conditions
x0 = molecularModel('IC', chemotaxisModel, cheSpecies, attachedToPhyBOrPIF3, 'Asp', asp, 'p', p);

% Equilibrate model
[t_out, x_out] = ode15s(@molecularModel, t_span, x0, [], chemotaxisModel, cheSpecies, attachedToPhyBOrPIF3, 'Asp', asp, 'p', p); %#ok<ASGLU>
x0 = x_out(end, :)';

% Run experiment / main simulation
options = odeset('RelTol',1e-9,'MaxStep', 0.05); 
[t_out, x_out]=ode15s(@molecularModel, t_span, x0, options, chemotaxisModel, cheSpecies, attachedToPhyBOrPIF3, 'Asp', asp, 'p', p, 'RLfunc', rlfunc, 'FRLfunc', frlfunc);

[cheProteins, CheY, CheY_free, CheYp, CheYp_free] = concentrations(x_out, chemotaxisModel, attachedToPhyBOrPIF3);

function [cheProteins, CheY, CheY_free, CheYp, CheYp_free] = concentrations(x_out, chemotaxisModel, attachedToPhyBOrPIF3)
% Get the concentrations over time from simulation
if strcmpi(chemotaxisModel, 'spiro')
    n_spiro = 12;
    n_cheProts = 6;
    if attachedToPhyBOrPIF3
        n_cheProtsStates = 4;
        n_light = 3;
    else
        n_cheProtsStates = 3;
        n_light = 5;
    end

    cheProteins = reshape(x_out(:, n_spiro+n_light+1:end), size(x_out, 1), n_cheProts, n_cheProtsStates);
elseif strcmpi(chemotaxisModel, 'mello')
    n_mello = 15;
    n_cheProts = 6;
    if attachedToPhyBOrPIF3
        n_cheProtsStates = 4;
        n_light = 3;
    else
        n_cheProtsStates = 3;
        n_light = 5;
    end

    cheProteins = reshape(x_out(:, n_mello+n_light+1:end), size(x_out, 1), n_cheProts, n_cheProtsStates);
end

% Create free (=reactive) CheYp
CheY  = reshape(cheProteins(:, 4, :), size(cheProteins, 1), n_cheProtsStates);
CheY_free = sum(CheY(:, 1:end-1), 2);

CheYp = reshape(cheProteins(:, 5, :), size(cheProteins, 1), n_cheProtsStates);
CheYp_free = sum(CheYp(:, 1:end-1), 2);

function plotSimulation(t_out, cheProteins, CheY, CheY_free, CheYp, CheYp_free, attachedToPhyBOrPIF3, p)
% Plot total concentration over time of all Che protein species.
figure();
cheSpeciesNames = {'CheR', 'CheB', 'CheB_p', 'CheY', 'CheY_p', 'CheZ'};
lineSpec = getLineSpec();
for j = 1:size(cheProteins, 2)
    for i=1:size(cheProteins, 3)
        subplot(2, 3, j);
        plot(t_out, cheProteins(:, j, i), lineSpec{i});
        hold on;
    end
    if attachedToPhyBOrPIF3
        legend('Pr_{free}', 'Pfr_{free}', 'Pfr-PIF3_{free}', 'Pfr-PIF3_{bound}');
    else
        legend('PIF3_{free}', 'PhyB-PIF3_{free}', 'PhyB-PIF3_{bound}');
    end
    title(cheSpeciesNames{j});
    xlabel('time [s]');
    ylabel('concentration [\mu M]');
end

% Plot concentration over time of all Che protein species and different
% states.
figure();
lineSpec = getLineSpec();
sumUpSpecies = {1, ... CheR
    [2, 3], ... CheB_tot = CheB + CheBp
    [4, 5], ... CheY_tot = CheY + CheYp
    6}; % CheZ
sumUpSpeciesNames = {'CheR_{tot}', 'CheB_{tot}', 'CheY_{tot}', 'CheZ_{tot}'};
for j = 1:length(sumUpSpecies)
    for i=1:size(cheProteins, 3)
        subplot(2, 2, j);
        protConcentration = zeros(size(cheProteins, 1), 1);
        for k = 1:length(sumUpSpecies{j})
            protConcentration = protConcentration + cheProteins(:, sumUpSpecies{j}(k), i);
        end
        plot(t_out, protConcentration, lineSpec{i});
        hold on;
    end
    if attachedToPhyBOrPIF3
        legend('Pr_{free}', 'Pfr_{free}', 'Pfr-PIF3_{free}', 'Pfr-PIF3_{bound}');
    else
        legend('PIF3_{free}', 'PhyB-PIF3_{free}', 'PhyB-PIF3_{bound}');
    end
    title(sumUpSpeciesNames{j});
    xlabel('time [s]');
    ylabel('concentration [\mu M]');
end

% Plot the response of the system, e.g. CheY_free and CheYp_free
% concentrations over time.
figure();
lineSpec = getLineSpec();
plot(t_out, CheY_free, lineSpec{1});
hold on;
plot(t_out, CheYp_free, lineSpec{2});
legend('CheY_{free}', 'CheYp_{free}');
title(sprintf('Response of the system (AP=%g, anchor=%g)', p.AnkerProt_tot, p.Anker_tot));
xlabel('time [s]');
ylabel('concentration [\mu M]');
yLimLast = ylim();
ylim([0, yLimLast(2)]);
drawnow;

function y = smoothedStep(t, t_step,dt)
% Function smoothing a step change in light, to bypass integrator problems.
if t < t_step - dt/2
    y = 0;
elseif t > t_step + dt/2
    y = 1;
else
    y = (t- (t_step - dt/2)) / dt;
end

function lineSpec = getLineSpec( )
% lineSpec = getLineSpec( )
%
% Returns a large array of linespecs that can be used for plots with an
% huge amount of time-curves in it.

% Author:   Moritz Lang
%           ETH Zürich
%           Department of Biosystems Science and Engineering (D-BSSE)
%           Stelling Group
%           Mattenstrasse 26
%           4058 Basel, Switzerland
% Date:     2009-02-11

lineSpec = {'r';    'g';    'b';    'c';    'm';    'y';    'k';    ...
           % '-r';   '-g';   '-b';   '-c';   '-m';   '-y';   '-k';   ...
            '--r';  '--g';  '--b';  '--c';  '--m';  '--y';  '--k';  ...
            ':r';   ':g';   ':b';   ':c';   ':m';   ':y';   ':k';   ...
            '-.r';  '-.g';  '-.b';  '-.c';  '-.m';  '-.y';  '-.k'};

function A_max = relative_amplitude(CheYp_free, t_out)
startIdx = find(t_out>65, 1);
A_max = ( max(CheYp_free(startIdx:end)) - min(CheYp_free(startIdx:end)) ) / CheYp_free(1); % normalized amplitude
    
function A_max = absolute_amplitude(CheYp_free, t_out, c, rlt, frlt)
[max_Che_Yp, min_Che_Yp] = get_maxmin(CheYp_free, t_out, c, rlt, frlt);

A_Che_Yp = (max_Che_Yp(:,1) - min_Che_Yp(:,1));

if c == 1
    t_Che_Yp = max_Che_Yp(:,2) + round((min_Che_Yp(:,2) - max_Che_Yp(:,2)) / 2);
elseif c == 2
    t_Che_Yp = min_Che_Yp(:,2) + round((max_Che_Yp(:,2) - min_Che_Yp(:,2)) / 2);
end

A_max = sortrows([A_Che_Yp, t_Che_Yp, max_Che_Yp(:,2), min_Che_Yp(:,2)], -1);

if 0 % Create debug plot
    figure();
    lineSpec = getLineSpec();
    hold on;
    plot(t_out, CheYp_free, lineSpec{2});
    plot(t_out(max_Che_Yp(:,2)),max_Che_Yp(:,1),'r*',t_out(min_Che_Yp(:,2)),min_Che_Yp(:,1),'g*');
    for i=1:(length(t_Che_Yp))
        line([t_out(t_Che_Yp(i)); t_out(t_Che_Yp(i))],[(min_Che_Yp(i,1)); max_Che_Yp(i,1)]);
    end
    legend('CheYp_{free}');
    title('Amplitude of CheYp_{free}');
    xlabel('time [s]');
    ylabel('concentration [\mu M]');
    yLimLast = ylim();
    ylim([0, yLimLast(2)]);
end
    
function tc = time_const(CheYp_free, A_th, t_out, c, rlt, frlt)
% Determines the time constants of FRL and RL light pulses and creates
% plots of the CheYp concentration over time.

for j=1:length(A_th)
    % This loop selects the closest timepoint to the threshold
    % amplitude A_th.

    A_temp = [];
    t_temp = [];

    if c == 1 % RL
        for k=A_th(j,2):A_th(j,3)
            A_temp(end+1) = (CheYp_free(A_th(j,2)) - CheYp_free(k));
            t_temp(end+1) = k;
        end
        [~,ind] = min(abs(A_temp-A_th(j,1)));

        A(j) = A_temp(ind);
        tc(j) = t_out(t_temp(ind))-t_out(A_th(j,2));
    elseif c == 2 % FRL
        for k=A_th(j,3):A_th(j,2)
            A_temp(end+1) = (CheYp_free(k) - CheYp_free(A_th(j,3)));
            t_temp(end+1) = k;
        end
        [~,ind] = min(abs(A_temp-A_th(j,1)));

        A(j) = A_temp(ind);
        tc(j) = t_out(t_temp(ind))-t_out(A_th(j,3));
    end
end

if 1 % Create plots

    [max_Che_Yp, min_Che_Yp] = get_maxmin(CheYp_free, t_out, c, rlt, frlt);

    figure();
    lineSpec = getLineSpec();
    hold on;
    plot(t_out, CheYp_free, lineSpec{2});
    plot(t_out(max_Che_Yp(:,2)),max_Che_Yp(:,1),'r*',t_out(min_Che_Yp(:,2)),min_Che_Yp(:,1),'b*');

    if c == 1 % RL

        for i=1:(length(max_Che_Yp))
            line([t_out(max_Che_Yp(i,2)); t_out(max_Che_Yp(i,2))],[(min_Che_Yp(i,1)); max_Che_Yp(i,1)],'Color','b');
        end

        for i=1:(length(max_Che_Yp))
            line([t_out(max_Che_Yp(i,2)); t_out(min_Che_Yp(i,2))],[min_Che_Yp(i,1); min_Che_Yp(i,1)],'Color','b');
        end

        for i=1:(length(tc))
            line([t_out(max_Che_Yp(i,2)); t_out(max_Che_Yp(i,2))+tc(i)],[(max_Che_Yp(i,1)); (max_Che_Yp(i,1))],'Color','r');
        end

        for i=1:(length(tc))
            line([t_out(max_Che_Yp(i,2))+tc(i); t_out(max_Che_Yp(i,2))+tc(i)],[max_Che_Yp(i,1); max_Che_Yp(i,1)-A(i)],'Color','r');
        end

        title('Time constants of RL induction');

    elseif c == 2 % FRL

        for i=1:(length(max_Che_Yp))
            line([t_out(min_Che_Yp(i,2)); t_out(max_Che_Yp(i,2))],[(max_Che_Yp(i,1)); max_Che_Yp(i,1)],'Color','b');
        end

        for i=1:(length(max_Che_Yp))
            line([t_out(min_Che_Yp(i,2)); t_out(min_Che_Yp(i,2))],[min_Che_Yp(i,1); max_Che_Yp(i,1)],'Color','b');
        end

        for i=1:(length(tc))
            line([t_out(min_Che_Yp(i,2)); t_out(min_Che_Yp(i,2))+tc(i)],[(min_Che_Yp(i,1)); (min_Che_Yp(i,1))],'Color','r');
        end

        for i=1:(length(tc))
            line([t_out(min_Che_Yp(i,2))+tc(i); t_out(min_Che_Yp(i,2))+tc(i)],[min_Che_Yp(i,1); min_Che_Yp(i,1)+A(i)],'Color','r');
        end

        title('Time constants of FRL induction');
    end

        legend('CheYp_{free}','Amplitude_{max/sqrt(2)}','Amplitude_{max}');
        xlabel('time [s]');
        ylabel('concentration [\mu M]');
        yLimLast = ylim();
        ylim([0, yLimLast(2)]);
end

function [max_Che_Yp, min_Che_Yp] = get_maxmin(CheYp_free, t_out, c, rlt, frlt)
% This function removes manually all non-essential maxima / minima. It
% requires red light and far-red light times. It needs to be adapted after
% changes of the light pulse experimental setup.

max_Che_Yp = [];
min_Che_Yp = [];

for i=1:1:length(rlt)-1
    inds = find(t_out >= rlt(i) + 5 & t_out < rlt(i+1));
    startidx = inds(1);
    endidx = inds(end);
    [C,ind] = min(CheYp_free(startidx:endidx));
    min_Che_Yp(end+1,:) = [C,ind+startidx];
end
for j=1:1:length(frlt)-1
    inds = find(t_out >= frlt(j) & t_out < frlt(j+1));
    startidx = inds(1);
    endidx = inds(end);
    [C,ind] = max(CheYp_free(startidx:endidx));
    max_Che_Yp(end+1,:) = [C,ind+startidx];
end

if c == 1 % cRL: Remove last maximum
    max_Che_Yp(end,:) = [];
elseif c == 2 % cFRL: Remove first maximum.
    max_Che_Yp(1,:) = [];
end