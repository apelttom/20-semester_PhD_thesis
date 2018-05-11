function [pulsepinstr, signportstr, signpinstr, periodstr, clkABstr, resolutionstr] = mbc_pwmoutput(sampletime, resolution, PWMperiod, pulse_pin, sign_port, sign_pin, Vmax, sig_mon)

% Check the sample time:
if((sampletime < 0) && (sampletime ~= -1))
    fprintf ('PWM: Inadmissible sample time !\n');
end

% Check the PWM period value
if ((PWMperiod < 0) || (PWMperiod > 179))
    disp('PWM: Inadmissible value for PWM period.')
end

% return period string for display...
periodstr = num2str(PWMperiod);

% feasible period -> check if possible in conjunction with the chosen resolution
if ((resolution == 1) && (PWMperiod > 0.699))
    disp('PWM: Inadmissible value for PWM period in 8-bit mode, switching to 16-bit resolution.')
    resolution = 2;
    kk = find_system(gcb, 'FollowLinks', 'on');
    ll = get_param(kk{:}, 'DialogParameters');
    modified_resolution_text = ll.resolution.Enum;
    set_param(kk{:}, 'resolution', modified_resolution_text{resolution});
end

% valid period -> calculate PWM clock parameters
% base period : 1/[24 MHz] = 42 ns
basePERIOD = 1/24e6;

% check if we need to cascade timers... (1 -> 8-bit, 2 -> 16-bit)
if(resolution == 2)
    cascadeFactor = 256;
    resolutionstr = '16';
else
    cascadeFactor = 1;
    resolutionstr = '8';
end

% determine period settings
useSCL = 2;       % implicit factor '2' of the S(caled) clock
PCK = 0;          % PCK[0-2] can range from 0 to 7  ==>  prescale values /1 ... /128
PWMSCL = 1;       % PWMSCL[0-7] can range from 1 to 256
while(PWMperiod > basePERIOD*256*cascadeFactor*(2^PCK)*useSCL*PWMSCL)
    if(PWMSCL < 256)
        PWMSCL = PWMSCL + 1;
    else
        % exhausted capabilities of PWMSCL -> also use prescaler
        PCK = PCK + 1;          % additional factor 2
        PWMSCL = 128;           % restart period search at 1/2 the PWMSCL value
    end
end

% determine period value
% first part [] is the fraction, second part is the full scale value
myPERIOD = round(PWMperiod/(basePERIOD*256*cascadeFactor*(2^PCK)*useSCL*PWMSCL) * 256*cascadeFactor);
myPERIODstr = num2str(myPERIOD);

% factor 256 is represented by PWMSCL = 0
if(PWMSCL == 256)
    PWMSCL = 0;
end


% set timing variables to be passed to the TLC
PCKstr = num2str(PCK);
PWMSCLstr = num2str(PWMSCL);


% adjust pin numbers (evaluate to '1 ... 8' rather than '0 ... 7')
sign_pin = sign_pin - 1;
pulse_pin = pulse_pin - 1;

% define pulse pin/port strings
pulsepinstr = num2str(pulse_pin);

% make sure the 'pulse_pin' is valid in 16-bit mode...
output_channels_16bit = {'1', '3', '5', '7'};
kk = find_system(gcb, 'FollowLinks', 'on');
ll = get_param(kk{:}, 'DialogParameters');
modified_channel_text = ll.pulse_pin.Enum;
if((resolution == 2) && ~ismember(pulsepinstr, output_channels_16bit))
    disp(['PWM: 16-bit mode only possible on channels 1, 3, 5 or 7  --  adjusting channel from ' num2str(pulse_pin) ' to ' num2str(pulse_pin+1)])
    pulse_pin = pulse_pin + 1;
    pulsepinstr = num2str(pulse_pin);
    set_param(kk{:}, 'pulse_pin', modified_channel_text{pulse_pin+1});
end


% useSCL : indicates if scaled clock is to be used (1) or not (0)
useSCLstr = num2str(useSCL-1);

