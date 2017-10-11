% build libraries -- provided any of the libs needs rebuilding. The latter 
% is established by comparing the libraryMarkerFile to the current settings
% of the project. Any discrepancy (memory model, etc.) lead to the 
% rebuilding of the library.
%
% This function is used in conjunction with 'CodeWarrior' and an
% 'ActiveX'-based build process.
function mc_buildLibrariesActiveX

global mcBuildPars;


% The value of 'ReadOnlyInstall' is adjusted by the 'setup' script. Do not
% modify the following line.
ReadOnlyInstall = 0;


% check if the libraries need recompiled
%
% only build libraries in non read only environments. In read
% only environments (classroom) the libs should be downloaded
% and installed by the system administrator.
if ~ReadOnlyInstall

    % determine libs to be built (if present)
    allLibrariesFile = fullfile(mcBuildPars.mcBaseDir, 'bin', 'allLibrariesFile.mat');

    if exist('allLibrariesFile.mat', 'file')

        % library information already available -> load
        kk = feval(@load, allLibrariesFile);
        allLibraries = kk.allLibraries;

    else

        % should not happen...
        error(['File ' allLibrariesFile ' not found -> run ''setup'' again.']);

    end

    % library names (eg. 'rtwlib', 'dsplib', etc.)
    allLibNames = setdiff(fieldnames(allLibraries), 'genBC');

    % loop through all libraries
    for ii = 1:length(allLibNames)

        % currently working on library...
        currLib = allLibNames{ii};

        % build library, if possible/required
        if ~isempty(allLibraries.(currLib))
            
            % toolbox installed -> build lib
            i_buildLibrary(currLib);
            
        end

    end

end




%% local functions




%% ======================================================================
function i_buildLibrary(currLib)

global mcBuildPars;


% set the temporary build directory -- avoid spaces in path names as this
% throws off the CodeWarrior librarian
if any(mcBuildPars.mcBaseDir == ' ') && ~isempty(ver('rtw'))

    % eliminate space characters using the 8.3 notation
    % build diretory: <mcBaseDir>\rtwlib\rtwlibbuild
    libGenPath = RTW.transformPaths(fullfile(mcBuildPars.mcBaseDir, 'rtwlib', 'rtwlibbuild'));

elseif any(mcBuildPars.mcBaseDir == ' ')

    % RTW not installed -> eliminate space characters by building into 
    % 'C:\rtwlibbuild'
    libGenPath = 'C:\rtwlibbuild';
    if ~exist(libGenPath, 'dir')
        
        try
            
            % directory does not yet exist -> create
            mkdir(libGenPath);
            
        catch ME
            
            % where did it all go wrong?!
            mc_errorMsgAndExit(mfilename, ME);
            
        end
        
    end

else
    
    % either there's no RTW or the installation path is space free -> use
    % build diretory: <mcBaseDir>\rtwlib\rtwlibbuild
    
    % ensure folder '...\rtwlib' exists
    libGenPath = fullfile(mcBuildPars.mcBaseDir, 'rtwlib');
    
    % does folder '...\rtwlib' exist?
    if ~exist(libGenPath, 'dir')
        
        % no -> create folder ...\rtwlib
        mkdir(libGenPath);
        
    end
    
    % ensure folder '...\rtwlib\rtwlibbuild' exists
    libGenPath = fullfile(libGenPath, 'rtwlibbuild');
    
    % does folder '...\rtwlib\rtwlibbuild' exist?
    if ~exist(libGenPath, 'dir')
        
        % no -> create folder ...\rtwlib\rtwlibbuild
        mkdir(libGenPath);
        
    end

end


%% make HW include file available during the building of the libraries

% lib storage path
hwDefsLibBuildPath = fullfile(mcBuildPars.mcBaseDir, 'rtwlib', 'rtwlibbuild');

% copy header file
disp(['### Copying local HW header file to ' hwDefsLibBuildPath]);
system([...
    'copy ' ...
    fullfile(pwd, 'mc_hw_defines.h'), ' ', ...
    fullfile(hwDefsLibBuildPath, 'mc_hw_defines.h') ...
    ]);
    


