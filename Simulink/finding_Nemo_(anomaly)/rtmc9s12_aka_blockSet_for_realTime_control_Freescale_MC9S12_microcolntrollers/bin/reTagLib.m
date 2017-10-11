function reTagLib

% known block tags
myTags = { ...
    'mcTarget_rfCommsCli', 'rfComms_client.html'; ...
    'mcTarget_rfCommsSrv', 'rfComms_server.html'; ...
    'mcTarget_dac', 'dac_sfcn_9S12.html'; ...
    'mcTarget_dacDragonOnBoard', 'onboardDAC_sfcn_9S12.html'; ...
    'mcTarget_adc', 'adc_sfcn_9S12.html'; ...
    'mcTarget_digOut', 'digOut_sfcn_9S12.html'; ...
    'mcTarget_digIn', 'digIn_sfcn_9S12.html'; ...
    'mcTarget_pwm', 'pwm_sfcn_9S12.html'; ...
    'mcTarget_pwmServo', 'servo_pwm_sfcn_9S12.html'; ...
    'mcTarget_timer', 'timer_sfcn_9S12.html'; ...
    'mcTarget_sonar', 'sonar_sfcn_9S12.html'; ...
    'mcTarget_freePortCommsTX', 'freePortComms_txd.html'; ...
    'mcTarget_freePortCommsRX', 'freePortComms_rxd.html'; ...
    'mcTarget_fuzzy', 'fuzzy_sfcn_9S12.html' ...
    };

% tag all blocks of the toolbox
libName = fullfile(fileparts(mfilename('fullpath')), 'mc9s12tool.mdl');
load_system(libName);
%open_system(libName);

% unlock library...
if strcmp(get_param(bdroot, 'Lock'), 'on')
	set_param(bdroot, 'Lock', 'off')
end

% save flag
anyChanges = false;

% first pass: check for all tags
allTags = myTags(:, 1);
for kk = 1:length(allTags)

    % next tag
    currTag = allTags{kk, 1};

    allMC9S12DriverBlocks = find_system(bdroot, 'FollowLinks', 'on', 'BlockType', 'SubSystem', 'Tag', currTag);
    nAllMC9S12DriverBlocks = length(allMC9S12DriverBlocks);

    for ll = 1:nAllMC9S12DriverBlocks

        % find the underlying S-Function block
        SFblock = find_system(allMC9S12DriverBlocks{ll}, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'S-Function');
        SFblockTag = get_param(SFblock{1}, 'Tag');

        % matching tags?
        if isempty(SFblockTag) || ~strcmp(SFblockTag, currTag)

            % nope -> correct tag
            set_param(SFblock{1}, 'Tag', currTag)

            % set 'save' flag
            anyChanges = true;

        end  % SFblockTag ~= currTag
        
        % PWM block?
        if strcmp(currTag, 'mcTarget_pwm')

            % yep -> replace SFunction parameters
            oldPara = get_param(SFblock{1}, 'Parameters');
            newPara = 'sampletime, PWMperiod, pulse_pin, sign_port, sign_pin, Vmax, sig_mon';

            % still needs changed?
            if ~strcmp(oldPara, newPara)

                % yep
                set_param(SFblock{1}, 'Parameters', newPara);

                % set 'save' flag
                anyChanges = true;

            end

        end  % PWM block

        % delete RTWdata from parent block
        oldRTWdata = get_param(allMC9S12DriverBlocks{ll}, 'RTWdata');
        
        % need to delete this?
        if ~isempty(oldRTWdata)
            
            % yep
            set_param(allMC9S12DriverBlocks{ll}, 'RTWdata', []);
            
            % set 'save' flag
            anyChanges = true;

        end

    end  % nAllMC9S12DriverBlocks


end  % for(allTags)


% second pass: check for all help texts
allHelpTexts = myTags(:, 2);
for kk = 1:length(allHelpTexts)

    % next help text
    currHelpText = ['web(''' allHelpTexts{kk} ''');'];
    currTag = myTags{kk, 1};

    allMC9S12DriverBlocks = find_system(bdroot, 'FollowLinks', 'on', 'BlockType', 'SubSystem', 'MaskHelp', currHelpText);
    nAllMC9S12DriverBlocks = length(allMC9S12DriverBlocks);

    for ll = 1:nAllMC9S12DriverBlocks

        % ensure the parent block is tagged
        oldParentTag = get_param(allMC9S12DriverBlocks{ll}, 'Tag');

        % missing or incorrect tag?
        if isempty(oldParentTag) || ~strcmp(oldParentTag, currTag)

            % yep
            set_param(allMC9S12DriverBlocks{ll}, 'Tag', currTag);

            % set 'save' flag
            anyChanges = true;

        end
        
        % find the underlying S-Function block
        SFblock = find_system(allMC9S12DriverBlocks{ll}, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'S-Function');
        SFblockTag = get_param(SFblock{1}, 'Tag');

        % matching tags?
        if isempty(SFblockTag) || ~strcmp(SFblockTag, currTag)

            % nope -> correct tag
            set_param(SFblock{1}, 'Tag', currTag)

            % set 'save' flag
            anyChanges = true;

        end  % SFblockTag ~= currTag

        % ADC block?
        if strcmp(currTag, 'mcTarget_adc')

            % yep -> replace initialisation command
            oldInit = get_param(allMC9S12DriverBlocks{ll}, 'MaskInitialization');
            newInit = '[channelsStr, firstChannel, numChannels] = mbc_adcinput(channels);';

            % still needs changed?
            if ~strcmp(oldInit, newInit)

                % yep
                set_param(allMC9S12DriverBlocks{ll}, 'MaskInitialization', newInit);

                % set 'save' flag
                anyChanges = true;

            end

        end  % ADC block

        % PWM block?
        if strcmp(currTag, 'mcTarget_pwm')

            % yep -> replace SFunction parameters
            oldPara = get_param(SFblock{1}, 'Parameters');
            newPara = 'sampletime, PWMperiod, pulse_pin, sign_port, sign_pin, Vmax, sig_mon';

            % still needs changed?
            if ~strcmp(oldPara, newPara)

                % yep
                set_param(SFblock{1}, 'Parameters', newPara);

                % set 'save' flag
                anyChanges = true;

            end

        end  % PWM block

        % delete RTWdata from parent block
        oldRTWdata = get_param(allMC9S12DriverBlocks{ll}, 'RTWdata');
        
        % need to delete this?
        if ~isempty(oldRTWdata)
            
            % yep
            set_param(allMC9S12DriverBlocks{ll}, 'RTWdata', []);
            
            % set 'save' flag
            anyChanges = true;

        end

    end  % nAllMC9S12DriverBlocks


end  % for(allHelpTexts)

% close system
if anyChanges
    
    % save
    close_system(libName, 1);

else

    % don't save
    close_system(libName, 0);

end
