% This file installs the Lemming Toolbox.

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

%% Configuration
toolBoxName = 'LemmingToolbox';
toolBoxPath = fullfile(matlabroot,['/toolbox/', toolBoxName]);
dummyImagesPath = fullfile(matlabroot,['/toolbox/', toolBoxName, '/dummyImages']);
extensionsToCopy = {'.mdl', '.m', '.fig', '.gif', '.jpg', '.tif'};

%% Installation
disp('Installing Lemming Toolbox,');
disp('by Moritz Lang and others of the 2010 ETH Zurich iGem team.');
disp('');
disp('If you have questions, please contact moritz.lang@bsse.ethz.ch.');
disp('-------------------------------------------');

numCopiedFiles = 0;
% Create toolbox folder
mkdir(toolBoxPath);
% Copy files
% Get all files
fileList = dir();
for i=1:length(fileList)
    % Check if file should be copied
    [pathstr, name, ext, versn] = fileparts(fileList(i).name);
    shouldBeCopied = false;
    for j = 1:length(extensionsToCopy)
        if strcmpi(ext, extensionsToCopy{j})
            shouldBeCopied = true;
            break;
        end
    end
    if ~shouldBeCopied
        continue;
    end
    
    % Copy file
    copyfile(fileList(i).name, fullfile(toolBoxPath, [name, ext]));
    disp(sprintf('Copied file %s ...', fileList(i).name));
    numCopiedFiles = numCopiedFiles + 1;
end

% Create dummyImages folder
mkdir(dummyImagesPath);
% Copy files
% Get all files
fileList = dir([cd, '/dummyImages']);
for i=1:length(fileList)
    % Check if file should be copied
    [pathstr, name, ext, versn] = fileparts(fileList(i).name);
    shouldBeCopied = false;
    for j = 1:length(extensionsToCopy)
        if strcmpi(ext, extensionsToCopy{j})
            shouldBeCopied = true;
            break;
        end
    end
    if ~shouldBeCopied
        continue;
    end
    
    % Copy file
    copyfile([cd, '/dummyImages/', fileList(i).name], fullfile(dummyImagesPath, [name, ext]));
    disp(sprintf('Copied file dummyImages/%s ...', fileList(i).name));
    numCopiedFiles = numCopiedFiles + 1;
end

%% Registration
% Add the toolbox to the path
disp('Adding toolbox to matlab path..');
addpath(genpath(toolBoxPath))
savepath;
disp('-------------------------------------------');
disp(sprintf('%g files copied.', numCopiedFiles));
disp('');
disp('Installation successfull.');
disp('Please restart Simulink if currently running.');