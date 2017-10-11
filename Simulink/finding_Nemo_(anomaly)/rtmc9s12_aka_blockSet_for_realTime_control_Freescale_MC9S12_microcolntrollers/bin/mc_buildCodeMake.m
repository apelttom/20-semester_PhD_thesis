% mc_buildCodeMake builds a target using a make-based build process
% target actions: 'build' or 'execute'
%
% fw-07-10
function [errorMsgs, warningMsgs] = mc_buildCodeMake(action)

% prepare project for building
targetProjectPathAndMAKEFILE = i_prepareProject;

% Invoke 'make' process
[errorMsgs, warningMsgs] = i_makeProject(targetProjectPathAndMAKEFILE, action);

% remove no longer required files
i_cleanUp(targetProjectPathAndMAKEFILE);





%% local functions

% =========================================================================
% i_prepareProject: perform all required preparations before building
%
function targetProjectPathAndMAKEFILE = i_prepareProject

global mcBuildPars;

% determine 'copy' command / 'mkdir' command (depends on system 
% architecture -- currently windows only)
myCopyCommand = i_DetermineSystemCommands;

% at this stage we are in <project>\sources -> destination path: one up
targetProjectPath = fileparts(pwd);

% produce directory tree for the target project
targetProjectPathAndMAKEFILE = i_ProduceProjectDirectoryTree(targetProjectPath);

% adjust current template makefile (tmf) according to model content

% define list of model dependent modules
myListOfFilesForSOURCES = { ...
    'app_vectors.c', ...
    'Start12.c', ...
    'rt_sim.c', ...
    'bsp_pll.c', ...
    'mc_main.c', ...
    'mc_signal.c', ...
    'bsp_sci.c', ...
    'app_sci.c', ...
    'bsp_err.c', ...
    'bsp_rti.c', ...
    'app_rti.c', ...
    'bsp_rbuf.c', ...
    'mc_timer.c' ...
    };


% all MBSE files are listed in rtw_filelist.mpf (= *.c files in .../sources)
myListOfFilesForSIMULINK = textread('rtw_filelist.mpf', '%[^\n]');

% find out which optional modules need to get included
Has_ExtMode       =  strcmp(mcBuildPars.resources.ExtMode, 'on');
Has_LCD           =  strcmp(mcBuildPars.resources.LCDMsgs, 'on');
Has_RFServer      =  mcBuildPars.resources.HasRFComms;
Has_RFClient      = (mcBuildPars.resources.RFCommsServerChannels > 0);
Has_RFComms       =  Has_RFServer || Has_RFClient;
Has_SPI           =  Has_RFComms  || mcBuildPars.resources.HasOnBoardDAC;
Has_freePortComms =  strcmp(mcBuildPars.resources.SCI0, 'frPT') || strcmp(mcBuildPars.resources.SCI1, 'frPT');
Has_FuzzyBlocks   =  mcBuildPars.resources.HasFuzzyBlocks;
Has_debugMessages = (str2double(mcBuildPars.resources.DEBUG_MSG_LVL) > 0);
Has_debugMangling =  strcmp(mcBuildPars.resources.DEBUG_MSG_MNGL, 'on');
Has_DSPblocks     =  mcBuildPars.resources.HasDSPblocks;
Has_FixedPoint    =  mcBuildPars.resources.HasFixedPoint;



% add project entry for LCD (if required)
if Has_LCD
    
    disp('### Adding LCD support to the project (1x)')
    myListOfFilesForSOURCES{end + 1} = 'mc_lcd.c';
    
end

% add project entry for radioComms (if required)
if Has_RFComms
    
    disp('### Adding RFComms to the project (1x)')
    myListOfFilesForSOURCES{end + 1} = 'mc_radioComms.c';
    
end

% add project entry for radioComms / Server (if required)
if Has_RFServer
    
    disp('### Adding RFComms (server) to the project (1x)')
    myListOfFilesForSOURCES{end + 1} = 'mc_radioServer.c';
    
end

% add project entry for radioComms / Client (if required)
if Has_RFClient
    
    disp('### Adding RFComms (client) to the project (1x)')
    myListOfFilesForSOURCES{end + 1} = 'mc_radioClient.c';
    
end

% add project entry for freePortComms (if required)
if Has_freePortComms
    
    disp('### Adding freePortComms support to the project (1x)')
    myListOfFilesForSOURCES{end + 1} = 'mc_freePortComms.c';
    
end

% add project entry for fuzzy support (if required)
if Has_FuzzyBlocks
    
    disp('### Adding fuzzy support to the project (1x)')
    myListOfFilesForSOURCES{end + 1} = 'FuzzyEngine.asm';
    