%% change to the temporary build directory of the library
currDir = pwd;
cd(libGenPath);

% construct library marker object
%
%          libraryName : 
%           sourcePath : 
%            buildPath : 
%          storagePath : 
%     libSourceModules : 
%        codeGenerator : 
%
libObj = mcLibraryMarker;

% populate library marker object
libObj.buildPath   = fullfile(mcBuildPars.mcBaseDir, 'rtwlib', 'rtwlibbuild');
libObj.storagePath = fullfile(mcBuildPars.mcBaseDir, 'rtwlib');

% establish library name - depends on the chosen memory model
if strcmp(mcBuildPars.resources.MemModel, 'Flash_flat')

    % flat memory model
    libProjectName = [currLib '_flat'];

else

    % banked memory model
    libProjectName = [currLib '_banked'];

end


% From "PurelyIntegerCode" flag, determine which rtwlib is needed.
rtwOptsStr = get_param(gcs, 'RTWoptions');
purelyIntegerCode = regexp(rtwOptsStr, 'PurelyIntegerCode=(\d)', 'tokens', 'once');
purelyIntegerCode = str2double(purelyIntegerCode{:});

if purelyIntegerCode

    libObj.libraryName = [libProjectName '_int.lib'];

else

    libObj.libraryName = [libProjectName '.lib'];

end

% determine codeGenerator
isRTW = ver('rtw');
isTL  = ver('TL');
if ~isempty(isRTW)
    
    % using RTW
    libObj.codeGenerator = [isRTW.Name ' -- ' isRTW.Version];
    
elseif ~isempty(isTL)
    
    % using TargetLink
    libObj.codeGenerator = [isTL.Name ' -- ' isTL.Version];
    
else

    % unknown code generator
    error('Unknown code generator.')
    
end


% check if the library can be retrieved from its storage location or if it
% needs to be rebuilt
rtwlibNeedsRebuild = i_checkLibrary(libObj);

if rtwlibNeedsRebuild

    % rebuild library

    % assemble a list of source code files for this library
    libraryBaseName = regexprep(libObj.libraryName, '_\w+\.lib', '');
    switch libraryBaseName

        case 'rtwlib'
            
            % RTW main lib
            libObj.sourcePath = fullfile(matlabroot, 'rtw', 'c', 'src', 'matrixmath');

        case 'dsplib'
            
            % DSP blockset
            libObj.sourcePath = fullfile(matlabroot, 'toolbox', 'rtw', 'dspblks', 'c');
            
        otherwise
            
            % unknown library
            error(['Unknown library: ' libraryBaseName])

    end  % switch
    
    % determine all required source files and add them to the library
    % project file (XML)
    libProjectPathAndXML = i_genLibProject(libObj);

    % extract library name
    libNameNoExt = regexprep(libObj.libraryName, '(.lib)$', '');
    
    % some feedback...
    disp(['### Building library: ' libNameNoExt])
    disp(['### Library project file: ' libProjectPathAndXML])

    % build CodeWarrior project, store imported project as '<libname>.mcp'
    [errorMsgs, warningMsgs] = mc_cwAutomation(libProjectPathAndXML, 'build', [libNameNoExt '.mcp']);

    % close CW
    pause(2);
    mc_cwAutomation(libProjectPathAndXML, 'kill');
    
    % build errors?
    if ~isempty(errorMsgs)
    
        % errors
        
        disp(['### Encountered problems while building library: ' libNameNoExt])
        disp('### Library build erros:')
        
        % display all errors
        disp('--------------------------------------------------------------------')
        for ii = 1:length(errorMsgs)
        
            disp(errorMsgs{ii})
            disp('--------------------------------------------------------------------')
            
        end
        
    else
    
        % success

        % move library file to persistant storage location
        system(['copy ' ...
            '"' fullfile(libObj.buildPath,   libObj.libraryName) '" ', ...
            '"' fullfile(libObj.storagePath, libObj.libraryName) '"']);

        % move library marker file to persistant storage location
        libMarkerFile = [libNameNoExt '_marker.mat'];
        system(['copy ' ...
            '"' fullfile(libObj.buildPath,   libMarkerFile) '" ', ...
            '"' fullfile(libObj.storagePath, libMarkerFile) '"']);
            
    end
    
    % keep things tidy...
    system(['del /s /q "'   fullfile(libObj.buildPath, 'c"')]);
    system(['del /s /q "'   fullfile(libObj.buildPath, 'mc_hw_defines.h"')]);
    system(['del /s /q "'   fullfile(libObj.buildPath, [libNameNoExt '_Data"'])]);
    system(['rmdir /s /q "' fullfile(libObj.buildPath, [libNameNoExt '_Data"'])]);
    system(['del /s /q "'   fullfile(libObj.buildPath, [libNameNoExt '.mcp"'])]);
    system(['del /s /q "'   fullfile(libObj.buildPath, [libNameNoExt '.lib"'])]);
    system(['del /s /q "'   fullfile(libObj.buildPath, [libNameNoExt '.lst"'])]);
    system(['del /s /q "'   fullfile(libObj.buildPath, ['lib_' libNameNoExt '.mcp.xml"'])]);
    system(['del /s /q "'   fullfile(libObj.buildPath, [libNameNoExt '_marker.mat"'])]);