% determine clock source
PWM_channels_A = { '0', '1', '4', '5' };
if(ismember(pulsepinstr, PWM_channels_A))
    CLKselect = 0;          % A (SA)
    clkABstr = 'A';         % % return clock source string
else
    CLKselect = 1;          % B (SB)
    clkABstr = 'B';         % % return clock source string
end

CLKselectstr = num2str(CLKselect);

% Check port number
port_strings = {'PORTA', 'PORTB', 'PTH', 'PTJ', 'PTM', 'PTP', 'PTS', 'PTT'};
ddr_strings = {'DDRA', 'DDRB', 'DDRH', 'DDRJ', 'DDRM', 'DDRP', 'DDRS', 'DDRT'};
signportstr = port_strings{sign_port};
signportddrstr = ddr_strings{sign_port};


% Check if sign_pin number is available on the chosen port
valid_pin = { [0 1 2 3 4 5 6 7]; ...
    [0 1 2 3 4 5 6 7]; ...
    [0 1 2 3 4 5 6 7]; ...
    [0 1 6 7]; ...
    [0 1 2 3 4 5 6 7]; ...
    [0 1 2 3 4 5 6 7]; ...
    [0 1 2 3 4 5 6 7]; ...
    [0 1 2 3 4 5 6 7] };

% Check the sign pin number and set signpinstr (display)
if(any(setdiff(sign_pin, valid_pin{sign_port})))
    signpinstr = '???';
    fprintf ('PWM: Inadmissible sign pin number for %s.\n', signportstr);
else
    signpinstr = num2str(sign_pin);
end

% assemble masks ('pulse' as well as 'sign')
signpinmask = num2str(2^sign_pin);
pulsepinmask = num2str(2^pulse_pin);

% Create resource keywords to be reserved in resource database
modelRTWFields = struct( 'pulsepinStr', pulsepinstr, ...
    'pulsepinMask', pulsepinmask, ...
    'signportStr', signportstr, ...
    'signportddrStr', signportddrstr, ...
    'signpinMask', signpinmask, ...
    'signpinStr', signpinstr, ...
    'resolutionStr', resolutionstr, ...
    'CLKselectStr', CLKselectstr, ...
    'useSCLStr', useSCLstr, ...
    'PCKStr', PCKstr, ...
    'PWMSCLStr', PWMSCLstr, ...
    'PERIODStr', myPERIODstr );

%debug
%modelRTWFields

% Insert modelRTWFields in the I/O block S-Function containing the Tag 'mcTarget_pwm'
% to set the block 'Tag' use:
% >> kk = get_param(find_system(gcb, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'Name', 'MC'), 'Tag')
% >> set_param(kk{:}, 'Tag', 'mcTarget_pwm')
% ... then save the block / model (fw-02-05)
MC9S12DriverDataBlock = find_system(gcb, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'S-Function', 'Tag', 'mcTarget_pwm');
set_param(MC9S12DriverDataBlock{1}, 'RTWdata', modelRTWFields);


% Check the maximum voltage:
if (Vmax < 0)
    fprintf ('PWM: Maximum voltage has to be positive !\n');
end


% optional: signal monitoring

% replace parameter 'sig_mon' by '0' or '1'
% sPars = get_param ([gcb, '/MC'], 'Parameters');
% sPars = strrep(sPars, 'sig_mon', num2str(sig_mon));
% set_param([gcb, '/MC'], 'Parameters', sPars);

