% resource check, mc9s12
%
% The model resources are determined and stored in the global variable
% 'mcBuildPars.resources'. It is assumed that all target specific options
% have a common prefix (callup parameter, eg. 'mcBuildPars.resources.'). The corresponding
% class entry has the same name but without the prefix, i. e. model option
% 'mc9s12_TargetBoard' -> 'mcBuildPars.resources.TargetBoard'.
%
% The introduction of a new option as a tlc variable in the main tlc-file
% ('mc9s12.tlc') thus needs to follow the following two rules:
% [1] use of the target prefix (eg. 'mc9s12_')
% [2] the corresponding class entry (without the prefix) needs to be added
%     to .../bin/mcResources/private/defineClassStruct.m
%
% List of tags (name convention: 'mcTarget_<tag_name>'):
%
% mcTarget_rfCommsCli
% mcTarget_rfCommsSrv
% mcTarget_dac
% mcTarget_dacDragonOnBoard
% mcTarget_adc
% mcTarget_digOut
% mcTarget_digIn
% mcTarget_pwm
% mcTarget_pwmServo
% mcTarget_timer
% mcTarget_sonar
% mcTarget_rfCommsCli
% mcTarget_rfCommsSrv
% mcTarget_freePortCommsTX
% mcTarget_freePortCommsRX
% mcTarget_fuzzy
%
% fw-02-09

function mc_resourceCheck(targetPrefix)

global mcBuildPars;

% create 'resources' and populate it with current model settings. The
% result can be accessed through global variable 'mcBuildPars.resources'
mcBuildPars.resources = mc_readOptions(gcs, targetPrefix);


