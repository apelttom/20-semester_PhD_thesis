% Recompile the communication module 'ext_comm'
%
% This file can be called 
% - without call-up parameters
% - with one call-up parameter (debug level -> 0 .. 5)
% - with two call-up parameters (debug level, additional options (eg. 
%   '-Dmyopt=3 -DANOTHEROPT')
% - with three call-up parameters (same as before plus keyword 'check' -- 
%   specifying the latter forces the checking of the marker file. On
%   validity 'remex' simply returns without doing anything.
%
% fw-01-09

function remex(varargin)

global mcBuildPars;


% The value of 'ReadOnlyInstall' is adjusted by the 'setup' script. Do not
% modify the following line.
ReadOnlyInstall = 0;


% has the global variable 'mcBuildPars' been initialized?
if ~isempty(mcBuildPars)

    % yes -> fetch base dir
    mcBaseDir = mcBuildPars.mcBaseDir;

    % specify a number of fixed options
    if strcmp(mcBuildPars.resources.ExtModeStatusBarClk, 'on')

        % display status bar clock
        fixOpts =  [...
            '-DSEND_GET_TIME_PKTS=1 ' ...
            '-DCIRCBUFSIZE=' num2str(mcBuildPars.resources.ExtModeTxBufSize) ' ' ...
            '-DFIFOBUFSIZE=' num2str(mcBuildPars.resources.ExtModeFifoBufSize) ' ' ...
            '-DTARGET_CPU_FAMILY=' mc_interpreteUserOption(mcBuildPars.resources.mcType, 'cpuFamily') ' ' ...
            ];

    else

        % no status bar clock
        fixOpts =  [...
            '-DSEND_GET_TIME_PKTS=0 ' ...
            '-DCIRCBUFSIZE=' num2str(mcBuildPars.resources.ExtModeTxBufSize) ' ' ...
            '-DFIFOBUFSIZE=' num2str(mcBuildPars.resources.ExtModeFifoBufSize) ' ' ...
            '-DTARGET_CPU_FAMILY=' mc_interpreteUserOption(mcBuildPars.resources.mcType, 'cpuFamily') ' ' ...
            ];

    end
    
else
    
    % not yet -> determine base dir from location of this file...
    mcBaseDir = fileparts(fileparts(mfilename('fullpath')));
    
    % default fixed options
    fixOpts = '-DTARGET_CPU_FAMILY=BSP_MC9S12';
    
end

% MATLAB installation
matlabBaseDir = matlabroot;


% transform paths to 8.3 format  - provided RTW has been installed
result = ver('rtw');
if ~isempty(result)
    
    % license for Real-Time Workshop found
    mcBaseDirComp     = RTW.transformPaths(mcBaseDir);
    matlabBaseDirComp = RTW.transformPaths(matlabBaseDir);
    
else
    
    % no RTW installation -> use 'raw' installation directory names
    mcBaseDirComp     = mcBaseDir;
    matlabBaseDirComp = matlabBaseDir;
    
end


% set include paths
include_path0 = fullfile(mcBaseDirComp, 'ml', 'extern', 'include');
include_path1 = fullfile(mcBaseDirComp, 'ml', 'rtw', 'c', 'src', 'ext_mode', 'common');
include_path2 = fullfile(mcBaseDirComp, 'ml', 'rtw', 'c', 'src', 'ext_mode', 'serial');
include_path3 = fullfile(mcBaseDirComp, 'ml', 'rtw', 'ext_mode', 'common');
include_path4 = fullfile(mcBaseDirComp, 'ml', 'rtw', 'ext_mode', 'serial');
include_path5 = fullfile(mcBaseDirComp, 'mc', 'core');
include_path6 = fullfile(matlabBaseDirComp,   'extern', 'include');        % needs to be included AFTER include_path0


% define host source files
build_file0 = fullfile(mcBaseDirComp, 'ml', 'rtw', 'ext_mode', 'common', 'ext_comm.c');
build_file1 = fullfile(mcBaseDirComp, 'ml', 'rtw', 'ext_mode', 'common', 'ext_convert.c');
build_file2 = fullfile(mcBaseDirComp, 'ml', 'rtw', 'ext_mode', 'common', 'debugMsgs_host.c');
build_file3 = fullfile(mcBaseDirComp, 'ml', 'rtw', 'ext_mode', 'serial', 'ext_serial_transport.c');
build_file4 = fullfile(mcBaseDirComp, 'ml', 'rtw', 'ext_mode', 'serial', 'ext_serial_win32_port.c');
build_file5 = fullfile(mcBaseDirComp, 'ml', 'rtw', 'c', 'src', 'ext_mode', 'serial', 'ext_serial_pkt.c');



% set macro DEBUG_MSG_LVL
if nargin == 0

    DebugLvl = 0;
    addOpts = [fixOpts ' ', processOptions(DebugLvl)];

    % make sure the additional options are properly formatted
    addOpts = strtrim(strrep(addOpts, '  ', ' '));

elseif nargin == 1

    DebugLvl = varargin{1};
    addOpts = [fixOpts ' ', processOptions(DebugLvl)];

    % make sure the additional options are properly formatted
    addOpts = strtrim(strrep(addOpts, '  ', ' '));

elseif nargin == 2

    DebugLvl = varargin{1};
    addOpts = [fixOpts ' -DDEBUG_MSG_LVL=' num2str(DebugLvl) ' ' varargin{2}];

    % make sure the additional options are properly formatted
    addOpts = strtrim(strrep(addOpts, '  ', ' '));
    
else
    
    % three or more call-up parameters -> keyword 'check'?
    if strcmpi(varargin{3}, 'check')
        
        % keyword 'check' specified -> check validity of the marker file
        % and return if nothing's been changed

        DebugLvl = varargin{1};
        addOpts  = [fixOpts ' -DDEBUG_MSG_LVL=' num2str(DebugLvl) ' ' varargin{2}];

        % make sure the additional options are properly formatted
        addOpts = strtrim(strrep(addOpts, '  ', ' '));

        if marker_valid(addOpts, ReadOnlyInstall, mcBaseDir)
            
            % no new options -> return
            return;
            
        end
        
    else
        
        % invalid calling syntax        
        error('remex:option','invalid option to remex');
        
    end
    
end


% compile 'ext_comm' - now compiles to temporary directory
disp ('Compiling file ''ext_comm.c'' into a DLL (file extension ''mexw32'').');
compile_string = ['mex -v ' ...
    build_file0 ' ' ...
    build_file1 ' ' ...
    build_file2 ' ' ...
    build_file3 ' ' ...
    build_file4 ' ' ...
    build_file5 ' ' ...
    '-I' include_path0 ' ' ...
    '-I' include_path1 ' ' ...
    '-I' include_path2 ' ' ...
    '-I' include_path3 ' ' ...
    '-I' include_path4 ' ' ...
    '-I' include_path5 ' ' ...
    '-I' include_path6 ' ' ...
    '-output ' tempdir 'ext_serial_mc9s12_comm ' ...
    addOpts ' -DWIN32 -Drtmc9s12_HOST'];

% do it..
eval(compile_string);


% write current options to marker file
write_marker(ReadOnlyInstall, addOpts, mcBaseDir);


% install new host comms file

%warning('OFF','Simulink:SL_CloseBlockDiagramNotLoaded');
%close_system(bdroot);

if ~ReadOnlyInstall
    
    if mislocked('ext_serial_mc9s12_comm')
        munlock ext_serial_mc9s12_comm;
    end
    clear mex;
    
else

    if mislocked('.\ext_serial_mc9s12_comm')
        munlock ext_serial_mc9s12_comm;
    end
    clear mex;
    
end

if ~ReadOnlyInstall
    
    % source file
    srcFile = [tempdir 'ext_serial_mc9s12_comm.mexw32'];
    
    if exist(srcFile, 'file')
        
        disp (['Copying file ''ext_serial_mc9s12_comm.mexw32'' to the required system folder... (' fullfile(mcBaseDir, 'bin') ')']);
        movefile(srcFile, fullfile(mcBaseDir, 'bin', 'ext_serial_mc9s12_comm.mexw32'));
        disp ('Done !');
        
    else
        
        disp('WARNING: Failed to compile the host communication module')
        
    end
    
else

    % source file
    srcFile = [tempdir 'ext_serial_mc9s12_comm.mexw32'];
    
    if exist(srcFile, 'file')
        
%         % copy host communication module to local folder 'slprj\mc9s12'
%         if ~exist('slprj\mc9s12', 'dir')
% 
%             mkdir('slprj\mc9s12');
% 
%         end

        disp (['Copying file ''ext_serial_mc9s12_comm.mexw32'' to the required user folder... (' pwd ')']);
        movefile(srcFile, fullfile(pwd, 'ext_serial_mc9s12_comm.mexw32'));
        disp ('Done !');
        
    else
        
        disp('WARNING: Failed to compile the host communication module')
        
    end

end




%% local functions --------------------------------------------------------------

% adjust current options (from the marker file, if possible) to set the
% current 'debug level'
function adjOpts = processOptions(DebugLvl)

% check if the marker file already exists
if exist('ext_serial_mc9s12_comm_marker.txt', 'file')
    
    % marker file exists -> read it
    fid = fopen('ext_serial_mc9s12_comm_marker.txt', 'r');
    adjOpts = char(fread(fid).');
    fclose(fid);
    
    % set adjOpts, replacing the current DEBUG_MSG_LVL by the new value
    adjOpts = regexprep(adjOpts, '-DDEBUG_MSG_LVL=\d', ['-DDEBUG_MSG_LVL=' num2str(DebugLvl)]);
    
else
    
    % no marker file -> set adjOpts
    adjOpts = [' -DDEBUG_MSG_LVL=' num2str(DebugLvl) ' '];
    
end


% write marker file --------------------------------------------------
function write_marker(ReadOnlyInstall, options, BaseDir)

% Read only installation?
if ~ReadOnlyInstall
    
    % no -> store marker file in '.../bin' folder
    fid = fopen(fullfile(BaseDir, 'bin', 'ext_serial_mc9s12_comm_marker.txt'), 'w');
    fwrite(fid, options);
    fclose(fid);
    
else
    
    % yes -> store marker file locally
    fid = fopen('ext_serial_mc9s12_comm_marker.txt', 'w');
    fwrite(fid, options);
    fclose(fid);
    
end


% check marker file --------------------------------------------------
function valid = marker_valid(NEWOPTS, ReadOnlyInstall, BaseDir)

% Read only installation?
if ~ReadOnlyInstall
    
    % no -> fetch marker file from '.../bin' folder
    fid = fopen(fullfile(BaseDir, 'bin', 'ext_serial_mc9s12_comm_marker.txt'), 'r');
    
else
    
    % yes -> fetch marker file from current folder
    fid = fopen('ext_serial_mc9s12_comm_marker.txt', 'r');
    
end

% attempt to read options (if maker file exists)
if fid ~= -1
    
    options = char(fread(fid).');
    fclose(fid);
    
else
    
    options = '';
    
end

% are the options the same as in the marker file?
if strcmp(options, NEWOPTS)
    
    % yes
    valid = 1;
    
else
    
    % no
    valid = 0;
    
end