if(sig_mon == 1)

    % check if output needs to be generated
    op = get_param (gcb, 'OutputPorts');

    if isempty(op)

        % yes -> modify mask


        % de-activate link to library (permanently)
        if ~strcmp(get_param(gcb, 'LinkStatus'), 'inactive')
            
            %set_param(gcb, 'LinkStatus', 'inactive')
            set_param(gcb, 'LinkStatus', 'none')
            
        end

        % add block output
        add_block ('built-in/Outport', [gcb, '/Out1']);
        set_param ([gcb, '/Out1'], 'Position', get_param ([gcb, '/In1'], 'Position') + [250 0 250 0])

        % add output port to the 'MC' block
        sPars = get_param ([gcb, '/MC'], 'Parameters');
        sPars = strrep(sPars, 'sig_mon', '1');              % change parameter 'sig_mon' to '1'
        set_param([gcb, '/MC'], 'Parameters', sPars);       % force port to appear...
        sPars = strrep(sPars, '1', 'sig_mon');              % restore original parameter 'sig_mon'
        set_param([gcb, '/MC'], 'Parameters', sPars);

        % connect new MC output port to the new output block
        add_line (gcb, 'MC/1', 'Out1/1', 'autorouting', 'on');

    end

else

    % no signal monitoring -> check if output needs to be deleted
    op = get_param (gcb, 'OutputPorts');

    if ~isempty(op)


        % de-activate link to library (permanently)
        if ~strcmp(get_param(gcb, 'LinkStatus'), 'inactive')
            
            %set_param(gcb, 'LinkStatus', 'inactive')
            set_param(gcb, 'LinkStatus', 'none')
            
        end

        % delete line between the MC port and the output block
        delete_line (gcb, 'MC/1', 'Out1/1');

        % delete output port
        delete_block([gcb, '/Out1']);

        % remove output port of the MC block
        sPars = get_param ([gcb, '/MC'], 'Parameters');
        sPars = strrep(sPars, 'sig_mon', '0');              % change parameter 'sig_mon' to '0'
        set_param([gcb, '/MC'], 'Parameters', sPars);       % force port to disappear
        sPars = strrep(sPars, '0', 'sig_mon');              % restore original parameter 'sig_mon'
        set_param([gcb, '/MC'], 'Parameters', sPars);

    end

end


% =========================================================================
% synchronize blocks -> resolution has to be the same for all
% only the last block in the model performs this section
% =========================================================================

MC9S12PWMBlocks = find_system(bdroot, 'FollowLinks', 'on', 'BlockType', 'SubSystem', 'Tag', 'mcTarget_pwm');

amlast = 0;
myResolution = [];
myCLKselection = [];
mySCLused = [];
myPCK = [];
myPWMSCL = [];
myPERIOD = [];
for ii = 1:length(MC9S12PWMBlocks)
    
    % find SFunction within this block
    SFblock = find_system(MC9S12PWMBlocks{ii}, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'S-Function');

    % get current settings
    kk = get_param(SFblock{1}, 'RTWdata');
    
    myResolution = [myResolution str2double(kk.resolutionStr)]; %#ok<AGROW>
    myCLKselection = [myCLKselection str2double(kk.CLKselectStr)]; %#ok<AGROW>
    mySCLused = [mySCLused str2double(kk.useSCLStr)]; %#ok<AGROW>
    myPCK = [myPCK str2double(kk.PCKStr)]; %#ok<AGROW>

    PWMSCLtemp = str2double(kk.PWMSCLStr);
    if(PWMSCLtemp == 0)
        myPWMSCL = [myPWMSCL 256];               %#ok<AGROW> % '0' stands for '256'
    else
        myPWMSCL = [myPWMSCL PWMSCLtemp];        %#ok<AGROW> % all other values...
    end

    myPERIOD = [myPERIOD str2double(kk.PERIODStr)]; %#ok<AGROW>

    % determine if we're the last timer block to get updated
    if(strcmp(MC9S12PWMBlocks{ii}, MC9S12DriverDataBlock{1}) && (ii == length(MC9S12PWMBlocks)))
        amlast = 1;
    end
end