end  % rtwlibNeedsRebuilt

% restore folder
cd(currDir);


%% ======================================================================
function rtwlibNeedsRebuild = i_checkLibrary(libObj)

% Assume it is not necessary to rebuild
rtwlibNeedsRebuild = 0;

% name of the library marker file
libMarkerFile = [regexprep(libObj.libraryName, '(.lib)$', '') '_marker.mat'];

% Dialog setting "StaticLibraryRebuild" can be used to force the rebuilding
% of the library
rtwOptsStr = get_param(gcs, 'RTWoptions');
staticLibFlag = regexp(rtwOptsStr, 'StaticLibraryRebuild=(\d)', 'tokens', 'once');
staticLibFlag = str2double(staticLibFlag{:});

if staticLibFlag

    % force rebuilding of the libarary
    rtwlibNeedsRebuild = 1;

elseif ~exist(libObj.storagePath, 'dir')

    % storage directory does not exist -> need to rebuild
    rtwlibNeedsRebuild = 1;
    
    % attempt to make storage directory
    try
        
        system(['mkdir "', libObj.storagePath '"']);
        
    catch ME
        
        % display error message
        mc_errorMsgNoExit(ME);
        
        % additional warning
        disp(['### Warning. Cannot create directory ' libObj.storagePath  ...
            ' for persistent storage of rtw library.']);
        
    end

elseif ~exist(fullfile(libObj.storagePath, libObj.libraryName), 'file')

    % library not found -> need to rebuild
    rtwlibNeedsRebuild = 1;

elseif ~exist(fullfile(libObj.storagePath, libMarkerFile), 'file')

    % marker file not found -> undetermined status of library -> rebuild
    rtwlibNeedsRebuild = 1;

else
    
    % everything seems to be in place -> check marker file
    storedMarker = i_readLibMarkerFile(fullfile(libObj.storagePath, libMarkerFile));

    % ignore source path and source modules in marker test
    storedMarker.sourcePath = '';
    storedMarker.libSourceModules = '';
    
    if storedMarker ~= libObj
        
        % marker does not match current settings -> rebuild
        rtwlibNeedsRebuild = 1;
        
    end

end

% feedback...
if ~rtwlibNeedsRebuild

    disp(['### Reusing stored rtw library file ' fullfile(libObj.storagePath, libObj.libraryName)]);

else
    
    disp(['### Rebuilding library ' libObj.libraryName]);
    
end


%% =========================================================================
% Generate library marker file in the local directory. This marker file
% includes all relevant target preferences. Any changes in these settings
% result in a rebuild of the corresponding library file.
function i_writeLibMarkerFile(libObj)

try
    
    % store libObj as '*.mat' file
    feval(@save, [regexprep(libObj.libraryName, '(.lib)$', '') '_marker.mat'], 'libObj');
    
