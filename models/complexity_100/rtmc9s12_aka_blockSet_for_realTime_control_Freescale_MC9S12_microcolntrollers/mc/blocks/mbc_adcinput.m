% model block configuration: ADCINPUT
%
% fw-08-10
function [channelsStr, firstChannel, numChannels] = mbc_adcinput(channels)

% turn 'channels' parameter into 'firstChannel' and 'numberChannels'
channels2 = strrep(channels, '-', ':');

% range of input channels?
if ~isempty(findstr(channels2, ':'))
    
    % yep - turn into vector
    channels3 = eval(channels2);
    
    % ensure valid channel number
    firstChannel = channels3(1);
    if firstChannel > 7
        
        % issue warning
        disp('ADC: Invalid channel number (0 - 7)')
        
    end
    
    % limit the requested number of channels to 8
    numChannels = length(channels3);
    if firstChannel + numChannels - 1 > 7
        
        % at most 8 ADC channels per ADC bank
        numChannels = 8 - firstChannel;
        disp(['ADC: Limiting number of channels to ' num2str(numChannels) '.'])
        
    end
    
else
    
    % list of individual channels
    channels2 = strrep(channels, ' ', ',');
    
    % reformat channel list
    while ~isempty(findstr(channels2, ',,'))
        
        % eliminate double commas
        channels2 = strrep(channels2, ',,', ',');
        
    end
    
    % eliminate leading comma
    if channels2(1) == ','
        
        channels2(1) = [];
        
    end
    
    % eliminiate trailing comma
    if channels2(end) == ','
        
        channels2(end) = [];
        
    end
    
    % vectorize and sort channel list
    channels3 = eval(['[' channels2 ']']);
    channels3 = sort(channels3);
    
    % determine requested number of channels
    numChannels = channels3(end) - channels3(1) + 1;
    
    % more than one channel -> using 'continuous sampling'
    firstChannel = channels3(1);
    if numChannels > length(channels3)
        
        disp(['ADC: Increased the requested number of channels (' num2str(length(channels3)) ...
            ') to ' num2str(numChannels) ' consecutive channels.'])
        
    end
    
    % ensure there are at most 8 channels per bank
    if firstChannel + numChannels - 1 > 7
        
        numChannels = 8 - firstChannel;
        disp(['ADC: Limiting number of channels to ' num2str(numChannels) '.'])
        
    end
    
end


%% adjust block mask: text
if numChannels > 1
    
    channelsStr = ['Channels ' num2str(firstChannel) ' - ' num2str(firstChannel + numChannels - 1)];
    
else
    
    channelsStr = ['Channel ' num2str(firstChannel)];
    
end


%% adjust number of block output ports...

% determine current number outputs
currBlkObj = get_param(gcb, 'object');
num_now = length(currBlkObj.PortHandles.Outport);

% modification of number of channels requested?
if numChannels == num_now
    
    % no change -> return
    return
    
else
    
    % modified number of channels
    
    % de-activate link to library (permanently)
    if ~strcmp(get_param(gcb, 'LinkStatus'), 'inactive')
        
        %set_param(gcb, 'LinkStatus', 'inactive')
        set_param(gcb, 'LinkStatus', 'none')
        
    end
    
    % fewer channels than before?
    if numChannels < num_now
        
        % reduced number of channels
        for kk = numChannels + 1 : num_now
            
            % delete superfluous channels
            delete_line(gcb, ['Demux/', num2str(kk)], ['Out' num2str(kk), '/1'])
            delete_block([gcb, '/Out', num2str(kk)])
            
        end
        
        % set adjusted number of channels
        set_param ([gcb, '/Demux'], 'Outputs', num2str(numChannels))
        
    else
        
        % increased number of channels
        set_param([gcb, '/Demux'], 'Outputs', num2str(numChannels))
        
        % add missing channels
        for ii = num_now + 1 : numChannels
            
            % add block outport
            add_block ('built-in/Outport', [gcb, '/Out', num2str(ii)])
            
            % link sFnc block to new outports
            set_param([gcb, '/Out', num2str(ii)], 'Position', get_param ([gcb, '/Out', num2str(ii-1)], 'Position') + [0 45 0 45])
            set_param([gcb, '/Out', num2str(ii)], 'FontSize', '12')
            add_line(gcb, ['Demux/', num2str(ii)], ['Out', num2str(ii), '/1'])
            
        end
        
    end
    
end  % modified number of channel

