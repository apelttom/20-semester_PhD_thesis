%function [timerChannelstr, timerModestr, timerPORTstr, timerPINstr, timerPeriodstr, ECTResolutionstr] = mbc_timer(timerChannel, timerMode, timerOCport, timerOCpin, timerPeriod, sampletime)
function [timerChannelstr, timerModestr, timerPeriodstr, ECTResolutionstr] = mbc_timer(timerChannel, timerMode, timerPeriod, sampletime)

% Check the sample time:
if (sampletime < 0) && (sampletime ~= -1)
    fprintf ('Timer: Inadmissible sample time.\n');
end

% turn timer setting into string
timerChannel = timerChannel - 1;
timerChannelstr = num2str(timerChannel);

mode_strings = {'OC', 'IC'};            % stored as '1' and '2' in RTWdata
timerModestr = mode_strings{timerMode};

timerPeriodstr = num2str(timerPeriod);


% determine ECT resolution as required by the settings of this block
currPeriod = 65535/24e6;
myECTResolution = 1/24e6;

n = 1;
while (currPeriod < timerPeriod) && (n < 128)
    
    n = n * 2;
    
    myECTResolution = 1/24e6 * n;
    currPeriod = myECTResolution * 65535;
    
end



% suggested ECT resolution...
ECTResolutionstr = num2str(myECTResolution);


% % Check port number (OC only)
% if(timerMode == 1)
%     
%     % ensure that port and pin selection are visible
%     set_param(gcb, 'MaskVisibilities', {'on', 'on', 'on', 'on', 'on', 'on' });
%     % set_param(gcb, 'MaskEnables', {'on', 'on', 'on', 'on', 'on', 'on' });
%     
%     port_strings = {'PORTA', 'PORTB', 'PTH', 'PTJ', 'PTM', 'PTP', 'PTS', 'PTT'};
%     ddr_strings = {'DDRA', 'DDRB', 'DDRH', 'DDRJ', 'DDRM', 'DDRP', 'DDRS', 'DDRT'};
%     
%     timerPORTstr = port_strings{timerOCport};
%     timerDDRstr = ddr_strings{timerOCport};
%     % disp([timerPORTstr, ' - ', timerDDRstr])
%     
%     % determine chosen pins
%     timerOCpin = strrep(timerOCpin, '|', ' ');
%     timerOCpin = strrep(timerOCpin, ',', ' ');
%     timerOCpin = strrep(timerOCpin, ';', ' ');
%     
%     % get pin numbers and number of pins
%     pins = str2num(timerOCpin);           % this is the parameter to be passed to the sfunction (numeric)
%     numPins = length(pins);
%     
%     % Check if all pin number are available on the chosen port
%     valid_pin = { [0 1 2 3 4 5 6 7]; ...
%             [0 1 2 3 4 5 6 7]; ...
%             [0 1 2 3 4 5 6 7]; ...
%             [0 1 6 7]; ...
%             [0 1 2 3 4 5 6 7]; ...
%             [0 1 2 3 4 5 6 7]; ...
%             [0 1 2 3 4 5 6 7]; ...
%             [0 1 2 3 4 5 6 7] };
%     
%     % Check the pin number and set pinstr (display)
%     if(any(setdiff(pins, valid_pin{timerOCport})))
%         timerPINstr = '???';
%         fprintf ('Timer: Inadmissible pin number for %d.\n', min(setdiff(pins, valid_pin{timerOCport})));
%     else
%         timerPINstr = [];
%         for(ii = 1:numPins)
%             timerPINstr = [timerPINstr ',' num2str(pins(ii))];
%         end
%         timerPINstr(1) = [];
%     end
%     
%     % assemble mask
%     timerPINmask = 0;
%     for(ii = 1:numPins)
%         timerPINmask = timerPINmask + 2^pins(ii);
%     end
%     
%     % turn mask into string
%     timerPINmaskstr = num2str(timerPINmask);
%     
% else
%     
%     % IC mode -> no port / pin selection
%     set_param(gcb, 'MaskVisibilities', {'on', 'on', 'off', 'off', 'on', 'on' });
%     % set_param(gcb, 'MaskEnables', {'on', 'on', 'off', 'off', 'on', 'on' });
% 
%     timerPORTstr = 'PTT';
%     timerDDRstr  = '-';     % currently not used
%     timerPINmaskstr = '-';  % currently not used
%     timerPINstr = '-';      % currently not used
%     
% end
% 
% 
% % Create resource keywords to be reserved in resource database
% modelRTWFields = struct( 'timerChannel', timerChannelstr, ...
%                          'timerMode', num2str(timerMode), ...
%                          'timerPeriod', timerPeriodstr, ...
%                          'timerResolution', ECTResolutionstr, ...
%                          'timerPORTstr', timerPORTstr, ...
%                          'timerDDRstr', timerDDRstr, ...
%                          'timerPINmaskstr', timerPINmaskstr, ...
%                          'timerPINstr', timerPINstr); 


