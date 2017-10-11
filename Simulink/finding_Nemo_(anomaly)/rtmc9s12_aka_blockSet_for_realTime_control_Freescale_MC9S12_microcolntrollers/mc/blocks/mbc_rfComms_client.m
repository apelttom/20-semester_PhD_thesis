function [buf_sizestr, RXTXmodestr, RFchannelstr, clientstr, serverAddressstr, clientAddressstr, channelstr, data_type_str, sampletime_str] = ...
          mbc_rfComms_client(sampletime, RXTXmode, RFchannel, clientNum, serverAddress, clientAddress, channel, buf_size, data_type, format, outformat)

MAX_RFCOM_CHANNELS = 127;
MAX_RFCOM_USERCHANNELS = 10;        % 10 channels per client
MAX_BUF_SIZE = 32;


% de-activate link to library (permanently)
if ~strcmp(get_param(gcb, 'LinkStatus'), 'inactive')
    
    %set_param(gcb, 'LinkStatus', 'inactive')
    set_param(gcb, 'LinkStatus', 'none')
    
end


% check server address
if strcmp(serverAddress(1:2), '0x') == 1 && length(serverAddress) == 10
    
    % general format is ok
    if(~any(setdiff(serverAddress(3:end), ['0' '1' '2' '3' '4' '5' '6' '7' '8' '9' 'a' 'b' 'c' 'd' 'e' 'f' 'A' 'B' 'C' 'D' 'E' 'F'])))

        % accept server address
        serverAddressstr = serverAddress;
        
    else
        
        % found illegal characters
        fprintf ('rfComms_server: Inadmissible server address (not a hexadecimal number).\n');
        
    end
        
else
    
    % overall format not correct
    fprintf ('rfComms_server: Inadmissible server address (length, might not start with ''0x''.\n');
    
end
    
% check client address
if( (strcmp(clientAddress(1:2), '0x') == 1) && (length(clientAddress) == 10) )
    
    % general format is ok
    if(~any(setdiff(clientAddress(3:end), ['0' '1' '2' '3' '4' '5' '6' '7' '8' '9' 'a' 'b' 'c' 'd' 'e' 'f' 'A' 'B' 'C' 'D' 'E' 'F'])))

        % accept client address
        clientAddressstr = clientAddress;
        
    else
        
        % found illegal characters
        fprintf ('rfComms_server: Inadmissible client address (not a hexadecimal number).\n');
        
    end
        
else
    
    % overall format not correct
       fprintf ('rfComms_server: Inadmissible client address (length, might not start with ''0x''.\n');
    
end
        

% assemble 'clients' string (display only)
clientstr = num2str(clientNum);

% select client mask
clientmasks = [ 2, 4, 8, 16, 32 ];
clientmask = clientmasks(clientNum);

% turn mask into string
clientmaskstr = num2str(clientmask);


% Check the sample time:
if ((sampletime < 0) && (sampletime ~= -1))
   fprintf ('RFComms_server: Inadmissible sample time !\n');
   sampletime_str = 'invalid';
else
   if(sampletime == -1)
      sampletime_str = 'inherited';
   else
      if(sampletime == 0)
         sampletime_str = 'continuous';
      else
         sampletime_str = [num2str(sampletime) ' s'];
      end
   end
end


% Check channel number
if ((channel < 0) || (channel > MAX_RFCOM_USERCHANNELS))
   fprintf ('RFComms_server: Inadmissible user channel number !\n');
end


% Check RFchannel number
if ((RFchannel < 0) || (RFchannel > MAX_RFCOM_CHANNELS))
   RFchannelstr = '???';
   fprintf ('RFComms_server: Inadmissible RF channel number !\n');
else
   RFchannelstr = num2str (RFchannel);
end


% Check the number of inputs and adapt the underlying Simulink block to it:
if (buf_size < 1) || (buf_size > MAX_BUF_SIZE)
   fprintf ('RFComms_server: Inadmissible buffer size!\n');
   buf_sizestr = '???';
else
   buf_sizestr = num2str (buf_size);
end


% set RXTXmode string
RXTXmodelabels = {'RX', 'TX'};
RXTXmodestr = RXTXmodelabels{RXTXmode};