catch ME
    
    % display last error (command line)
    mc_errorMsgNoExit(ME);

    % exit
    error('Unable to generate rtwlib markerfile in \source directory');

end


%% =========================================================================
function myLibMarker = i_readLibMarkerFile(libMarkerFile)

% load libObj from specified '*.mat' file (library marker file)
kk = feval(@load, libMarkerFile);
myLibMarker = kk.libObj;


%% ======================================================================
function libProjectPathAndXML = i_genLibProject(libObj)

global mcBuildPars;

% all source files need to be copied to the rtwlib/c folder of the toolbox
buildPath = fullfile(libObj.buildPath, 'c');

% ensure that the required destination file structure is in place...
if ~exist(buildPath, 'dir')
    
    % build directory doesn't exist... create it
    mkdir(buildPath);
    
end

% copy library source files...
i_copyAllFiles(libObj.sourcePath, buildPath, '.c');

% copy common header file "rt_matrixlib.h"
cpyCmd = ['copy ' fullfile(libObj.sourcePath, 'rt_matrixlib.h') ' ' buildPath];
system(cpyCmd);

% assemble a list of all modules in this library
allSources  = i_getListOfModules(libObj.sourcePath);

% include source modules in the current library marker
libObj.libSourceModules = allSources;

% create library marker file with all current settings
i_writeLibMarkerFile(libObj);


% assemble library project file (XML)
myFileList           = {};
myLinkOrder          = {};
myGroupListSOURCES   = {};

% target name
libNameNoExt = regexprep(libObj.libraryName, '\.lib', '');

% XML path and filename
xmlName = ['lib_' libNameNoExt '.mcp.xml'];
templateLibProjectPathAndXML = fullfile(mcBuildPars.mcBaseDir, 'bin', 'templates', 'lib_templateCWproject.xml');
libProjectPathAndXML         = fullfile(libObj.buildPath, xmlName);

% copy template to build directory
system(['copy ' ...
    '"' templateLibProjectPathAndXML '" ', ...
    '"' libProjectPathAndXML '"']);
    

% deterine memory model option ('-Mb' or '')
myMemModel = char(regexp(mcBuildPars.resources.MemModel, 'Flash_(\w+)', 'tokens', 'once'));
if strcmpi(myMemModel, 'banked')
    
    % banked memory model -> '-Mb'
    myMemModelOpt = '-Mb';
    
else
    
    % flat memory model -> ''
    myMemModelOpt = '';

end


% for each source file, add an entry to the project XML
for ii = 1:length(allSources)
    
    % feedback
    disp(['Adding source file ' allSources{ii}])
    
    % add FILELIST entry
    myFileList = i_addFilelistEntry(myFileList, allSources{ii});

    % add LINKORDER entry
    myLinkOrder = i_addLinkOrderEntry(myLinkOrder, allSources{ii});

    % add GROUPLIST entry
    myGroupListSOURCES = i_addGroupListEntry(myGroupListSOURCES, libNameNoExt, allSources{ii});
    
end  % allSources


% open library project XML
proj = textread(libProjectPathAndXML, '%s', 'delimiter', '\n', 'whitespace', '');

% find all relevant tags
FILELISTtag       = find(~strcmp(regexp(proj, '<FILELIST>', 'match', 'once'), ''));
LINKORDERtag      = find(~strcmp(regexp(proj, '<LINKORDER>', 'match', 'once'), ''));
GROUPSOURCEStag   = find(~strcmp(regexp(proj, '<GROUP><NAME>Sources', 'match', 'once'), ''));

% assemble...
projOut = proj(1:FILELISTtag);
projOut = [projOut; myFileList(:)];
projOut = [projOut; proj(FILELISTtag+1:LINKORDERtag)];
projOut = [projOut; myLinkOrder(:)];
projOut = [projOut; proj(LINKORDERtag+1:GROUPSOURCEStag)];
projOut = [projOut; myGroupListSOURCES(:)];
projOut = [projOut; proj(GROUPSOURCEStag+1:end)];