if(amlast == 1)

    % separate A-clk blocks and B-clk blocks
    Aclks = find(myCLKselection == 0);
    Bclks = find(myCLKselection == 1);

    % synchronize A-blocks
    %myResA = myResolution(Aclks);
    %myCLKselA = myCLKselection(Aclks);
    %mySCLusedA = mySCLused(Aclks);
    myPCKA = myPCK(Aclks);
    myPWMSCLA = myPWMSCL(Aclks);
    %myPERIODA = myPERIOD(Aclks);

    % determine slowest A-clk
    myPCKAslowest = max(myPCKA);
    myPCKAslowest_IDX = (myPCKA == myPCKAslowest);
    myPWMSCLAslowest = max(myPWMSCLA(myPCKAslowest_IDX));
    %myPWMSCLAslowest_IDX = find(myPWMSCLA(myPCKAslowest_IDX) == myPWMSCLAslowest, 1, 'last' );     % max -> can just choose any (doesnt' matter)

    % adjust clock settings of all A-clk blocks to match those of the slowest one
    for ii = 1:length(Aclks)

        % find SFunction within this block
        SFblock = find_system(MC9S12PWMBlocks{Aclks(ii)}, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'S-Function');

        % get current settings
        kk = get_param(SFblock{1}, 'RTWdata');

        % recalculate new period
        %ll = get_param(get_param(MC9S12PWMBlocks{Aclks(ii)}, 'Parent'), 'MaskValues');
        ll = get_param(MC9S12PWMBlocks{Aclks(ii)}, 'MaskValues');
        blockPeriod = str2double(ll{3});

        newPERIOD = round(blockPeriod/(basePERIOD*256*cascadeFactor*(2^myPCKAslowest)*useSCL*myPWMSCLAslowest) * 256*cascadeFactor);
        kk.PERIODStr = num2str(newPERIOD);

        if(myPWMSCLAslowest == 256)
            kk.PWMSCLStr = '0';                             % 256 is encoded as '0'
        else
            kk.PWMSCLStr = num2str(myPWMSCLAslowest);       % all other values are as they are
        end

        kk.PCKStr = num2str(myPCKAslowest);

        % set adjusted parameters
        set_param(SFblock{1}, 'RTWdata', kk);

    end


    % synchronize B-blocks
    %myResB = myResolution(Bclks);
    %myCLKselB = myCLKselection(Bclks);
    %mySCLusedB = mySCLused(Bclks);
    myPCKB = myPCK(Bclks);
    myPWMSCLB = myPWMSCL(Bclks);
    %myPERIODB = myPERIOD(Bclks);

    % determine slowest B-clk
    myPCKBslowest = max(myPCKB);
    myPCKBslowest_IDX = (myPCKB == myPCKBslowest);
    myPWMSCLBslowest = max(myPWMSCLB(myPCKBslowest_IDX));
    %myPWMSCLBslowest_IDX = find(myPWMSCLB(myPCKBslowest_IDX) == myPWMSCLBslowest, 1, 'last' );     % max -> can just choose any (doesnt' matter)

    % adjust clock settings of all B-clk blocks to match those of the slowest one
    for ii = 1:length(Bclks)

        % find SFunction within this block
        SFblock = find_system(MC9S12PWMBlocks{Bclks(ii)}, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'S-Function');

        % get current settings
        kk = get_param(SFblock{1}, 'RTWdata');

        % recalculate new period
        % ll = get_param(get_param(MC9S12PWMBlocks{Bclks(ii)}, 'Parent'), 'MaskValues');
        ll = get_param(MC9S12PWMBlocks{Bclks(ii)}, 'MaskValues');
        blockPeriod = str2double(ll{3});

        newPERIOD = round(blockPeriod/(basePERIOD*256*cascadeFactor*(2^myPCKBslowest)*useSCL*myPWMSCLBslowest) * 256*cascadeFactor);
        kk.PERIODStr = num2str(newPERIOD);

        if(myPWMSCLBslowest == 256)
            kk.PWMSCLStr = '0';                             % 256 is encoded as '0'
        else
            kk.PWMSCLStr = num2str(myPWMSCLBslowest);       % all other values are as they are
        end

        kk.PCKStr = num2str(myPCKBslowest);

        % set adjusted parameters
        set_param(SFblock{1}, 'RTWdata', kk);

    end

    save_system;

end