% set data conversion type according to the block parameter 'data_type'
myBlocks = find_system(gcb, 'LookUnderMasks', 'all');
DTC = find(~strcmp(regexp(myBlocks, 'Data Type Conversion', 'match', 'once'), ''));

% define data_types as text
data_sz_str={'single', 'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32', 'boolean'};


% telegram format (raw / formatted)
formatstr = num2str(format);

if(format == 1)
    
    if (strcmp(RXTXmodestr, 'TX') == 1)
        set_param(gcb, 'MaskVisibilities', {'on', 'on', 'on', 'on', 'on', 'on', 'off', 'on', 'off', 'on', 'off' });
        % set_param(gcb, 'MaskEnables', {'on', 'on', 'on', 'on', 'on', 'on', 'off', 'on', 'off', 'on', 'off' });
    else
        set_param(gcb, 'MaskVisibilities', {'on', 'on', 'on', 'on', 'on', 'on', 'off', 'on', 'off', 'on', 'on' });
        % set_param(gcb, 'MaskEnables', {'on', 'on', 'on', 'on', 'on', 'on', 'off', 'on', 'off', 'on', 'on' });
    end

    channelstr = '-';
    data_type_str = 'uint8';
    
else

    if (strcmp(RXTXmodestr, 'TX') == 1)
        set_param(gcb, 'MaskVisibilities', {'on', 'on', 'on', 'on', 'on', 'on', 'on', 'on', 'on', 'on', 'off' });
        % set_param(gcb, 'MaskEnables', {'on', 'on', 'on', 'on', 'on', 'on', 'on', 'on', 'on', 'on', 'off' });
    else
        set_param(gcb, 'MaskVisibilities', {'on', 'on', 'on', 'on', 'on', 'on', 'on', 'on', 'on', 'on', 'on' });
        % set_param(gcb, 'MaskEnables', {'on', 'on', 'on', 'on', 'on', 'on', 'on', 'on', 'on', 'on', 'on' });
    end

    channelstr = num2str (channel);
    data_type_str = data_sz_str{data_type};
    
end


% prevent accidental format change on hidden input
if (strcmp(RXTXmodestr, 'TX') == 1)
    outformat = 0;
end

% set block parameter of the data conversion block
if(outformat == 1)
    set_param(myBlocks{DTC}, 'DataType', 'double');
else
    set_param(myBlocks{DTC}, 'DataType', data_type_str);
end


% check if each communication channel has only been allocated once
mySendBlocks = get_param(find_system(gcs, 'LookUnderMasks', 'all', 'Name', 'rfComms_server_sfnc'), 'Parent');    % get all rfComms_server blocks
kk = get_param(mySendBlocks, 'format');                                                                          % raw data / formatted data
myRaw = [];
for ii = 1:length(kk)
    if(findstr(kk{ii}, 'on'))
        myRaw = [myRaw ii]; %#ok<AGROW>
    end
end

% indices of formatted channels
myFormatted = setdiff(1:length(kk), myRaw);

% check formatted data for double channel allocation
if ~isempty(myFormatted)

    kk = get_param(mySendBlocks, 'channel');                                                                     % get user channel number
    kk = double(char(kk) - '0');                                                                                 % turn this into numbers...
    kk = kk(myFormatted);                                                                                        % restrict this to the formatted channels
    if(length(unique(kk)) < length(kk))
        % the same channel number has been used more than once...
        disp('RFComms_client: Warning... at least 2 blocks have been allocated the same user channel number!')
    end
    
end

% Create resource keywords to be reserved in resource database
modelRTWFields = struct( 'format', formatstr, ...
                         'RXTXmode', RXTXmodestr, ...
                         'serverAddress', serverAddressstr, ...
                         'clientAddress', clientAddressstr, ...
                         'RFchannel', RFchannelstr, ...
                         'ClientNum', num2str(clientNum), ...
                         'clientflagmask', clientmaskstr );

%debug
%modelRTWFields