% Create resource keywords to be reserved in resource database
modelRTWFields = struct( 'timerChannel', timerChannelstr, ...
                         'timerMode', num2str(timerMode), ...
                         'timerPeriod', timerPeriodstr, ...
                         'timerResolution', ECTResolutionstr); 

                     
% Insert modelRTWFields in the I/O block S-Function containing the Tag 'mcTarget_timer'
MC9S12DriverDataBlock = find_system(gcb, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'S-Function', 'Tag', 'mcTarget_timer');
set_param(MC9S12DriverDataBlock{1}, 'RTWdata', modelRTWFields);


%% adjust number of block input and/or output ports...


% de-activate link to library (permanently)
if ~strcmp(get_param(gcb, 'LinkStatus'), 'inactive')
    
    %set_param(gcb, 'LinkStatus', 'inactive')
    set_param(gcb, 'LinkStatus', 'none')
    
end


switch(timerModestr)
    
    case 'OC'
        
        % OC -> produce block input
        
        % delete output port (if required)
        num_now = length (find_system (gcb, 'LookUnderMasks', 'on', 'BlockType', 'Outport'));
        if (num_now == 1)
            
            % disp('deleting output port...');
            
            delete_line (gcb, 'Timer Block/1', 'Out1/1')
            delete_block ([gcb, '/Out1'])
            
            % remove the output port of the 'Timer Block' block
            sPars = get_param ([gcb, '/Timer Block'], 'Parameters');
            sPars = strrep(sPars, 'timerMode', '1');                  % change parameter 'timerMode' to 'OC'
            set_param([gcb, '/Timer Block'], 'Parameters', sPars);    % force input port to disappear
            sPars = strrep(sPars, '1', 'timerMode');                  % restore original parameter 'timerMode'
            set_param([gcb, '/Timer Block'], 'Parameters', sPars);
            
        end
        
        % add input port (if required)
        num_now = length (find_system (gcb, 'LookUnderMasks', 'on', 'BlockType', 'Inport'));
        if (num_now == 0)
            
            % disp('adding input port...');

            % add an input port to the 'Timer Block' block
            sPars = get_param ([gcb, '/Timer Block'], 'Parameters');
            sPars = strrep(sPars, 'timerMode', '1');                  % change parameter 'timerMode' to 'OC'
            set_param([gcb, '/Timer Block'], 'Parameters', sPars);    % force output port to appear
            sPars = strrep(sPars, '1', 'timerMode');                  % restore original parameter 'timerMode'
            set_param([gcb, '/Timer Block'], 'Parameters', sPars);
            
            % add input block
            add_block ('built-in/Inport', [gcb, '/In1'])
            kk = get_param ([gcb, '/In1'], 'Position');
            ll = get_param ([gcb, '/Timer Block'], 'Position');
            set_param ([gcb, '/In1'], 'Position',  [ll(1)-50                 ll(2)+floor((ll(4)-ll(2))/2)-floor((kk(4)-kk(2))/2) ...
                                                    ll(1)-50+(kk(3)-kk(1))   ll(2)+floor((ll(4)-ll(2))/2)-floor((kk(4)-kk(2))/2)+(kk(4)-kk(2))])
            set_param ([gcb, '/In1'], 'FontSize', '12')
            add_line (gcb, 'In1/1', 'Timer Block/1')

        end
        
    case 'IC'
        
        % IC -> produce block output
        
        % delete input port (if required)
        num_now = length (find_system (gcb, 'LookUnderMasks', 'on', 'BlockType', 'Inport'));
        if (num_now == 1)
            
            % disp('deleting input port...');
            
            delete_line (gcb, 'In1/1', 'Timer Block/1')
            delete_block ([gcb, '/In1'])
            
            % remove the input port of the 'Timer Block' block
            sPars = get_param ([gcb, '/Timer Block'], 'Parameters');
            sPars = strrep(sPars, 'timerMode', '2');                  % change parameter 'timerMode' to 'IC'
            set_param([gcb, '/Timer Block'], 'Parameters', sPars);    % force input port to disappear
            sPars = strrep(sPars, '2', 'timerMode');                  % restore original parameter 'timerMode'
            set_param([gcb, '/Timer Block'], 'Parameters', sPars);
            
        end
        
        % add output port (if required)
        num_now = length (find_system (gcb, 'LookUnderMasks', 'on', 'BlockType', 'Outport'));
        if (num_now == 0)
            
            % disp('adding output port...');

            % add an output port to the 'Timer Block' block
            sPars = get_param ([gcb, '/Timer Block'], 'Parameters');
            sPars = strrep(sPars, 'timerMode', '2');                  % change parameter 'timerMode' to 'IC'
            set_param([gcb, '/Timer Block'], 'Parameters', sPars);    % force output port to appear
            sPars = strrep(sPars, '2', 'timerMode');                  % restore original parameter 'timerMode'
            set_param([gcb, '/Timer Block'], 'Parameters', sPars);
            
            % add output block
            add_block ('built-in/Outport', [gcb, '/Out1'])
            kk = get_param ([gcb, '/Out1'], 'Position');
            ll = get_param ([gcb, '/Timer Block'], 'Position');
            set_param ([gcb, '/Out1'], 'Position',  [ll(3)+50                 ll(2)+floor((ll(4)-ll(2))/2)-floor((kk(4)-kk(2))/2) ...
                                                     ll(3)+50+(kk(3)-kk(1))   ll(2)+floor((ll(4)-ll(2))/2)-floor((kk(4)-kk(2))/2)+(kk(4)-kk(2))])
            set_param ([gcb, '/Out1'], 'FontSize', '12')
            add_line (gcb, 'Timer Block/1', 'Out1/1')
            
        end
        
