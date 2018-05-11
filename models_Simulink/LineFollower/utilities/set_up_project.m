function set_up_project()
%set_up_project  Configure the environment for this project
%
%   Set up the environment for the current project. This function is set to
%   Run at Startup.

%   Copyright 2011-2014 The MathWorks, Inc.

% Use Simulink Project API to get the current project:
project = simulinkproject;
projectRoot = project.RootFolder;

% Set the location of slprj to be the "work" folder of the current project:

% Simulink creates simulation targets in the slprj subfolder of the working
% folder. If slprj does not exist, Simulink creates it.
myCacheFolder = fullfile(projectRoot, 'work');
if ~exist(myCacheFolder, 'dir')
    mkdir(myCacheFolder)
end
Simulink.fileGenControl('set', 'CacheFolder', myCacheFolder, ...
   'CodeGenFolder', myCacheFolder);

% Change working folder to the "work" folder:
cd(myCacheFolder);

assignin('base', 'track_1', importdata('track-1.png'));
assignin('base', 'track_2', importdata('track-2.png'));
assignin('base', 'track_2b', importdata('track-2b.png'));
assignin('base', 'track_3', importdata('track-3.png'));


alpha = linspace(0, 2*pi, 21)';
robotRadiusMM = 340/2;
assignin('base', 'contour_robot', [cos(alpha) * robotRadiusMM, sin(alpha) * robotRadiusMM]);


bumperRadiusMM = robotRadiusMM + 10;

alpha = linspace(1/6*pi, 1/2*pi, 6)';
assignin('base', 'contour_bumperL', [cos(alpha) * bumperRadiusMM, sin(alpha) * bumperRadiusMM]);

alpha = linspace(-1/6*pi, 1/6*pi, 6)';
assignin('base', 'contour_bumperM', [cos(alpha) * bumperRadiusMM, sin(alpha) * bumperRadiusMM]);

alpha = linspace(-1/6*pi, -1/2*pi, 6)';
assignin('base', 'contour_bumperR', [cos(alpha) * bumperRadiusMM, sin(alpha) * bumperRadiusMM]);


assignin('base', 'contour_obstacle', [-20 -80; 20 -80; 20 80; -20 80; -20 -80]);

end

