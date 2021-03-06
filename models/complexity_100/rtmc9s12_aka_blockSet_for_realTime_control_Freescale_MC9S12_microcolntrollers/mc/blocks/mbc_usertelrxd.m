function [buf_sizestr, channelstr, data_type_str, sampletime_str] = mbc_usertelrxd(sampletime, channel, buf_size, data_type)

MAX_UCOM_CHANNELS = 10;


% de-activate link to library (permanently)
if ~strcmp(get_param(gcb, 'LinkStatus'), 'inactive')
    
    %set_param(gcb, 'LinkStatus', 'inactive')
    set_param(gcb, 'LinkStatus', 'none')
    
end


% Check the sample time:
if sampletime < 0 && sampletime ~= -1
   fprintf ('s0_userData_txd: Inadmissible sample time !\n');
   sampletime_str = 'invalid';
else
   if sampletime == -1
      sampletime_str = 'inherited';
   else
      if sampletime == 0
         sampletime_str = 'continuous';
      else
         sampletime_str = [num2str(sampletime) ' s'];
      end
   end
end

% Check channel number
if channel <  0 || channel >= MAX_UCOM_CHANNELS
   channelstr = '???';
   fprintf ('s0_userData_txd: Inadmissible channel number !\n');
else
   channelstr = num2str (channel);
end

% Check the number of inputs and adapt the underlying Simulink block to it:
if buf_size < 1 || buf_size > 100
   fprintf ('s0_userData_txd: Inadmissible buffer size!\n');
   buf_sizestr = '???';
else
   buf_sizestr = num2str (buf_size);
end

% define data_types as text
data_sz_str = {'single', 'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32', 'boolean'};

% get data_type_string
data_type_str = data_sz_str{data_type};

% keep data_type as is (no index adjustment, e.g. 'data_type = data_type-1') 
% -> this makes the first possible parameter ('1') map to the built-in data
% type 'single'  ('0' = 'double'... which we omit here)  --  fw-03-05

%debug
%disp(['mbc_RxD: data type: ' num2str(data_type) ' (' data_type_str ')'])

% check if each communication channel has only been allocated once
myReceiveBlocks = get_param(find_system(gcs, 'LookUnderMasks', 'all', 'Name', 'RECEIVE_USR_DATA'), 'Parent');     % get all RxD blocks
kk = get_param(myReceiveBlocks, 'channel');                                                                       % get channel number
kk = double(char(kk) - '0');                                                                                      % turn this into numbers...
if(length(unique(kk)) < length(kk))
    % the same channel number has been used more than once...
    disp('s0_userData_rxd: Warning... at least 2 RxD blocks have been allocated the same channel number!')
end