end % switch



% =========================================================================
% synchronize blocks -> resolution has to be the same for all
% only the last block in the model performs this section
% =========================================================================

MC9S12TimerBlocks = find_system(bdroot, 'FollowLinks', 'on', 'BlockType', 'SubSystem', 'Tag', 'mcTarget_timer');

amlast = 0;
myTimerPeriods = [];
myTimerModes = [];
myTimerChannels = [];
myTimerResolutions = [];
for ii = 1:length(MC9S12TimerBlocks)
    
    % find SFunction within this block
    SFblock = find_system(MC9S12TimerBlocks{ii}, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'S-Function');

    % get current settings
    kk = get_param(SFblock{1}, 'RTWdata');

    myTimerPeriods = [myTimerPeriods str2double(kk.timerPeriod)]; %#ok<AGROW>
    myTimerModes = [myTimerModes str2double(kk.timerMode)]; %#ok<AGROW>
    myTimerChannels = [myTimerChannels str2double(kk.timerChannel)]; %#ok<AGROW>
    myTimerResolutions = [myTimerResolutions str2double(kk.timerResolution)]; %#ok<AGROW>
    
    % determine if we're the last timer block to get updated
    if strcmp(MC9S12TimerBlocks{ii}, MC9S12DriverDataBlock{1}) && (ii == length(MC9S12TimerBlocks))
        amlast = 1;
    end
    
end

if amlast == 1
    
    % ECT resolution = maximum resolution of all timer blocks
    myECTResolution = max(myTimerResolutions);
    ECTResolutionstr = num2str(myECTResolution);
    
    % synchronize resolution field of all timer blocks
    for ii = 1:length(MC9S12TimerBlocks)
        
        %% determine parent block (tagged block isn't the one with the mask)
        %currBlock = MC9S12TimerBlocks{ii};
        %currBlock(max(find(currBlock == '/')):end) = [];     % delete last section of the name

        % SYNC: adjust resolution term in all timer blocks of the model
        % find SFunction within this block
        SFblock = find_system(MC9S12TimerBlocks{ii}, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'S-Function');

        % get current settings
        kk = get_param(SFblock{1}, 'RTWdata');

        kk.timerResolution = ECTResolutionstr;

        % IC blocks: adjust 'period' to maximum achievable measurement period
        if(kk.timerMode == '2')
            % IC -> period is set to the maximum possible period
            kk.timerPeriod = num2str(myECTResolution*65535);    % RTWdata
            
            % update mask
            %ll = get_param(currBlock, 'MaskValues');
            %ll{3} = num2str(myECTResolution*65534);             % mask
            %set_param(currBlock, 'MaskValues', ll)
        end
        
        set_param(SFblock{1}, 'RTWdata', kk);
        
    end
    
else
    
    % indicate that the resolution is set by another block
    ECTResolutionstr = 'automatic';
    
end