end

% add project entry for SPI support (if required)
if Has_SPI
    
    disp('### Adding SPI support to the project (1x)')
    myListOfFilesForSOURCES{end + 1} = 'mc_spi.c';
    
end

% add project entry for debug messages (if required)
if Has_debugMessages
    
    disp('### Adding debug message support to the project (1x)')
    myListOfFilesForSOURCES{end + 1} = 'mc_debugMsgs.c';
    
end

% add project entry for CONTINUOUS TIME SOLVER (if required)
useSolver = mcBuildPars.codeGenerator.buildOpts.solver;
if ~strcmp(useSolver, 'FixedStepDiscrete')
    
    disp('### Adding continuous-time solver to the project (1x)')
    myListOfFilesForSIMULINK{end + 1} = [useSolver '.c'];
    
end

% add project entry for microcontroller registers
mcType = mcBuildPars.resources.mcType;
disp('### Adding microcontroller register definition to the project (1x)')

switch mcType
    
    case 'BSP_MC9S12DG256'
        
        myListOfFilesForSOURCES{end + 1} = 'mc9s12dg256.c';
        
    case 'BSP_MC9S12DP256B'
        
        myListOfFilesForSOURCES{end + 1} = 'mc9s12dp256.c';
        
    case 'BSP_MC9S12C128'
        
        myListOfFilesForSOURCES{end + 1} = 'mc9s12c128.c';
        
    case 'BSP_MC9S12C32'
        
        myListOfFilesForSOURCES{end + 1} = 'mc9s12c32.c';
        
    case 'BSP_MC9S12DG128'
        
        myListOfFilesForSOURCES{end + 1} = 'mc9s12dg128.c';
        
end  % switch

% add project entries for EXTERNAL MODE support (if required)
if Has_ExtMode
    
    disp('### Adding External Mode files to the project (7x)')
    myListOfFilesForSIMULINK{end + 1} = 'mem_mgr.c';
    myListOfFilesForSIMULINK{end + 1} = 'ext_work.c';
    myListOfFilesForSIMULINK{end + 1} = 'updown.c';
    myListOfFilesForSIMULINK{end + 1} = 'ext_serial_9s12_port.c';
    myListOfFilesForSIMULINK{end + 1} = 'ext_serial_pkt.c';
    myListOfFilesForSIMULINK{end + 1} = 'ext_svr_serial_transport.c';
    myListOfFilesForSIMULINK{end + 1} = 'ext_svr.c';
    
end


% deterine memory model option ('-Mb' or '')
myMemModel = char(regexp(mcBuildPars.resources.MemModel, 'Flash_(\w+)', 'tokens', 'once'));
if strcmpi(myMemModel, 'banked')
    
    % banked memory model -> '-Mb'
    %myMemModelOpt = '-Mb';
    myLibrarySuffix = 'b';
    
else
    
    % flat memory model -> ''
    %myMemModelOpt = '';
    myLibrarySuffix = 's';

end

% add required libraries (banked, flat, rtw, dsp, ...)
myListOfFilesForLIBRARIES = { ...
    ['Ansi' myLibrarySuffix '.lib'], ...
    ['rtwlib_' myMemModel '.lib'] ...
    };


% toolbox specific modifications: Signal Processing Toolbox (DSP)
if Has_DSPblocks
    
    % check if the toolbox has been installed
    kk = ver('Signal');
    if ~isempty(kk)

        % Signal Processing Toolbox installed
        myListOfFilesForLIBRARIES{end + 1} = ['dsplib_' myMemModel '.lib'];

    else
        
        % toolbox not installed -> can't compile model
        error([mfilename ': Model includes DSP blocks, however the DSP blockset has not been installed'])
        
    end
    
end
    

% Toolbox specific modifications: Fixed-Point Toolbox
if Has_FixedPoint
    
    % check if the toolbox has been installed
    kk = ver('Fixedpoint');
    if ~isempty(kk)

        % Fixed-Point Toolbox installed
        myListOfFilesForLIBRARIES{end + 1} = ['fixptlib_' myMemModel '.lib'];

    else
        
        % toolbox not installed -> can't compile model
        error([mfilename ': Model includes fixed point calculus, however the Fixed Point toolbox has not been installed'])
        
    end
    
end


% assemble project makefile (.mk)
disp('### Adjusting makefile...')

% read makefile
proj = textread(targetProjectPathAndMAKEFILE, '%s', 'delimiter', '\n', 'whitespace', '');

% find all |>something<| tags
allTagIDX = find(~strcmp(regexp(proj, '\|>(\w+)<\|', 'match', 'once'), ''));
nAllTagIDX = length(allTagIDX);

