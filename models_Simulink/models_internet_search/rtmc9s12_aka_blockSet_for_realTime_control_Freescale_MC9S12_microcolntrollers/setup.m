% setup rtmc9s12-Target
% fw-01-09
function setup

%% ask whether this is going to be a read-only install
while 1

    answer = input('Is this going to be a read-only install? Y/[N]: ', 's');

    if strcmpi(answer, 'yes') || strcmpi(answer, 'y')

        ReadOnlyInstall = 1;
        break;

    elseif isempty(answer) || strcmpi(answer, 'no') || strcmpi(answer, 'n')

        ReadOnlyInstall = 0;
        break;

    end

end

%% set up mex compiler (if required)
while 1

    answer = input('Set up mex compiler Y/[N]: ', 's');

    if strcmpi(answer, 'yes') || strcmpi(answer, 'y')

        display('Setting up mex compiler. A safe option is Lcc...');
        mex -setup;
        break;

    elseif isempty(answer) || strcmpi(answer, 'no') || strcmpi(answer, 'n')

        % do nothing
        break;

    end

end


%% adjust MATLAB search path

% get installation path...
installationPath = fileparts(mfilename('fullpath'));

% issue a warning if there are blanks in the installation path
if strfind(installationPath, ' ')

    disp([char(10) ...
        'WARNING: ''setup.m'' is run from a installation path which includes space characters.' char(10) ...
        '         Depending on your system architecture, this may lead to problems. ' char(10) ...
        '         It is strongly recommended to install the toolbox on a space free path.' char(10)])
      
end


% attempt to remove previous installations from the MATLAB path by deleting
% any paths that contain *rtmc*
oldinstpath = regexp(path, '[:\\\/\w- ]*rtmc[:\\\/\w- ]*', 'match');
if ~isempty(oldinstpath)
    
    % remove old path entries
    cellfun(@rmpath, oldinstpath);
    
end

% ... keep things in order
rehash;

% add new path
addpath(...
    fullfile(installationPath, 'bin'), ...
    fullfile(installationPath, 'mc', 'blocks'), ...
    fullfile(installationPath, 'mc', 'core'), ...
    '-end');

% permanetly store adjusted path
savepath;


%% check if the system file 'ext_comm_mc9s12.mexw32' is up to date
binrtw         = dir(fullfile(installationPath, 'bin', 'ext_serial_mc9s12_comm.mexw32'));
orig_ext_comm  = dir(fullfile(installationPath, 'ml', 'rtw', 'ext_mode', 'ext_serial_mc9s12_comm.mexw32'));

% make sure 'ext_comm' isn't locked...
if (mislocked('ext_serial_mc9s12_comm'))
    munlock('ext_serial_mc9s12_comm');
end
clear mex;

if ~ReadOnlyInstall

    if ~isempty(binrtw)
        
        if(~strcmp(binrtw.date,orig_ext_comm.date))
            disp(['Copying file ' installationPath ...
                '/ml/rtw/ext_mode/ext_serial_mc9s12_comm.mexw32 to '...
                installationPath '/bin/ext_serial_mc9s12_comm.mexw32']);
            copyfile([installationPath '/ml/rtw/ext_mode/ext_serial_mc9s12_comm.mexw32'],...
                [installationPath '/bin/ext_serial_mc9s12_comm.mexw32']);
            copyfile([installationPath '/ml/rtw/ext_mode/ext_serial_mc9s12_comm_marker.txt'],...
                [installationPath '/bin/ext_serial_mc9s12_comm_marker.txt']);
        end
        
    else
        
        disp(['Copying file ' installationPath ...
            '/ml/rtw/ext_mode/ext_serial_mc9s12_comm.mexw32 to '...
            installationPath '/bin/ext_serial_mc9s12_comm.mexw32']);
        copyfile([installationPath '/ml/rtw/ext_mode/ext_serial_mc9s12_comm.mexw32'],...
            [installationPath '/bin/ext_serial_mc9s12_comm.mexw32']);
        copyfile([installationPath '/ml/rtw/ext_mode/ext_serial_mc9s12_comm_marker.txt'],...
            [installationPath '/bin/ext_serial_mc9s12_comm_marker.txt']);
        
    end
    