% set fixed options (i. e., those not defined via the options pages
% (on RTW these used to be the NonUI options defined within the main TLC)
i_setFixedOptions(targetPrefix);

% check parameter consistency: External Mode
i_checkExternalMode;

% check parameter consistency: FreePort parameters
i_checkFreePorts;

% check parameter consistency: Fuzzy blocks
i_checkFuzzyBlocks;

% check parameter consistency: Onboard DAC (Dragon12plus)
i_checkOnBoardDAC_Dragon12Plus;

% check parameter consistency: Timer blocks
i_checkTimers;

% check parameter consistency: RFComms blocks
i_checkRFComms;

% check parameter consistency: ADC
i_checkADC;

% check for presence of elements from the DSP block set
i_checkDSPblocks;

% check for presence of fixed point calculus
i_checkFixedPoint;


% store consistent options set to the model ----------------------------
mc_writeOptions(gcs, targetPrefix, mcBuildPars.resources);

% save adjusted model...
save_system




%% local functions


%% check consistency of External Mode settings
function i_checkExternalMode

global mcBuildPars;

% ensure consistency of option 'ExtMode' (defined via the drop down menu in
% Simulink as well as a target specific option '<prefix>ExtMode')
if strcmp(get_param(gcs,'SimulationMode'), 'normal')
    
    % 'normal' mode
    if strcmp(mcBuildPars.resources.ExtMode, 'on')
        
        % option mismatch -> adjust target specific 'ExtMode' option
        mcBuildPars.resources.ExtMode = 'off';
        
        %         % disable all ExtMode options
        %         actConfigSet = getActiveConfigSet(gcs);
        %
        %         % disable options...
        %         actConfigSet.Components(end).Components(end).setPropEnabled('mc9s12_ExtModeRxBufSize', 'off');
        %         actConfigSet.Components(end).Components(end).setPropEnabled('mc9s12_ExtModeTxBufSize', 'off');
        %         actConfigSet.Components(end).Components(end).setPropEnabled('mc9s12_ExtModeBufSizeDisp', 'off');
        %         actConfigSet.Components(end).Components(end).setPropEnabled('mc9s12_ExtModeFifoBufSize', 'off');
        %         actConfigSet.Components(end).Components(end).setPropEnabled('mc9s12_ExtModeFifoBufNum', 'off');
        %         actConfigSet.Components(end).Components(end).setPropEnabled('mc9s12_ExtModeDispCommStatePTT', 'off');
        %         actConfigSet.Components(end).Components(end).setPropEnabled('mc9s12_ExtModeBaudrate', 'off');
        %         actConfigSet.Components(end).Components(end).setPropEnabled('mc9s12_ExtModeHostPort', 'off');
        %         actConfigSet.Components(end).Components(end).setPropEnabled('mc9s12_ExtModeTargetPort', 'off');
        %         actConfigSet.Components(end).Components(end).setPropEnabled('mc9s12_ExtModeStatMemAlloc', 'off');
        %         actConfigSet.Components(end).Components(end).setPropEnabled('mc9s12_ExtModeStatMemSize', 'off');
        %         actConfigSet.Components(end).Components(end).setPropEnabled('mc9s12_ExtModeStatusBarClk', 'off');
        
    end
    
else
    
    % 'external' mode
    if strcmp(mcBuildPars.resources.ExtMode, 'off')
        
        % option mismatch -> adjust target specific 'ExtMode' option
        mcBuildPars.resources.ExtMode = 'on';
        
        %         % enable all ExtMode options
        %         actConfigSet = getActiveConfigSet(gcs);
        %
        %         % enable options...
        %         actConfigSet.Components(end).Components(end).setPropEnabled('mc9s12_ExtModeRxBufSize', 'on');
        %         actConfigSet.Components(end).Components(end).setPropEnabled('mc9s12_ExtModeTxBufSize', 'on');
        %         actConfigSet.Components(end).Components(end).setPropEnabled('mc9s12_ExtModeBufSizeDisp', 'on');
        %         actConfigSet.Components(end).Components(end).setPropEnabled('mc9s12_ExtModeFifoBufSize', 'on');
        %         actConfigSet.Components(end).Components(end).setPropEnabled('mc9s12_ExtModeFifoBufNum', 'on');
        %         actConfigSet.Components(end).Components(end).setPropEnabled('mc9s12_ExtModeDispCommStatePTT', 'on');
        %         actConfigSet.Components(end).Components(end).setPropEnabled('mc9s12_ExtModeBaudrate', 'on');
        %         actConfigSet.Components(end).Components(end).setPropEnabled('mc9s12_ExtModeHostPort', 'on');
        %         actConfigSet.Components(end).Components(end).setPropEnabled('mc9s12_ExtModeTargetPort', 'on');
        %         actConfigSet.Components(end).Components(end).setPropEnabled('mc9s12_ExtModeStatMemAlloc', 'on');
        %         actConfigSet.Components(end).Components(end).setPropEnabled('mc9s12_ExtModeStatMemSize', 'on');
        %         actConfigSet.Components(end).Components(end).setPropEnabled('mc9s12_ExtModeStatusBarClk', 'on');
        
    end
    
end

if strcmp(mcBuildPars.resources.ExtMode, 'on')
    
    % ExtMode is enabled... determine additional comms parameters
    verb = get_param(gcs, 'RTWVerbose');
    verb = num2str(strcmp(verb, 'on'));
    
    % set parameter 'ExtModeMexArgs' (directly)
    ext_comm_str = [verb ',' mcBuildPars.resources.ExtModeHostPort(4) ',' mcBuildPars.resources.ExtModeBaudrate];
    kk = get_param(gcs, 'ExtModeMexArgs');
    if(~strcmp(deblank(kk), deblank(ext_comm_str)))
        
        % ExtModeMexArgs not yet correctly set -> adjust (directly)
        set_param(gcs, 'ExtModeMexArgs', ext_comm_str);
        
    end
    
    % set parameter 'ExtModeMexFile' (directly)
    set_param(gcs, 'ExtModeMexFile', 'ext_serial_mc9s12_comm');
    
    
    % declare SCI0/1 as MATLAB comms port (adjust resources object)
    if strcmp(mcBuildPars.resources.ExtModeTargetPort, 'SCI0')
        
        % ExtMode uses 'SCI0' -> declare as 'MCOM' (MATLAB comms port)
        mcBuildPars.resources.SCI0 = 'MCOM';
        
    else
        
        % ExtMode uses 'SCI1' -> declare as 'MCOM' (MATLAB comms port)
        mcBuildPars.resources.SCI1 = 'MCOM';
        
    end
    
else
    
    % no external mode -> SCI0 & SCI1 are 'idle'
    mcBuildPars.resources.SCI0 = 'idle';
    mcBuildPars.resources.SCI1 = 'idle';
    
    % disable ExtMode memory management
    if strcmp(mcBuildPars.resources.ExtModeStatMemAlloc, 'on')
        
        % disable ExtModeMalloc (using 'malloc' instead -> ansi-lib)
        mcBuildPars.resources.ExtModeStatMemAlloc = 'off';
        
    end
    
end



%% check consistency of FreePorts settings
function i_checkFreePorts

global mcBuildPars;

% find blocks with tag 'mcTarget_rfCommsCli/Srv' to ensure consistency.
%
% Assumption: These blocks have been tagged using...
%
% >> set_param(gcb, 'Tag', 'mcTarget_rfCommsCli')
% >> save_system
%
% fw-01-09
taggedBlocksTX = find_system(bdroot,  'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'SubSystem', 'Tag', 'mcTarget_freePortCommsTX');
taggedBlocksRX = find_system(bdroot,  'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'SubSystem', 'Tag', 'mcTarget_freePortCommsRX');
taggedBlocks = [taggedBlocksTX; taggedBlocksRX];

% find all possible 'port' parameters (using first block -- all blocks
% should use the same 'FreePort' setting
% nn = get_param(taggedBlocks{1}, 'DialogParameters');
% modified_port_text = nn.port.Enum;

% are there any 'freeport' blocks in the present model?
if ~isempty(taggedBlocks)
    
    % yes -> find current port setting
    numFreePortSCI0 = 0;
    numFreePortSCI1 = 0;
    
    % analyse all used ports...
    for i = 1:length(taggedBlocks)
        
        currPort = get_param(taggedBlocks{i}, 'port');
        
        % update FreePort specifier
        if strcmp(currPort(1:3), 'SCI')
            
            % SCIx -> determine port
            if currPort(4) == '0'
                
                % SCI0 -> declare as 'freeport'
                mcBuildPars.resources.SCI0 = 'frPT';
                numFreePortSCI0 = numFreePortSCI0 + 1;
                
            else
                
                % SCI1 -> declare as 'freeport'
                mcBuildPars.resources.SCI1 = 'frPT';
                numFreePortSCI1 = numFreePortSCI1 + 1;
                
            end
            
        end  % port is 'SCIx'
        
    end  % loop over all freeport blocks
    
    % adjust freeport settings
    mcBuildPars.resources.NumFreePortSCI0 = numFreePortSCI0;
    mcBuildPars.resources.NumFreePortSCI1 = numFreePortSCI1;
    
end


%% set fixed options
function i_setFixedOptions(targetPrefix)

global mcBuildPars;

% determine build style (ActiveX, make)
mcBuildPars.codeGenerator.buildStyle = get_param(gcs, [targetPrefix 'BuildStyle']);

% template makefile name for CodeWarrior
mcBuildPars.compiler.templateMakeFileName = [targetPrefix 'cw.tmf'];


% First microcontroller communications port
mcBuildPars.resources.SCI0 = 'idle';

% Second microcontroller communications port
mcBuildPars.resources.SCI1 = 'idle';

% SCI0 Freeport channels
mcBuildPars.resources.NumFreePortSCI0 = 0;

% SCI1 Freeport channels
mcBuildPars.resources.NumFreePortSCI1 = 0;

% Timer base period
mcBuildPars.resources.TimerBasePeriod = 0;

% Timer prescaler value
mcBuildPars.resources.TimerPrescaler = 0;

% Timer prescaler mask
mcBuildPars.resources.TimerPrescalerMask = 0;

% Timer blocks present
mcBuildPars.resources.HasTimers = 0;

% RFComms blocks present
mcBuildPars.resources.HasRFComms = 0;

% ADC blocks present
mcBuildPars.resources.HasADC = 0;

% RFComms server channels
mcBuildPars.resources.RFCommsServerChannels = 0;

% Fuzzy blocks present
mcBuildPars.resources.HasFuzzyBlocks = 0;

% Onboard DAC blocks present (Dragon-12plus, Rev-E)
mcBuildPars.resources.HasOnBoardDAC = 0;

% MC type ... see 'mc_interpreteUserOption.m' for TargetBoard defs
switch mc_interpreteUserOption(mcBuildPars.resources.TargetBoard)
    
    case 'BSP_DRAGON12'
        
        % microcontroller: MC9S12DP256B
        mcBuildPars.resources.mcType = 'BSP_MC9S12DP256B';
        
    case 'BSP_MINIDRAGONPLUS'
        
        % microcontroller: MC9S12DP256B
        mcBuildPars.resources.mcType = 'BSP_MC9S12DP256B';
        
    case {'BSP_DRAGON12PLUS', 'BSP_MINIDRAGONPLUS2'}
        
        % microcontroller: MC9S12DG256
        mcBuildPars.resources.mcType = 'BSP_MC9S12DG256';
        
    case 'BSP_DRAGONFLY12C128'
        
        % microcontroller: MC9S12C128
        mcBuildPars.resources.mcType = 'BSP_MC9S12C128';
        
    case 'BSP_DRAGONFLY12C32'
        
        % microcontroller: MC9S12C32
        mcBuildPars.resources.mcType = 'BSP_MC9S12C32';
        
    case 'BSP_GENERIC_DG128'
        
        % microcontroller: MC9S12DG128
        mcBuildPars.resources.mcType = 'BSP_MC9S12DG128';
        mcBuildPars.resources.Oscillator = '16 MHz';
        
    otherwise
        
        % unknown micro
        mcBuildPars.resources.mcType = 'UNKNOWN';
        mcBuildPars.resources.Oscillator = '16 MHz';
        
end  % switch

%% check consistency of fuzzy block settings
function i_checkFuzzyBlocks

global mcBuildPars;

% find blocks with tag 'mcTarget_fuzzy' to ensure consistency.
%
% Assumption: These blocks have been tagged using...
%
% >> set_param(gcb, 'Tag', 'mcTarget_fuzzy')
% >> save_system
%
% fw-08-09
taggedBlocks = find_system(bdroot,  'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'SubSystem', 'Tag', 'mcTarget_fuzzy');

% are there any 'fuzzy' blocks in the present model?
if ~isempty(taggedBlocks)
    
    % yes -> set variable 'HasFuzzyBlocks'
    mcBuildPars.resources.HasFuzzyBlocks = true;
    
else
    
    % no -> clear variable 'HasFuzzyBlocks'
    mcBuildPars.resources.HasFuzzyBlocks = false;
    
end



%% check consistency of on-board DAC, Dragon-12plus, Rev-E
function i_checkOnBoardDAC_Dragon12Plus

global mcBuildPars;

% find blocks with tag 'mcTarget_dacDragonOnBoard' to ensure consistency.
%
% Assumption: These blocks have been tagged using...
%
% >> set_param(gcb, 'Tag', 'mcTarget_dacDragonOnBoard')
% >> save_system
%
% fw-01-09
taggedBlocks = find_system(bdroot,  'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'SubSystem', 'Tag', 'mcTarget_dacDragonOnBoard');

% are there any 'fuzzy' blocks in the present model?
if ~isempty(taggedBlocks)
    
    % yes -> set variable 'HasOnBoardDAC'
    mcBuildPars.resources.HasOnBoardDAC = true;
    
else
    
    % no -> clear variable 'HasOnBoardDAC'
    mcBuildPars.resources.HasOnBoardDAC = false;
    
end


%% check consistency of Timer block settings
function i_checkTimers

global mcBuildPars;

% find blocks with tag 'mcTarget_timer' to ensure consistency.
%
% Assumption: These blocks have been tagged using...
%
% >> set_param(gcb, 'Tag', 'mcTarget_timer')
% >> save_system
%
% fw-01-09

% filter out timer blocks and RFComms blocks (both use the timer unit)
MC9S12TimerBlocks      = find_system(bdroot,  'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'SubSystem', 'Tag', 'mcTarget_timer');
MC9S12RFCommsBlocksCli = find_system(bdroot,  'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'SubSystem', 'Tag', 'mcTarget_rfCommsCli');
MC9S12RFCommsBlocksSrv = find_system(bdroot,  'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'SubSystem', 'Tag', 'mcTarget_rfCommsSrv');
MC9S12RFCommsBlocks    = [MC9S12RFCommsBlocksCli; MC9S12RFCommsBlocksSrv];

if ~isempty(MC9S12TimerBlocks)
    
    % model has timer blocks -> determine block settings
    nTimers = length(MC9S12TimerBlocks);
    
    myTimerPeriods  = NaN*ones(nTimers, 1);
    myTimerModes    = NaN*ones(nTimers, 1);
    myTimerChannels = NaN*ones(nTimers, 1);
    
    for ii = 1:nTimers
        
        % find SFunction within this block
        SFblock = find_system(MC9S12TimerBlocks{ii}, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'S-Function');
        
        % get RTWdata of current block
        currTimerBlock = get_param(SFblock{1}, 'RTWdata');
        
        % determine timer settings
        myTimerPeriods(ii)  = str2double(currTimerBlock.timerPeriod);
        myTimerModes(ii)    = str2double(currTimerBlock.timerMode);
        myTimerChannels(ii) = str2double(currTimerBlock.timerChannel);
        
    end
    
    
    % ensure TC7 is not used as core timer
    CoreTimer = mcBuildPars.resources.CoreTimer;
    if strcmp(CoreTimer, 'T7I')
        
        % can't use TC7 as core timer and still have timer blocks...
        error('Model time base currently uses timer TC7. Change to RTI to keep using timer blocks (see the rt9S12Target option pages).')
        
    end
    
    
    % check timer channel allocation
    kk = sort(myTimerChannels);
    mm = find(diff(kk) == 0, 1);
    if any(diff(kk) == 0)
        
        % two blocks use the same timer channel
        error(['Invalid timer channel settings: Timer channel ' num2str(kk(mm)) ' has been allocated more than once.'])
        
    end
    
    
    % check if there are any RFComms blocks
    if ~isempty(MC9S12RFCommsBlocks)
        
        % model also has RFComms blocks
        % -> set one of the TIMER_PRESCALER to 128... (period: 3.4 s)
        myTimerPeriods = [myTimerPeriods 65535/24e6*128];
        
    end
    
    
    % check consistency of all timer periods
    minTimerP = min(myTimerPeriods);
    maxTimerP = max(myTimerPeriods);
    
    % shortest period
    if minTimerP < 10/24e6
        
        % minimu period is too small
        % (assuming this should be at least 10 steps at fCPU)
        error(['Detected invalid timer period setting. The minimum period is ' num2str(minTimerP*1e9) ...
            ' ns. This value should be larger than ' num2str(10/24e6*1e9) ' ns.'])
        
    end
    
    % longest period still valid?
    if floor(maxTimerP/minTimerP) > 65535
        
        % nope (too large a difference between minimum and maximum period)
        error(['Detected invalid timer period setting. The minimum period is ' num2str(minTimerP) ...
            ' whereas the maximum period is ' num2str(maxTimerP) '. These values are too far apart (max/min > 65535)'])
        
    end
    
    % valid settings -> set timer base period
    mcBuildPars.resources.TimerBasePeriod = maxTimerP;
    
    
    % determine ECT resolution as required by the settings of this block
    currPeriod = 65535/24e6;
    
    n = 1;
    while (currPeriod < maxTimerP) && (n < 128)
        
        n = n * 2;
        
        myECTResolution = 1/24e6 * n;
        currPeriod = myECTResolution * 65535;
        
    end
    
    % determine bitmask which defines the chosen prescaler value
    myECTprescalerMask = log(n)/log(2);
    
    % set timer prescale value
    mcBuildPars.resources.TimerPrescaler = n;
    
    % set timer prescale mask
    mcBuildPars.resources.TimerPrescalerMask = myECTprescalerMask;
    
    
    % set macro HAS_TIMERBLOCKS
    myHasTimers = '0x00000000';
    myHasTimers(length(myHasTimers)-1 - myTimerChannels) = '0' + myTimerModes;
    mcBuildPars.resources.HasTimers = myHasTimers;
    
else
    
    % no timer blocks -> clear macro HAS_TIMERBLOCKS
    mcBuildPars.resources.HasTimers = '0x00000000';
    
    % check if there are RFComms blocks
    if ~isempty(MC9S12RFCommsBlocks)
        
        % set prescaler value to 128
        n = 128;
        
        % set timer period to maximum (3.4ish seconds)
        maxTimerP = 65535/24e6*n;
        
        % set timer period mask
        myECTprescalerMask = log(n)/log(2);
        
        % valid settings -> set timer base period
        mcBuildPars.resources.TimerBasePeriod = maxTimerP;
        
        % set timer prescale value
        mcBuildPars.resources.TimerPrescaler = n;
        
        % set timer prescale mask
        mcBuildPars.resources.TimerPrescalerMask = myECTprescalerMask;
        
    end
    
end



%% check consistency of RFComms block settings
function i_checkRFComms

global mcBuildPars;

% find blocks with tag 'mcTarget_rfCommsCli' (Srv) to ensure consistency.
%
% Assumption: These blocks have been tagged using...
%
% >> set_param(gcb, 'Tag', 'mcTarget_rfCommsCli')
% >> save_system
%
% fw-01-09

% filter out RFComms blocks
MC9S12RFCommsBlocksCli = find_system(bdroot,  'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'SubSystem', 'Tag', 'mcTarget_rfCommsCli');
MC9S12RFCommsBlocksSrv = find_system(bdroot,  'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'SubSystem', 'Tag', 'mcTarget_rfCommsSrv');
MC9S12RFCommsBlocks    = [MC9S12RFCommsBlocksCli; MC9S12RFCommsBlocksSrv];

if ~isempty(MC9S12RFCommsBlocks)
    
    % determine RF block types (client / server / both)
    HasServer = 0;
    HasClient = 0;
    
    % check all RFComms blocks
    for ii = 1:length(MC9S12RFCommsBlocks)
        
        if ~isempty(findstr(MC9S12RFCommsBlocks{ii}, 'rfComms_Server'))
            
            HasServer = 1;
            
        end
        
        if ~isempty(findstr(MC9S12RFCommsBlocks{ii}, 'rfComms_Client'))
            
            HasClient = 1;
            
        end
        
    end
    
    
    % combined indicator  ->  0: none  1: Server  2: Client  3: both
    HasRFCommsBlocks = HasServer + 2*HasClient;
    
    % set resource attribute HasRFComms
    mcBuildPars.resources.HasRFComms = HasRFCommsBlocks;
    
    
    % set macro CLIENT_COUNT (server) to the specified number of clients...
    myClients = [];
    for ii = 1:length(MC9S12RFCommsBlocks)
        
        % check 'server' and 'client' blocks
        if ~isempty(findstr(MC9S12RFCommsBlocks{ii}, 'rfComms_Server'))
            
            % model is 'server' -> get current settings
            
            % find SFunction within this block
            SFblock = find_system(MC9S12RFCommsBlocks{ii}, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'S-Function');
            
            % get RTWdata of current block
            ll = get_param(SFblock{1}, 'RTWdata');
            myClients = [myClients str2double(ll.numClient)]; %#ok<AGROW>
            
        elseif ~isempty(findstr(MC9S12RFCommsBlocks{ii}, 'rfComms_Client'))
            
            % model is 'client' -> get current settings
            
            % find SFunction within this block
            SFblock = find_system(MC9S12RFCommsBlocks{ii}, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'S-Function');
            
            % get RTWdata of current block
            ll = get_param(SFblock{1}, 'RTWdata');
            myClients = [myClients str2double(ll.ClientNum)]; %#ok<AGROW>
            
        end
        
    end
    
    myClients = unique(myClients);
    myNumClients = length(myClients);
    
    % set resource attribute RFCommsServerChannels
    mcBuildPars.resources.RFCommsServerChannels = myNumClients;
    
else
    
    % model does not include RFComms blocks
    mcBuildPars.resources.HasRFComms = 0;
    mcBuildPars.resources.RFCommsServerChannels = 0;
    
end


%% check consistency of A/D converter settings
function i_checkADC

global mcBuildPars;

% find blocks with tag 'mcTarget_adc' to ensure consistency.
%
% Assumption: These blocks have been tagged using...
%
% >> set_param(gcb, 'Tag', 'mcTarget_adc')
% >> save_system
%
% fw-02-09
taggedBlocks = find_system(bdroot,  'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'SubSystem', 'Tag', 'mcTarget_adc');

% are there any 'ADC' blocks in the present model?
if ~isempty(taggedBlocks)
    
    % yes -> set variable 'HasADC'
    mcBuildPars.resources.HasADC = true;
    
else
    
    % no -> clear variable 'HasADC'
    mcBuildPars.resources.HasADC = false;
    
end


%% check for presence of DSP block set elements
function i_checkDSPblocks

global mcBuildPars;

% default assumption: no DSP block set -> cannot use DSP blocks
mcBuildPars.resources.HasDSPblocks = false;

% determine if the current model includes any blocks of the DSP block set
a = ver('Signal');
allDSPblockFile = fullfile(mcBuildPars.mcBaseDir, 'bin', 'allDSPblocks.mat');

if ~isempty(a) && exist(allDSPblockFile, 'file')
    
    % Signal Processing Toolbox / DSP blockset installed
    % -> load 'allDSPblocks.mat'
    kk = feval(@load, allDSPblockFile);
    allDSPblocks = kk.allDSPblocks.DSPblocks;
    
    % find all S-Function blocks
    currSFcnBlocks = find_system(gcs, 'FindAll', 'on', 'BlockType', 'S-Function');
    
    % loop over all S-Function blocks in the mdl-file
    for jj = 1:length(currSFcnBlocks)
        
        % fetch MaskType of current block
        currSFcnName = get_param(currSFcnBlocks(jj), 'FunctionName');
        
        if ~isempty(currSFcnName)
            
            % valid mask type -> check for DSP blocks
            if ismember(currSFcnName, allDSPblocks)
                
                % found a DSP block -> need to include library
                mcBuildPars.resources.HasDSPblocks = true;
                
                % we're done..
                break
                
            end
            
        end
        
    end  % for
    
end


%% check for use of fixed point calculus
function i_checkFixedPoint

global mcBuildPars;

% currently disabled (fw-01-09)
% TODO
% TODO
% TODO
mcBuildPars.resources.HasFixedPoint = false;