% Insert modelRTWFields in the I/O block S-Function containing the Tag 'MC9S12target_RFCOMMS'
% to set the block 'Tag' use: 
% >> kk = find_system(gcb, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'Name', 'rfComms_client_sfnc')
% >> set_param(kk{:}, 'Tag', 'MC9S12target_RFCOMMS')
% ... then save the block / model (fw-09-06)
MC9S12DriverDataBlockCli = find_system(gcb, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'S-Function', 'Tag', 'mcTarget_rfCommsCli');
MC9S12DriverDataBlockSrv = find_system(gcb, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'S-Function', 'Tag', 'mcTarget_rfCommsSrv');
MC9S12DriverDataBlock    = [MC9S12DriverDataBlockCli; MC9S12DriverDataBlockSrv];
for ii = 1:length(MC9S12DriverDataBlock)
    set_param(MC9S12DriverDataBlock{ii}, 'RTWdata', modelRTWFields);
end



%% adjust number of block input and/or output ports...


% de-activate link to library (permanently)
if ~strcmp(get_param(gcb, 'LinkStatus'), 'inactive')
    
    %set_param(gcb, 'LinkStatus', 'inactive')
    set_param(gcb, 'LinkStatus', 'none')
    
end

switch RXTXmodestr
    
    case 'TX'
        
        % TX -> produce block input
        
        % delete output port (if required)
        num_now = length (find_system (gcb, 'LookUnderMasks', 'on', 'BlockType', 'Outport'));
        if (num_now == 1)
            
            % disp('deleting output port...');
            
            delete_line (gcb, 'Data Type Conversion Out/1', 'Out1/1')
            delete_line (gcb, 'rfComms_client_sfnc/1', 'Data Type Conversion Out/1')
            delete_block ([gcb, '/Data Type Conversion Out'])
            delete_block ([gcb, '/Out1'])
            
            % remove the output port of the 'rfComms_client_sfnc' block
            sPars = get_param ([gcb, '/rfComms_client_sfnc'], 'Parameters');
            sPars = strrep(sPars, 'RXTXmode', '1');                           % change parameter 'RXTXmode' to 'RX'
            set_param([gcb, '/rfComms_client_sfnc'], 'Parameters', sPars);    % force input port to disappear
            sPars = strrep(sPars, '1', 'RXTXmode');                           % restore original parameter 'RXTXmode'
            set_param([gcb, '/rfComms_client_sfnc'], 'Parameters', sPars);
            
        end
        
        % add input port (if required)
        num_now = length (find_system (gcb, 'LookUnderMasks', 'on', 'BlockType', 'Inport'));
        if (num_now == 0)
            
            % disp('adding input port...');

            % add an input port to the 'rfComms_client_sfnc' block
            sPars = get_param ([gcb, '/rfComms_client_sfnc'], 'Parameters');
            sPars = strrep(sPars, 'RXTXmode', '1');                           % change parameter 'RXTXmode' to 'RX'
            set_param([gcb, '/rfComms_client_sfnc'], 'Parameters', sPars);    % force input port to disappear
            sPars = strrep(sPars, '1', 'RXTXmode');                           % restore original parameter 'RXTXmode'
            set_param([gcb, '/rfComms_client_sfnc'], 'Parameters', sPars);
            
            % add input block
            add_block ('built-in/Inport', [gcb, '/In1'])
            add_block ('built-in/DataTypeConversion', [gcb, '/Data Type Conversion In'])

            
            % place 'Data Type Conversion' block
            ll = get_param ([gcb, '/rfComms_client_sfnc'], 'Position');
            set_param ([gcb, '/Data Type Conversion In'], 'Position',  ...
                       [ll(1)-50-70  ll(2)+floor((ll(4)-ll(2))/2)-floor(35/2) ...
                        ll(1)-50     ll(2)+floor((ll(4)-ll(2))/2)-floor(35/2)+35])
            set_param ([gcb, '/Data Type Conversion In'], 'DataType', data_type_str)
            set_param ([gcb, '/Data Type Conversion In'], 'FontSize', '12')

            % place 'output' block
            kk = get_param ([gcb, '/In1'], 'Position');
            ll = get_param ([gcb, '/Data Type Conversion In'], 'Position');
            set_param ([gcb, '/In1'], 'Position', ...
                       [ll(1)-50-(kk(3)-kk(1))   ll(2)+floor((ll(4)-ll(2))/2)-floor((kk(4)-kk(2))/2) ...
                        ll(1)-50                 ll(2)+floor((ll(4)-ll(2))/2)-floor((kk(4)-kk(2))/2)+(kk(4)-kk(2))])
            set_param ([gcb, '/In1'], 'FontSize', '12')
            
            add_line (gcb, 'Data Type Conversion In/1', 'rfComms_client_sfnc/1')
            add_line (gcb, 'In1/1', 'Data Type Conversion In/1')
            
            % made changes -> save
            %save_system;
            
        end
        
    case 'RX'
        
        % RX -> produce block output
        
        % delete input port (if required)
        num_now = length (find_system (gcb, 'LookUnderMasks', 'on', 'BlockType', 'Inport'));
        if (num_now == 1)
            
            % disp('deleting input port...');
            
            delete_line (gcb, 'In1/1', 'Data Type Conversion In/1')
            delete_line (gcb, 'Data Type Conversion In/1', 'rfComms_client_sfnc/1')
            delete_block ([gcb, '/Data Type Conversion In'])
            delete_block ([gcb, '/In1'])
            
            % remove the input port of the 'Timer Block' block
            sPars = get_param ([gcb, '/rfComms_client_sfnc'], 'Parameters');
            sPars = strrep(sPars, 'RXTXmode', '2');                           % change parameter 'RXTXmode' to 'TX'
            set_param([gcb, '/rfComms_client_sfnc'], 'Parameters', sPars);    % force input port to disappear
            sPars = strrep(sPars, '2', 'RXTXmode');                           % restore original parameter 'RXTXmode'
            set_param([gcb, '/rfComms_client_sfnc'], 'Parameters', sPars);
            
        end
        
        % add output port (if required)
        num_now = length (find_system (gcb, 'LookUnderMasks', 'on', 'BlockType', 'Outport'));
        if (num_now == 0)
            
            % disp('adding output port...');

            % add an output port to the 'rfComms_client_sfnc' block
            sPars = get_param ([gcb, '/rfComms_client_sfnc'], 'Parameters');
            sPars = strrep(sPars, 'RXTXmode', '2');                           % change parameter 'RXTXmode' to 'TX'
            set_param([gcb, '/rfComms_client_sfnc'], 'Parameters', sPars);    % force input port to disappear
            sPars = strrep(sPars, '2', 'RXTXmode');                           % restore original parameter 'RXTXmode'
            set_param([gcb, '/rfComms_client_sfnc'], 'Parameters', sPars);

            % add output block
            add_block ('built-in/Outport', [gcb, '/Out1'])
            add_block ('built-in/DataTypeConversion', [gcb, '/Data Type Conversion Out'])

            % place 'Data Type Conversion' block
            ll = get_param ([gcb, '/rfComms_client_sfnc'], 'Position');
            set_param ([gcb, '/Data Type Conversion Out'], 'Position',  ...
                       [ll(3)+50      ll(2)+floor((ll(4)-ll(2))/2)-floor(35/2) ...
                        ll(3)+50+70   ll(2)+floor((ll(4)-ll(2))/2)-floor(35/2)+35])
            set_param ([gcb, '/Data Type Conversion Out'], 'DataType', 'double')
            set_param ([gcb, '/Data Type Conversion Out'], 'FontSize', '12')

            % place 'output' block
            kk = get_param ([gcb, '/Out1'], 'Position');
            ll = get_param ([gcb, '/Data Type Conversion Out'], 'Position');
            set_param ([gcb, '/Out1'], 'Position', ...
                       [ll(3)+50                 ll(2)+floor((ll(4)-ll(2))/2)-floor((kk(4)-kk(2))/2) ...
                        ll(3)+50+(kk(3)-kk(1))   ll(2)+floor((ll(4)-ll(2))/2)-floor((kk(4)-kk(2))/2)+(kk(4)-kk(2))])
            set_param ([gcb, '/Out1'], 'FontSize', '12')
            
            add_line (gcb, 'rfComms_client_sfnc/1', 'Data Type Conversion Out/1')
            add_line (gcb, 'Data Type Conversion Out/1', 'Out1/1')
            
            % made changes -> save
            %save_system;
            
        end
        
end % switch