else
    
    % ReadOnlyInstall
    if ~isempty(binrtw)
        
        delete([installationPath '/bin/ext_serial_mc9s12_comm.mexw32']);
        delete([installationPath '/bin/ext_serial_mc9s12_comm_marker.txt']);
        
    end
    
end


%% adjust commands 'remex' and 'mc_build_exit' (ReadOnlyInstall or not)

if ReadOnlyInstall

    patchFileName = fullfile(installationPath, 'bin', 'remex.m');
    fid = fopen(patchFileName, 'r'); str = fread(fid); str = char(str.'); fclose(fid);
    str = regexprep(str, 'ReadOnlyInstall([ =01]*);', 'ReadOnlyInstall = 1;');
    fid = fopen(patchFileName, 'w'); fwrite(fid, str); fclose(fid);

    patchFileName = fullfile(installationPath, 'bin', 'mc_buildLibrariesActiveX.m');
    fid = fopen(patchFileName, 'r');str = fread(fid); str = char(str.'); fclose(fid);
    str = regexprep(str, 'ReadOnlyInstall([ =01]*);', 'ReadOnlyInstall = 1;');
    fid = fopen(patchFileName, 'w'); fwrite(fid,str); fclose(fid);

    patchFileName = fullfile(installationPath, 'bin', 'mc_buildLibrariesMake.m');
    fid = fopen(patchFileName, 'r');str = fread(fid); str = char(str.'); fclose(fid);
    str = regexprep(str, 'ReadOnlyInstall([ =01]*);', 'ReadOnlyInstall = 1;');
    fid = fopen(patchFileName, 'w'); fwrite(fid,str); fclose(fid);

else

    patchFileName = fullfile(installationPath, 'bin', 'remex.m');
    fid = fopen(patchFileName, 'r'); str = fread(fid); str = char(str.'); fclose(fid);
    str = regexprep(str, 'ReadOnlyInstall([ =01]*);', 'ReadOnlyInstall = 0;');
    fid = fopen(patchFileName, 'w'); fwrite(fid, str); fclose(fid);

    patchFileName = fullfile(installationPath, 'bin', 'mc_buildLibrariesActiveX.m');
    fid = fopen(patchFileName, 'r');str = fread(fid); str = char(str.'); fclose(fid);
    str = regexprep(str, 'ReadOnlyInstall([ =01]*);', 'ReadOnlyInstall = 0;');
    fid = fopen(patchFileName, 'w'); fwrite(fid,str); fclose(fid);

    patchFileName = fullfile(installationPath, 'bin', 'mc_buildLibrariesMake.m');
    fid = fopen(patchFileName, 'r');str = fread(fid); str = char(str.'); fclose(fid);
    str = regexprep(str, 'ReadOnlyInstall([ =01]*);', 'ReadOnlyInstall = 0;');
    fid = fopen(patchFileName, 'w'); fwrite(fid,str); fclose(fid);

end


%% determine information about all installed libraries
allLibrariesFile = fullfile(installationPath, 'bin', 'allLibrariesFile.mat');

% default: clear flag 'anyNewLibs' to block saving of 'allLibraries'
anyNewLibs = 0;

% has the library information ever been saved before?
if ~exist('allLibrariesFile.mat', 'file')
    
    % no -> construct 'mcLibraries'
    allLibraries = mcLibraries;
    
else
    
    % yes -> load
    kk = feval(@load, allLibrariesFile);
    allLibraries = kk.allLibraries;
    
end


%% if the RTW toolbox is installed -> enter RTW info in 'allLibraries'
rtwToolbox = ver('rtw');
if ~isempty(rtwToolbox) && isempty(allLibraries.rtwlib)
    
    % RTW has been installed -> construct 'mcLibraryEntry' object
    rtwlibInfo = mcLibraryEntry;
    
    % store name and version of the library
    rtwlibInfo.libName    = rtwToolbox.Name;
    rtwlibInfo.libVersion = rtwToolbox.Version;

    % set base path to the blocks of this library
    % 'n/a' as these are all regular simulink blocks
    rtwlibInfo.libBlocksPath  = 'n/a';

    % determine a list of 'S-Functions' in the blocks of this library
    % 'n/a' as the code is generated via TLC
    rtwlibInfo.libBlocks = 'n/a';

    % enter result in 'allLibraries'
    allLibraries.rtwlib = rtwlibInfo;

    % set flag 'anyNewLibs' to enforce save operation on 'allLibraries'
    anyNewLibs = 1;
    
end


%% if the DSP block set is installed -> compile catalogue of all DSP blocks
dspToolbox = ver('signal');
if ~isempty(dspToolbox) && isempty(allLibraries.dsplib)
    
    % DSP block set has been installed -> construct 'mcLibraryEntry' object
    dsplibInfo = mcLibraryEntry;
    
    % store name and version of the library
    dsplibInfo.libName    = dspToolbox.Name;
    dsplibInfo.libVersion = dspToolbox.Version;

    % set base path to the blocks of this library
    dsplibInfo.libBlocksPath  = fullfile(matlabroot, 'toolbox', 'dspblks', 'dspblks');

    % determine a list of 'S-Functions' in the blocks of this library
    disp(['Scanning library ' dsplibInfo.libName ' for S-Function blocks...'])
    dsplibInfo.libBlocks = getAllBlocks(dsplibInfo.libBlocksPath);
    disp('... done.')
    
    % enter result in 'allLibraries'
    allLibraries.dsplib = dsplibInfo;

    % set flag 'anyNewLibs' to enforce save operation on 'allLibraries'
    anyNewLibs = 1;
    
end


%% store central library info file
if anyNewLibs
    
    % something's been changed -> store
    feval(@save, allLibrariesFile, 'allLibraries');
    
end


%% adjust marker files
i_adjustLibMarkerFiles(installationPath);


%% set build path information in Metrowerks CodeWarrior projects (xml based templates, fw-01-09)
templateCWproject     = 'templateCWproject.xml';
lib_templateCWproject = 'lib_templateCWproject.xml';


% all XML templates are stored here...
templatePath = fullfile(installationPath, 'bin', 'templates');

% -----------------------------------------------------------------
% install template project file
% -----------------------------------------------------------------
lhd = fopen(fullfile(templatePath, [templateCWproject '.template']), 'r');
proj = fscanf(lhd, '%c');
fclose(lhd);

% substitute path tokens
proj = strrep(proj, 'RTMC9S12_CW_R14__MC__CORE',                      [installationPath '\mc\core']);
proj = strrep(proj, 'RTMC9S12_CW_R14__RTW__C__SRC',                   [installationPath '\ml\rtw\c\src']);
proj = strrep(proj, 'RTMC9S12_CW_R14__EXTERN__INCLUDE',               [installationPath '\ml\extern\include']);
proj = strrep(proj, 'RTMC9S12_CW_R14__RTWLIB',                        [installationPath '\rtwlib']);
proj = strrep(proj, 'MATLAB__SIMULINK__INCLUDE',                      [matlabroot       '\simulink\include']);
proj = strrep(proj, 'MATLAB__RTW__C__SRC__MATRIXMATH',                [matlabroot       '\rtw\c\src\matrixmath']);
proj = strrep(proj, 'MATLAB__TOOLBOX__DSPBLKS__INCLUDE',              [matlabroot       '\toolbox\dspblks\include']);

% store modified project file
lhd = fopen(fullfile(templatePath, templateCWproject), 'wb');
fwrite(lhd, proj);
fclose(lhd);
disp(['Writing adjusted project file ' templateCWproject]);


% -----------------------------------------------------------------
% install library template project files
% -----------------------------------------------------------------
lhd = fopen(fullfile(templatePath, [lib_templateCWproject '.template']), 'r');
proj = fscanf(lhd, '%c');
fclose(lhd);

% substitute path tokens
proj = strrep(proj, 'RTMC9S12_CW_R14__MC__CORE',                      [installationPath '\mc\core']);
proj = strrep(proj, 'RTMC9S12_CW_R14__RTW__C__SRC',                   [installationPath '\ml\rtw\c\src']);
proj = strrep(proj, 'RTMC9S12_CW_R14__EXTERN__INCLUDE',               [installationPath '\ml\extern\include']);
proj = strrep(proj, 'MATLAB__SIMULINK__INCLUDE',                      [matlabroot       '\simulink\include']);
proj = strrep(proj, 'MATLAB__TOOLBOX__DSPBLKS__INCLUDE',              [matlabroot       '\toolbox\dspblks\include']);

% store modified project file
lhd = fopen(fullfile(templatePath, lib_templateCWproject), 'wb');
fwrite(lhd, proj);
fclose(lhd);
disp(['Writing adjusted library project file ' lib_templateCWproject]);




%% local functions




%% ======================================================================
function i_adjustLibMarkerFiles(installpath)

% this is where we expect the marker files to be checked...
libPath = fullfile(installpath, 'rtwlib');

% does '...\rtwlib' already exist?
if ~exist(libPath, 'dir')
    
    % nope -> create directory '...\rtwlib'
    mkdir(libPath);
    
    % no markers -> we're already done checking...
    return
    
end

% check marker files
allMarkers = dir(fullfile(libPath, '*_marker.mat'));

% adjust all marker files
for ii = 1:length(allMarkers)
    
    % read next marker file
    libObj = i_readLibMarkerFile(fullfile(libPath, allMarkers(ii).name));

    % adjust marker file
    sourcePath = libObj.sourcePath;
    libObj.sourcePath  = fullfile(matlabroot, sourcePath(min(findstr(sourcePath, 'rtw')):end));
    libObj.buildPath   = fullfile(installpath, 'rtwlib', 'rtwlibbuild');
    libObj.storagePath = fullfile(installpath, 'rtwlib');
    
    % store adjusted marker
    i_writeLibMarkerFile(libObj);
    
end  % for


%% ======================================================================
% Generate library marker file in the local directory. This marker file
% includes all relevant target preferences. Any changes in these settings
% result in a rebuild of the corresponding library file.
function i_writeLibMarkerFile(libObj)

try
    
    % store libObj as '*.mat' file
    feval(@save, fullfile(libObj.storagePath, [regexprep(libObj.libraryName, '(.lib)$', '') '_marker.mat']), 'libObj');
    
catch %#ok<*CTCH>

    error('Unable to generate rtwlib markerfile in \rtwlib directory');

end


%% ======================================================================
function myLibMarker = i_readLibMarkerFile(libMarkerFile)

% load libObj from specified '*.mat' file (library marker file)
kk = feval(@load, libMarkerFile);
myLibMarker = kk.libObj;


%% ======================================================================
% find all S-Function blocks of a library
function allBlocks = getAllBlocks(libBlocksPath)

% deterine all 'mdl' files
fileList = dir(fullfile(libBlocksPath, '*.mdl'));
mdlFileList  = { fileList.name };

allBlocks = {};

% loop over all mdl-files
for ii = 1:length(mdlFileList)
    
    % open file (in the background) and fetch all blocks
    mySys = load_system(mdlFileList{ii});
    
    % find all S-Function blocks
    currSFcnBlocks = find_system(mySys, 'FindAll', 'on', 'BlockType', 'S-Function');
    
    % loop over all S-Function blocks in the mdl-file
    for jj = 1:length(currSFcnBlocks)
        
        % fetch MaskType of current block
        currSFcnName = get_param(currSFcnBlocks(jj), 'FunctionName');
        
        if ~isempty(currSFcnName)
            
            % valid mask type -> store in list
            allBlocks{end + 1} = currSFcnName; %#ok<*AGROW>
            
        end
        
    end
    
    % close current mdl-file
    close_system(mySys)
    
end

% return ordered list of S-Function names
allBlocks = sort(allBlocks);