% replace token 'LIBRARY__MEMMOD__TARGET' by target name
projOut = strrep(projOut, 'LIBRARY__MEMMOD__TARGET', libNameNoExt);

% replace token 'RTW__BANKED__FLAT__OPTION' by '-Mb' (banked) or '' (flat)
projOut = strrep(projOut, 'RTW__BANKED__FLAT__OPTION', myMemModelOpt);


% save adjusted project file (XML)
fid = fopen(libProjectPathAndXML, 'w');

% loop over all lines of the XML
for ii = 1:length(projOut)
    
    % write next line...
    fprintf(fid, '%s\r\n', char(projOut(ii)));
    
end

fclose(fid);



%% ========================================================================
% i_copyAllFiles copies all source code files with the specified extension
% from the specified srcDir (with sub-folders) to the common dstDir
%
% fw-08-07
function i_copyAllFiles(srcDir, dstDir, ext)

allFiles = dir(srcDir);

% switch to library folder
currDir = pwd;
cd(srcDir);

len = length(ext);
for ii = 1:length(allFiles)
    
    if ~allFiles(ii).isdir
        
        if strcmp(allFiles(ii).name(end+1-len:end), ext)
            
            if isempty(dir(fullfile(dstDir, allFiles(ii).name)))
                
                % file not already at destination... -> copy
                system(['copy "' allFiles(ii).name '" "' dstDir '"']);
                
            end
            
        end
        
    elseif ~(strcmp(allFiles(ii).name, '.') || strcmp(allFiles(ii).name, '..'))
        
        % check sub-folder
        cd(allFiles(ii).name)
        subDirFiles = dir(fullfile(pwd, ['*' ext]));     % e.g. '*.c'
        
        if ~isempty(subDirFiles)
            
            for jj = 1:length(subDirFiles)
                
                if isempty(dir(fullfile(dstDir, subDirFiles(jj).name)))
                    
                    % file not already at destination... -> copy
                    system(['copy "' subDirFiles(jj).name '" "' dstDir '"']);
                    
                end
                
            end  % for
            
        end

        % go back up one level...
        cd(srcDir);
        
    end
    
end  % for

% back to where we came from...
cd(currDir);



%% ======================================================================
% useful?  ->  might be obsolete (fw-01-09)
% -> essentially a call to 'i_getModuleNames'
function modules = i_getListOfModules(sourcePath)

global mcBuildPars;

% determine current system
currSystem = gcs;

if ~isempty(currSystem)
    
    % determine what kind of library we're building...
    mcBuildPars.codeGenerator.buildArgs = get_param(currSystem, 'RTWBuildArgs');
    mdlRefSimTarget = get_param(currSystem, 'ModelReferenceTargetType');

    % set flags (see below)
    bInteger = ~isempty(findstr(mcBuildPars.codeGenerator.buildArgs, 'INTEGER_CODE=1'));
    bRtwSfcn = ~isempty(findstr(mcBuildPars.codeGenerator.buildOpts.sysTargetFile, 'rtwsfcn')) || ...
               ~isempty(findstr(mcBuildPars.codeGenerator.buildOpts.sysTargetFile, 'accel')) || ...
                strcmpi(mdlRefSimTarget, 'SIM');

    % building an RTW S-Function or accelerator?
    if ~bRtwSfcn
        
        % maybe -> determine simulation mode and status
        simMode = get_param(currSystem, 'SimulationMode');
        simStat = get_param(currSystem, 'SimulationStatus');
        
        % accelerator?
        bRtwSfcn = strcmp(simStat, 'initializing') && strcmp(simMode, 'accelerator');
        
        if bRtwSfcn
            
            % yep -> feedback
            disp('### Accelerator got you ;-)');
        
        end
        
    end
    
    
    % building a library for the toolbox...
    % ... this is the typical use case of this function
    if bInteger
        
        % fixed point library
        
        % TODO  fw-01-09
        % TODO  fw-01-09
        % TODO  fw-01-09
        
        % don't know which blocks are integer only -> include'em all
        error([mfilename ': Fixed-point currently not supported'])
        
    else
        
        % normal (floating-point) library
        modules = i_getModuleNames(sourcePath, '.c');

        % accelerator?
        if ~bRtwSfcn
            
            % Accelerator/S-function use rt_tdelayacc which requires 
            % utMalloc -> exclude
            modules = modules(~strcmp(modules, 'rt_tdelayacc'));
            
        end
        
    end
    
