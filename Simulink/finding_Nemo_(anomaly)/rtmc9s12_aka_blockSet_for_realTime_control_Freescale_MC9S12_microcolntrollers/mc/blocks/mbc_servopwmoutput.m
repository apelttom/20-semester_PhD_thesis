function [pulsepinstr, periodstr, clkABstr, resolutionstr] = mbc_servopwmoutput(sampletime, PWMperiod, minwidth, maxwidth, resolution, pulse_pin, Vmax)

% Check the sample time:
if (sampletime < 0) && (sampletime ~= -1)
    fprintf ('Servo motor PWM: Inadmissible sample time !\n');
end

% feasible period -> check if possible in conjunction with the chosen resolution
if (resolution == 1) && (PWMperiod > 0.699)
    disp('Servo motor PWM: Inadmissible value for PWM period in 8-bit mode, switching to 16-bit resolution.')
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

% period... for display
periodstr = num2str(PWMperiod);

% determine period settings
useSCL = 2;       % implicit factor '2' of the S(caled) clock
PCK = 0;          % PCK[0-2] can range from 0 to 7  ==>  prescale values /1 ... /128
PWMSCL = 1;       % PWMSCL[0-7] can range from 1 to 256
while(PWMperiod > basePERIOD*256*cascadeFactor*(2^PCK)*useSCL*PWMSCL)
    if PWMSCL < 256
        PWMSCL = PWMSCL + 1;
    else
        % exhausted capabilities of PWMSCL -> also use prescaler
        PCK = PCK + 1;
        PWMSCL = 128;           % restart period search at 1/2 the PWMSCL value
    end
end

% determine period value
% first part [] is the fraction, second part is the full scale value
myPERIOD = round(PWMperiod/(basePERIOD*256*cascadeFactor*(2^PCK)*useSCL*PWMSCL) * 256*cascadeFactor);
myPERIODstr = num2str(myPERIOD);

% determine minimum and maximum duty cycle
mydutyMIN = round(minwidth/(basePERIOD*256*cascadeFactor*(2^PCK)*useSCL*PWMSCL) * 256*cascadeFactor);
mydutyMINstr = num2str(mydutyMIN);
mydutyMAX = round(maxwidth/(basePERIOD*256*cascadeFactor*(2^PCK)*useSCL*PWMSCL) * 256*cascadeFactor);
mydutyMAXstr = num2str(mydutyMAX);

% factor 256 is represented by PWMSCL = 0
if(PWMSCL == 256)
    PWMSCL = 0;
end


% set timing variables to be passed to the TLC
PCKstr = num2str(PCK);
PWMSCLstr = num2str(PWMSCL);


% adjust pin numbers (evaluate to '1 ... 8' rather than '0 ... 7')
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


% assemble masks ('pulse' as well as 'sign')
pulsepinmask = num2str(2^pulse_pin);

% Create resource keywords to be reserved in resource database
modelRTWFields = struct( 'pulsepinStr', pulsepinstr, ...
    'pulsepinMask', pulsepinmask, ...
    'resolutionStr', resolutionstr, ...
    'CLKselectStr', CLKselectstr, ...
    'useSCLStr', useSCLstr, ...
    'PCKStr', PCKstr, ...
    'PWMSCLStr', PWMSCLstr, ...
    'dutyMINStr', mydutyMINstr, ...
    'dutyMAXStr', mydutyMAXstr, ...
    'PERIODStr', myPERIODstr );

%debug
%modelRTWFields

% Insert modelRTWFields in the I/O block S-Function containing the Tag 'MC9S12DriverDataBlock'
% to set the block 'Tag' use:
% >> kk = find_system(gcb, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'Name', 'servo pwm')
% >> set_param(kk{:}, 'Tag', 'mcTarget_pwmServo')
% ... then save the block / model (fw-02-05)
MC9S12DriverDataBlock = find_system(gcb, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'S-Function', 'Tag', 'mcTarget_pwmServo');
set_param(MC9S12DriverDataBlock{1}, 'RTWdata', modelRTWFields);


% Check the maximum voltage:
if (Vmax < 0)
    fprintf ('Servo motor PWM: Saturation level has to be positive !\n');
end


% =========================================================================
% synchronize blocks -> resolution has to be the same for all
% only the last block in the model performs this section
% =========================================================================

MC9S12PWMBlocks = find_system(bdroot, 'FollowLinks', 'on', 'BlockType', 'SubSystem', 'Tag', 'mcTarget_pwmServo');

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
    myCLKselection = [myCLKselection str2double(kk.CLKselectStr)];
    mySCLused = [mySCLused str2double(kk.useSCLStr)];
    myPCK = [myPCK str2double(kk.PCKStr)];

    PWMSCLtemp = str2double(kk.PWMSCLStr);
    if(PWMSCLtemp == 0)
        myPWMSCL = [myPWMSCL 256];               % '0' stands for '256'
    else
        myPWMSCL = [myPWMSCL PWMSCLtemp];        % all other values...
    end

    myPERIOD = [myPERIOD str2double(kk.PERIODStr)];

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
        %ll = get_param(get_param(MC9S12PWMBlocks{Bclks(ii)}, 'Parent'), 'MaskValues');
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


% disp(pulsepinstr)
% disp(periodstr)
% disp(clkABstr)
% disp(resolutionstr)