% substitute all tags by their replacement
for ii = 1:nAllTagIDX
    
    % next makefile line (including a tag)
    currLine = allTagIDX(ii);
    
    % fetch tag
    currTag = char(regexp(proj{currLine}, '\|>(\w+)<\|', 'tokens', 'once'));
    
    % substitute tag
    proj{currLine} = strrep(proj{currLine}, ['|>' currTag '<|'], i_substTagInMakefile(currTag));
    
end  % nAllTagIDX


% save adjusted project makefile (.mk)
fid = fopen(targetProjectPathAndMAKEFILE, 'w');

% loop over all lines of the makefile
for ii = 1:length(proj)
    
    % write next line...
    fprintf(fid, '%s\r\n', char(proj(ii)));
    
end

fclose(fid);

% makefile adjusted -> inform user
disp('### ... done.')

%% smart debug messages support

% yes -> adjust sources to replace clear text debug messages by CRC16 
% based error codes  --  this reduces the required size of allocation 
% space in section .romdata1 and speeds up the transmission of debug 
% message logging data from the target to the host.

%  smart debug messages support?
if Has_debugMessages && Has_debugMangling
    
    % construct a debugMsgDictionary from the debug messages in the
    % selected source files

    % default messages
    debugMsgDictionary = mcDebugMsgDictionary(...
        'message', 'Unknown Function', ...
        'crc16ID', ['0x' dec2hex(crc16('0:Unknown Function'))], ...
        'level', '0', ...
        'type', 'name' ...
        );

    debugMsgDictionary = [debugMsgDictionary; mcDebugMsgDictionary(...
        'message', 'DEBUG_DYNAMIC: Switching DynamicDbgMsgLvl to ', ...
        'crc16ID', ['0x' dec2hex(crc16('0:DEBUG_DYNAMIC: Switching DynamicDbgMsgLvl to '))], ...
        'level', '0', ...
        'type', 'raw' ...
        )];

    % define a list of sources which are not to be touched by the 
    % pre-codegen debug message parser
    debug_exclude_list = { ...
        'app_vectors.c', ...
        'rt_sim.c', ...
        'Start12.c', ...
        'mc_debugMsgs.c', ...
        'bsp_pll.c', ...
        [lower(regexprep(mcType, 'BSP_', '')) '.c'], ...
        [mcBuildPars.modelName '.c'], ...
        [mcBuildPars.modelName '_data.c'] ...
        };
    
    % define a list of sources which are included by other files and thus
    % have to be added manually to the list of source files
    debug_include_list = { ...
        'ext_serial_utils.c'
        };
    
    % all source file candidates
    myListOfAllSourceFileCandidates = [ ...
        reshape(myListOfFilesForSOURCES, 1, length(myListOfFilesForSOURCES)), ...
        reshape(myListOfFilesForSIMULINK, 1, length(myListOfFilesForSIMULINK)), ...
        reshape(debug_include_list, 1, length(debug_include_list)) ...
        ];
    
    % list of all *.c files in 'mc\sources'
    myMcCoreSourcesPath = fullfile(mcBuildPars.mcBaseDir, 'mc', 'core');
    myMcCoreSources = dir(fullfile(myMcCoreSourcesPath, '*.c'));
    myMcCoreSourceNames = {myMcCoreSources(:).name};
    
    % list of all *.c files in 'ml\rtw\c\src\ext_mode\common'
    myRtwExtmodeCommonSourcePath = fullfile(mcBuildPars.mcBaseDir, 'ml', 'rtw', 'c', 'src', 'ext_mode', 'common');
    myRtwExtmodeCommonSources = dir(fullfile(myRtwExtmodeCommonSourcePath, '*.c'));
    myRtwExtmodeCommonSourceNames = {myRtwExtmodeCommonSources(:).name};
    
    % list of all *.c files in 'ml\rtw\c\src\ext_mode\serial'
    myRtwExtmodeSerialSourcePath = fullfile(mcBuildPars.mcBaseDir, 'ml', 'rtw', 'c', 'src', 'ext_mode', 'serial');
    myRtwExtmodeSerialSources = dir(fullfile(myRtwExtmodeSerialSourcePath, '*.c'));
    myRtwExtmodeSerialSourceNames = {myRtwExtmodeSerialSources(:).name};
    
    % need to check all source files
    disp('### Adjusting the following source files to mangle debug messages into CRC16-IDs:')
    for ii = 1:length(myListOfAllSourceFileCandidates)
        
        % next source file candidate
        currSource = myListOfAllSourceFileCandidates{ii};
        
        if ~any(strcmp(debug_exclude_list, currSource))
            
            % this is an adjustable file -> find source directory
            if any(strcmp(myMcCoreSourceNames, currSource))
                
                % in 'mc\sources'
                currSourcePath = myMcCoreSourcesPath;
                
            elseif any(strcmp(myRtwExtmodeCommonSourceNames, currSource))
                
                % in 'ml\rtw\c\src\ext_mode\common'
                currSourcePath = myRtwExtmodeCommonSourcePath;
                
            elseif any(strcmp(myRtwExtmodeSerialSourceNames, currSource))
                
                % in 'ml\rtw\c\src\ext_mode\serial'
                currSourcePath = myRtwExtmodeSerialSourcePath;
                
            else
                
                % source file not found -> error
                error(['mc9s12_buildaction: could not find source file ' currSource])
                
            end


            % check if this source file already exists as a local copy
            currLocalSource = dir(currSource);
            if isempty(currLocalSource)
                
                % file does not yet exist -> copy it from master location
                disp(['### Copying source file ''' currSource ''' to local build directory.'])
                system([myCopyCommand ' "' fullfile(currSourcePath, currSource) '"']);
                
            else
                
                % file exists -> has it been modified?
                myLocalSource = dir(currSource);
                myOrigSource = dir(fullfile(currSourcePath, currSource));
                
                if ~strcmp(myLocalSource.date, myOrigSource.date)
                    
                    % date stamps differ
                    disp(['### Copying recently modified source file ''' currSource ''' to local build directory.'])
                    system([myCopyCommand ' "' fullfile(currSourcePath, currSource) '"']);
                    
                end
                
            end
            
            % local directory now contains the most recent version of
            % source file <currSource>  ->  perform debug message mangling
            disp(['### Adjusting debug message contents in file: ''' currSource ''''])
            debugMsgDictionary = i_debugMessageMangling(currSource, debugMsgDictionary);
            
        end  % currSource is adjustable
        
    end  % all source file candidates
    
    % store debugMsgDictionary on disc...
    %debugMsgDictionary = sort(unique(debugMsgDictionary));
    save 'debugMsgDictionary' debugMsgDictionary
   
end  % Has_debugMessages




%% local functions





%% =========================================================================
% debug message mangling -> replace debug message strings by CRC16-IDs
function debugMsgDictionary = i_debugMessageMangling(currSource, debugMsgDictionary)

% read source file
srcText = textread(currSource, '%s', 'delimiter', '\n', 'whitespace', '');

% ---------------------------------------------------------------------
% DEFINE_DEBUG_FNAME
% ---------------------------------------------------------------------

% find lines with DEFINE_DEBUG_FNAME macros
myDebugFuncNameIDX = find(~strcmp(regexp(srcText, 'DEFINE_DEBUG_FNAME\(\"(.*)\"\)', 'match', 'once'), ''));

% filter out corresponding function name
myFuncNames = regexp(srcText(myDebugFuncNameIDX), 'DEFINE_DEBUG_FNAME\(\"(.*)\"\)', 'tokens', 'once');
myFuncNames = [myFuncNames{:}];

% replace function name definitions with CRC16-IDs
for ii = 1:length(myFuncNames)
    
    currFuncName = myFuncNames{ii};
    currFuncNameID = ['0x' dec2hex(crc16(['0:' currFuncName]))];    % level '0'
    
    % append message reference to the current debug message dictionary
    debugMsgDictionary = [ ...
        debugMsgDictionary; ...
        mcDebugMsgDictionary('message', currFuncName, 'crc16ID', currFuncNameID, 'level', '0', 'type', 'name') ...
        ]; %#ok<*AGROW>
    
    % replace source code reference by mangled version
    srcText2 = srcText(myDebugFuncNameIDX(ii) + 1:end);
    srcText{myDebugFuncNameIDX(ii) + 1} = strrep(srcText{myDebugFuncNameIDX(ii)}, ['"' currFuncName '"'], num2str(currFuncNameID));
    % srcText{myDebugFuncNameIDX(ii)} = ['// ' srcText{myDebugFuncNameIDX(ii)}];
    kk = srcText{myDebugFuncNameIDX(ii)};
    ll = regexp(kk, '\w', 'once');      % first non-blank character
    srcText{myDebugFuncNameIDX(ii)} = [kk(1:ll-1) '// ' kk(ll:end)];
    
    % adjust index to account for the additional line
    myDebugFuncNameIDX = myDebugFuncNameIDX + 1;
    
    % adjust source code
    srcText = [srcText(1:myDebugFuncNameIDX(ii)); srcText2];
    
end  % myFuncNames


% ---------------------------------------------------------------------
% PRINT_DEBUG_MSG_LVLx
% ---------------------------------------------------------------------

% find lines with PRINT_DEBUG_MSG_LVLx macros
myDebugMsgIDX = find(~strcmp(regexp(srcText, 'PRINT_DEBUG_MSG_LVL[1-5]\(\"(.*)\"\)', 'match', 'once'), ''));

% filter out corresponding function name
myDebugMsgs = regexp(srcText(myDebugMsgIDX), 'PRINT_DEBUG_MSG_LVL[1-5]\(\"(.*)\"\)', 'tokens', 'once');
myDebugLvls = regexp(srcText(myDebugMsgIDX), 'PRINT_DEBUG_MSG_LVL([1-5])\(.*\)', 'tokens', 'once');
myDebugMsgs = [myDebugMsgs{:}];
myDebugLvls = [myDebugLvls{:}];

% replace debug messages with CRC16-IDs
for ii = 1:length(myDebugMsgs)
    
    currMessage = myDebugMsgs{ii};
    currMessageLvl = myDebugLvls{ii};
    currMessageID = ['0x' dec2hex(crc16([currMessageLvl ':' currMessage]))];
    
    % append message reference to the current debug message dictionary
    debugMsgDictionary = [ ...
        debugMsgDictionary; ...
        mcDebugMsgDictionary('message', currMessage, 'crc16ID', currMessageID, 'level', currMessageLvl, 'type', 'text') ...
        ];
    
    % replace source code reference by mangled version
    srcText2 = srcText(myDebugMsgIDX(ii) + 1:end);
    srcText{myDebugMsgIDX(ii) + 1} = strrep(srcText{myDebugMsgIDX(ii)}, ['("' currMessage '"'], ...
                                                                        ['_ID(' num2str(currMessageID)]);
    % srcText{myDebugMsgIDX(ii)} = ['// ' srcText{myDebugMsgIDX(ii)}];
    kk = srcText{myDebugMsgIDX(ii)};
    ll = regexp(kk, '\w', 'once');      % first non-blank character
    srcText{myDebugMsgIDX(ii)} = [kk(1:ll-1) '// ' kk(ll:end)];
    
    % adjust index to account for the additional line
    myDebugMsgIDX = myDebugMsgIDX + 1;
    
    % adjust source code
    srcText = [srcText(1:myDebugMsgIDX(ii)); srcText2];
    
end  % myDebugMsgs


% ---------------------------------------------------------------------
% PRINT_DEBUG_MSG_LVLx_Raw
% ---------------------------------------------------------------------

% find lines with PRINT_DEBUG_MSG_LVLx_Raw macros
myDebugMsgIDX = find(~strcmp(regexp(srcText, 'PRINT_DEBUG_MSG_LVL[1-5]_Raw\(\"(.*)\"\)', 'match', 'once'), ''));

% filter out corresponding function name
myDebugMsgs = regexp(srcText(myDebugMsgIDX), 'PRINT_DEBUG_MSG_LVL[1-5]_Raw\(\"(.*)\"\)', 'tokens', 'once');
myDebugLvls = regexp(srcText(myDebugMsgIDX), 'PRINT_DEBUG_MSG_LVL([1-5])_Raw\(.*\)', 'tokens', 'once');
myDebugMsgs = [myDebugMsgs{:}];
myDebugLvls = [myDebugLvls{:}];

% replace debug messages with CRC16-IDs
for ii = 1:length(myDebugMsgs)
    
    currMessage = myDebugMsgs{ii};
    currMessageLvl = myDebugLvls{ii};
    currMessageID = ['0x' dec2hex(crc16([currMessageLvl ':' currMessage]))];
    
    % append message reference to the current debug message dictionary
    debugMsgDictionary = [ ...
        debugMsgDictionary; ...
        mcDebugMsgDictionary('message', currMessage, 'crc16ID', currMessageID, 'level', currMessageLvl, 'type', 'raw') ...
        ];
    
    % replace source code reference by mangled version
    srcText2 = srcText(myDebugMsgIDX(ii) + 1:end);
    srcText{myDebugMsgIDX(ii) + 1} = strrep(srcText{myDebugMsgIDX(ii)}, ['("' currMessage '"'], ...
                                                                        ['_ID(' num2str(currMessageID)]);
    % srcText{myDebugMsgIDX(ii)} = ['// ' srcText{myDebugMsgIDX(ii)}];
    kk = srcText{myDebugMsgIDX(ii)};
    ll = regexp(kk, '\w', 'once');      % first non-blank character
    srcText{myDebugMsgIDX(ii)} = [kk(1:ll-1) '// ' kk(ll:end)];
    
    % adjust index to account for the additional line
    myDebugMsgIDX = myDebugMsgIDX + 1;
    
    % adjust source code
    srcText = [srcText(1:myDebugMsgIDX(ii)); srcText2];
    
end  % myDebugMsgs


% ---------------------------------------------------------------------
% PRINT_DEBUG_MSG_NLx
% ---------------------------------------------------------------------

% find lines with PRINT_DEBUG_MSG_NLx macros
myDebugMsgIDX = ~strcmp(regexp(srcText, 'PRINT_DEBUG_MSG_NL([1-5])', 'match', 'once'), '');

% filter out corresponding debug level
myDebugLvls = regexp(srcText(myDebugMsgIDX), 'PRINT_DEBUG_MSG_NL([1-5])', 'tokens', 'once');
myDebugLvls = unique([myDebugLvls{:}]);

% store corresponding CRC16-IDs
for ii = 1:length(myDebugLvls)
    
    currMessage = '';       % no message, just new line
    currMessageLvl = myDebugLvls{ii};
    currMessageID = ['0x' dec2hex(crc16([currMessageLvl ':' currMessage]))];
    
    % append message reference to the current debug message dictionary
    debugMsgDictionary = [ ...
        debugMsgDictionary; ...
        mcDebugMsgDictionary('message', currMessage, 'crc16ID', currMessageID, 'level', currMessageLvl, 'type', 'NL') ...
        ];
    
end  % myDebugLvls


% store adjusted source file
fid = fopen(currSource, 'w');
for ii = 1:length(srcText)
    fprintf(fid, '%s\r\n', char(srcText{ii}));
end
fclose(fid);



%% =========================================================================
function [myCopyCommand myMkdirCommand] = i_DetermineSystemCommands

% determine Windows version
[~, result] = system('ver');
if ~isempty(regexp(result, 'Windows 2000', 'once'))

    hostArch = 'win2000';

elseif ~isempty(regexp(result, 'Windows XP', 'once' ))

    hostArch = 'winxp';

elseif ~isempty(regexp(result, 'Microsoft Windows', 'once' ))
    
    hostArch = 'win';    % e.g. vista

elseif ~isempty(regexp(result, 'Windows NT', 'once' ))
    
    hostArch = 'nt';    % or 'jnt' treated same as NT.

else

    hostArch = 'unsupported';

end


% determine copy command
switch hostArch
    
    case {'win2000', 'winxp', 'win'}
        
        myCopyCommand = 'copy /Y';
        myMkdirCommand = 'mkdir';
        
    case {'nt', 'jnt'}
        
        % ??  might need to be changed... ??
        myCopyCommand = 'xcopy /E';
        myMkdirCommand = 'mkdir';
        
    otherwise
        
        error('Unsupported Host.');
        
end  % switch



%% =========================================================================
function i_cleanUp(targetProjectPathAndMAKEFILE)

% currently not used (fw-02-09)

disp(['### CleanUp - removing ' targetProjectPathAndMAKEFILE]);
% system(['del "' targetProjectPathAndMAKEFILE '"']);


%% =========================================================================
function targetProjectPathAndMAKEFILE = i_ProduceProjectDirectoryTree(targetProjectPath)

global mcBuildPars;

% determine 'copy' command / 'mkdir' command (depends on system 
% architecture -- currently windows only)
[myCopyCommand myMkdirCommand] = i_DetermineSystemCommands;

% <project>-+-bin
%           |
%           +-cmd-+-postload.cmd
%           |     |
%           |     +-preload.cmd
%           |     |
%           |     +-reset.cmd
%           |     |
%           |     +-startup.cmd
%           |
%           +-prm-+-burner.bbl
%           |     |
%           |     +-project.prm
%           |
%           |
%           +-sources
if ~exist(fullfile(targetProjectPath, 'bin'), 'dir')
    system([myMkdirCommand ' "' fullfile(targetProjectPath, 'bin') '"']);
end

if ~exist(fullfile(targetProjectPath, 'cmd'), 'dir')
    system([myMkdirCommand ' "' fullfile(targetProjectPath, 'cmd') '"']);
end

if ~exist(fullfile(targetProjectPath, 'prm'), 'dir')
    system([myMkdirCommand ' "' fullfile(targetProjectPath, 'prm') '"']);
end


% feedback...
disp('### Copying CodeWarrior project files to the build directory')

% determine memory model ('flat', 'banked')
myMemModel = regexp(mcBuildPars.resources.MemModel, '\w+_(\w+)', 'tokens');
myMemModel = char(myMemModel{:});

% copy standard files from '...\bin\templates' ...
binPath      = fullfile(mcBuildPars.mcBaseDir, 'bin');
templatePath = fullfile(binPath, 'templates');

% ... to <project>\prm  :  memmap_[flat|banked].prm
system([myCopyCommand ' "' fullfile(templatePath, ['memmap_' myMemModel '.prm']) '" "' fullfile(targetProjectPath, 'prm', 'project.prm') '"']);

% ... to <project>\prm  :  burner.bbl
if ~exist(fullfile(targetProjectPath, 'prm', 'burner.bbl'), 'file')
    system([myCopyCommand ' "' fullfile(templatePath, 'burner.bbl') '" "' fullfile(targetProjectPath, 'prm') '"']);
end


% ... to <project>\cmd  :  postload.cmd
if strcmp(mcBuildPars.resources.FullyAutoBuild, 'on')
    
    % compile, download and run
    system([myCopyCommand ' "' fullfile(templatePath, 'postload_run.cmd') '" "' fullfile(targetProjectPath, 'cmd', 'postload.cmd') '"']);
    
else
    
    % just build and download, don't run
    system([myCopyCommand ' "' fullfile(templatePath, 'postload_breakpoint.cmd') '" "' fullfile(targetProjectPath, 'cmd', 'postload.cmd') '"']);
    
end

% invariant command files  :  preload, reset, startup
if ~exist(fullfile(targetProjectPath, 'cmd', 'preload.cmd'), 'file')
    system([myCopyCommand ' "' fullfile(templatePath, 'preload.cmd')  '" "' fullfile(targetProjectPath, 'cmd') '"']);
end
if ~exist(fullfile(targetProjectPath, 'cmd', 'reset.cmd'), 'file')
    system([myCopyCommand ' "' fullfile(templatePath, 'reset.cmd')    '" "' fullfile(targetProjectPath, 'cmd') '"']);
end
if ~exist(fullfile(targetProjectPath, 'cmd', 'startup.cmd'), 'file')
    system([myCopyCommand ' "' fullfile(templatePath, 'startup.cmd')  '" "' fullfile(targetProjectPath, 'cmd') '"']);
end


% ... to <project>  :  Monitor.ini, Default.mem, Monitor.hwl
if ~exist(fullfile(targetProjectPath, 'Monitor.ini'), 'file')
    system([myCopyCommand ' "' fullfile(templatePath, 'Monitor.ini') '" "' targetProjectPath '"']);
end
if ~exist(fullfile(targetProjectPath, 'Default.mem'), 'file')
    system([myCopyCommand ' "' fullfile(templatePath, 'Default.mem') '" "' targetProjectPath '"']);
end
if ~exist(fullfile(targetProjectPath, 'Monitor.hwl'), 'file')
    system([myCopyCommand ' "' fullfile(templatePath, 'Monitor.hwl') '" "' targetProjectPath '"']);
end


% ... to <project>  :  <modelName>.mk  (template  --  needs adjusted)
targetProjectPathAndMAKEFILE = fullfile(targetProjectPath, [mcBuildPars.modelName '.mk']);
system([myCopyCommand ' "' fullfile(templatePath, mcBuildPars.compiler.templateMakeFileName) '" "' targetProjectPathAndMAKEFILE '"']);


%% determine makefile tag replacement
function outTag = i_substTagInMakefile(currTag)

global mcBuildPars;

% resources tags (expanded automatically)
resourcesTags = fieldnames(mcBuildPars.resources);

% resource tag?
if ismember(currTag, resourcesTags)
    
    % yes -> expand tag
    currResource = mcBuildPars.resources.(currTag);
    
    % return 'adjusted' tag ('on' -> '1', 'off' -> '0', etc.)
    outTag = mc_interpreteUserOption(currResource);
    
    % done with this tag -> return
    return
    
end


% tags which need to be expanded individually:
%
% TEMPLATE_MAKEFILE_NAME
% MAKEFILE_NAME
% MAKEFILE_TIMESTAMP
% MODEL_NAME
% MODEL_MODULES
% MAKEFILE_NAME
% MATLAB_ROOT
% ALT_MATLAB_ROOT
% MATLAB_BIN
% ALT_MATLAB_BIN
% S_FUNCTIONS
% S_FUNCTIONS_LIB
% SOLVER
% NUMST
% TID01EQ
% NCSTATES
% BUILDARGS
% MULTITASKING
% toolboxbasedir
% compilerbasedir
% rtw_libbuilddir
% prj_localbuilddir
% MODELREFS
% SHARED_SRC
% SHARED_SRC_DIR
% SHARED_BIN_DIR
% SHARED_LIB
% MODELLIB
% MODELREF_LINK_LIBS
% MODELREF_LINK_RSPFILE_NAME
% START_MDLREFINC_EXPAND_INCLUDES
% RELATIVE_PATH_TO_ANCHOR
% MODELREF_TARGET_TYPE
% START_EXPAND_INCLUDES
% END_EXPAND_INCLUDES
% EXPAND_ADDITIONAL_LIBRARIES
% START_EXPAND_RULES
% END_EXPAND_RULES
% START_EXPAND_LIBRARIES
% START_EXPAND_MODULES
% END_EXPAND_MODULES
% EXPAND_LIBRARY_NAME
% END_EXPAND_LIBRARIES
% START_ADDITIONAL_LIBRARIES
% EXPAND_LIBRARY_NAME
% END_ADDITIONAL_LIBRARIES
% START_EXPAND_LIBRARIES
% END_EXPAND_LIBRARIES
% START_PRECOMP_LIBRARIES
% END_PRECOMP_LIBRARIES

switch currTag
    
    case 'TEMPLATE_MAKEFILE_NAME'
        
        % current template makefile name (target dependent)
        outTag = mcBuildPars.compiler.templateMakeFileName;
        
    case 'MAKEFILE_NAME'
        
        % current makefile name (model dependent)
        outTag = [mcBuildPars.modelName '.mk'];
        
    case 'MAKEFILE_TIMESTAMP'
        
        % timestamp of makefile
        outTag = datestr(now);
        
    case 'MODEL_NAME'
        
        % model name
        outTag = mcBuildPars.modelName;
        
    case 'MATLAB_ROOT'
        
        % matlab installation path
        outTag = matlabroot;
        
    case 'ALT_MATLAB_ROOT'
        
        % matlab installation path without spaces
        if strcmp(mcBuildPars.codeGenerator.codeGeneratorName, 'RTW')
            
            % using 'RTW' as codegenerator
            outTag = RTW.transformPaths(matlabroot);
            
        else
            
            % TargetLink -> currently no method available to turn a
            % path name into a space free path name
            outTag = matlabroot;
            
        end
        
    case 'MATLAB_BIN'
        
        % matlab binary installation path
        outTag = fullfile(matlabroot, 'bin', 'win32');
        
    case 'ALT_MATLAB_BIN'
        
        % matlab installation path without spaces
        if strcmp(mcBuildPars.codeGenerator.codeGeneratorName, 'RTW')
            
            % using 'RTW' as codegenerator
            outTag = RTW.transformPaths(fullfile(matlabroot, 'bin', 'win32'));
            
        else
            
            % TargetLink -> currently no method available to turn a
            % path name into a space free path name
            outTag = fullfile(matlabroot, 'bin', 'win32');
            
        end
        
    case 'MODEL_MODULES'
        
        % list of model dependent modules
        allModules = strrep(mcBuildPars.codeGenerator.buildOpts.modules, 'rt_printf.c', '');
        allModules = strrep(allModules, 'rt_matrx.c', '');
        
        % reduce list of model dependent modules
        outTag = deblank(allModules);
        
    case 'SOLVER'
        
        % ODE solver
        outTag = mcBuildPars.codeGenerator.buildOpts.solver;
        
    case 'NUMST'
        
        % number of sample times
        outTag = mcBuildPars.codeGenerator.buildOpts.numst;
        
    case 'TID01EQ'
        
        % TID01EQ
        outTag = mcBuildPars.codeGenerator.buildOpts.tid01eq;
        
    case 'NCSTATES'
        
        % number of continuous states
        outTag = mcBuildPars.codeGenerator.buildOpts.ncstates;
        
    case 'BUILDARGS'
        
        % further build args
        outTag = mcBuildPars.codeGenerator.buildArgs;
        
    case 'MULTITASKING'
        
        % multitasking?
        if strcmp(mcBuildPars.codeGenerator.buildOpts.solverMode, 'MultiTasking')

            % yes
            outTag = '1';
            
        else
            
            % nope
            outTag = '0';
            
        end
            
    case 'toolboxbasedir'
        
        % installation directory (toolbox)
        outTag = mcBuildPars.mcBaseDir;
        
    case 'rtw_libbuilddir'
        
        % library build directory
        outTag = fullfile(mcBuildPars.mcBaseDir, 'rtwlib', 'rtwlibbuild');
        
%     case 'compilerbasedir'
%     case 'prj_localbuilddir'
%     case 'S_FUNCTIONS'
%     case 'S_FUNCTIONS_LIB'

    otherwise

        % all other tags -> return tag (unknown)
        outTag = currTag;
        
end  % switch
        