else
    
    % no model open... should not be
    error([mfilename ': Could not determine current model.'])
    
end



%% ======================================================================
function fileList = i_getModuleNames(fileLocation, ext)

allFiles = dir(fileLocation);
nAllFiles = length(allFiles);

fileList = {};

% switch to library folder
currDir = pwd;
cd(fileLocation);

len = length(ext);
for ii = 1:nAllFiles
    
    % folder or file?
    if ~allFiles(ii).isdir
        
        % file -> correct file extension?
        if strcmp(allFiles(ii).name(end+1-len:end), ext)
            
            % yes -> append to list
            fileList{end + 1} = allFiles(ii).name; %#ok<AGROW>
            
        end
        
    elseif strcmp(allFiles(ii).name, '.') || strcmp(allFiles(ii).name, '..')
        
        % default folders -> ignore
        continue
        
    else
        
        % proper sub-folder -> explore...
        cd(allFiles(ii).name);
        
        subDirFiles = dir(pwd);
        for jj = 1:length(subDirFiles)
            
            % file or folder?
            if ~subDirFiles(jj).isdir
                
                % file -> correct file extension?
                if strcmp(subDirFiles(jj).name(end+1-len:end), ext)
                    
                    % yes -> append to list
                    fileList{end + 1} = subDirFiles(jj).name; %#ok<AGROW>

                end
                
            elseif strcmp(subDirFiles(jj).name, '.') || strcmp(subDirFiles(jj).name, '..')

                % default folders -> ignore
                continue

            else

                % currently only allowing one level of subDirs
                disp('### WARNING: Currently only one level of sub-directories allowed...')

            end

        end  % for
        
        % go back up...
        cd(fileLocation);
        
    end
    
end  % for

% restore original directory
cd(currDir);


%% =========================================================================
function myFileList = i_addFilelistEntry(myFileList, myFile)

myFileList{end + 1} =  '                <FILE>';
myFileList{end + 1} =  '                    <PATHTYPE>Name</PATHTYPE>';
myFileList{end + 1} = ['                    <PATH>' myFile '</PATH>'];
myFileList{end + 1} =  '                    <PATHFORMAT>Windows</PATHFORMAT>';
myFileList{end + 1} =  '                    <FILEKIND>Text</FILEKIND>';
myFileList{end + 1} =  '                    <FILEFLAGS>Debug</FILEFLAGS>';
myFileList{end + 1} =  '                </FILE>';


%% =========================================================================
function myLinkOrder = i_addLinkOrderEntry(myLinkOrder, myFile)

myLinkOrder{end + 1} =  '                <FILEREF>';
myLinkOrder{end + 1} =  '                    <PATHTYPE>Name</PATHTYPE>';
myLinkOrder{end + 1} = ['                    <PATH>' myFile '</PATH>'];
myLinkOrder{end + 1} =  '                    <PATHFORMAT>Windows</PATHFORMAT>';
myLinkOrder{end + 1} =  '                </FILEREF>';


%% =========================================================================
function myGroupList = i_addGroupListEntry(myGroupList, myTarget, myFile)

myGroupList{end + 1} =  '                <FILEREF>';
myGroupList{end + 1} = ['                    <TARGETNAME>' myTarget '</TARGETNAME>'];
myGroupList{end + 1} =  '                    <PATHTYPE>Name</PATHTYPE>';
myGroupList{end + 1} = ['                    <PATH>' myFile '</PATH>'];
myGroupList{end + 1} =  '                    <PATHFORMAT>Windows</PATHFORMAT>';
myGroupList{end + 1} =  '                </FILEREF>';


