% block mask: freeportTX
function [buf_sizestr, portNamestr, baudratestr, channelstr, data_type_str, sampletime_str] = ...
    mbc_freeporttxd(sampletime, port, baudrate, channel, buf_size, data_type, format)


% de-activate link to library (permanently)
if ~strcmp(get_param(gcb, 'LinkStatus'), 'inactive')
    
    %set_param(gcb, 'LinkStatus', 'inactive')
    set_param(gcb, 'LinkStatus', 'none')
    
end


% Check the sample time:
if (sampletime < 0) && (sampletime ~= -1)

    % invalid sample time
    fprintf ('FreePortCommsTX: Inadmissible sample time !\n');
    sampletime_str = 'invalid';

else

    % valid sample time
    switch sampletime
        
        case -1

            % inherited sample time
            sampletime_str = 'inherited';
            
        case 0

            % 'continuous' sample time
            sampletime_str = 'continuous';

            
        otherwise
            
            % regular sample time specified
            sampletime_str = [num2str(sampletime) ' s'];
            
    end  % switch (sampletime)

end


% Check requested buffer size
if (buf_size < 1) || (buf_size > 100)
    
    % inadmissible buffer size
    fprintf ('FreePortCommsTX: Inadmissible buffer size!\n');
    buf_sizestr = '???';
    
else

    % admissible buffer size
    buf_sizestr = num2str (buf_size);
    
end


% set data conversion type according to the block parameter 'data_type'
myBlocks = find_system(gcb, 'LookUnderMasks', 'all');
DTC = find(~strcmp(regexp(myBlocks, 'Data Type Conversion', 'match', 'once'), ''));

% define data_types as text
data_sz_str = { ...
    'single', ...
    'int8', ...
    'uint8', ...
    'int16', ...
    'uint16', ...
    'int32', ...
    'uint32', ...
    'boolean' ...
    };


% telegram format or raw data?
formatstr = num2str(format);
if format == 1
    
    % raw data
    set_param(gcb, 'MaskVisibilities', {'on', 'on', 'on', 'off', 'on', 'off', 'on' });
    % set_param(gcb, 'MaskEnables', {'on', 'on', 'on', 'off', 'on', 'on', 'on' });
    
    channelstr = '-';
    data_type_str = 'uint8';
    
else
    
    % formatted telegrams
    set_param(gcb, 'MaskVisibilities', {'on', 'on', 'on', 'on', 'on', 'on', 'on' });
    % set_param(gcb, 'MaskEnables', {'on', 'on', 'on', 'on', 'on', 'on', 'on' });
    
    channelstr = num2str (channel);
    data_type_str = data_sz_str{data_type};
    
end


% % get object of the current model
% currMdlObj = get_param(bdroot, 'object');
% 
% % using RTW at all?
% if ~isempty(currMdlObj.RTWOptions)
%     
%     % possibly using RTW -> extract options from 'options string'
%     currRTWOpts = regexp(currMdlObj.RTWOptions, '-a(\w+)=(\w+)', 'tokens');
%     currRTWOpts = [currRTWOpts{:}];
%     currRTWOpts = reshape(currRTWOpts, length(currRTWOpts), 1);
%     currRTWOpts = [currRTWOpts(1:2:end-1), currRTWOpts(2:2:end)];
%     
% end


% define 'portstr' (COMx / SCIx)
switch port
    
    case {1, 2}

        % target sided port (1 = SCI0, 2 = SCI1)
        port = port - 1;
        portstr = num2str(port);
        portNamestr = ['SCI' portstr];

        % running in External Mode?
        ExtMode = get_param(bdroot, 'ExtMode');
        if strcmp(ExtMode, 'on')

            % yes -> ensure this 'freeport' does not clash with the target
            % sided External Mode communications port
            RTWmlPt = get_param(bdroot, 'mc9s12_ExtModeTargetPort');
            RTWmlPt = str2double(RTWmlPt(4));

            % clash between 'freeport' (port) and External mode port (RTWmlPt)?
            if RTWmlPt == port

                % port clash
                fprintf('FreePortCommsRX: The selected free port is used by MATLAB (see RTW options, External Mode)\n');
                portNamestr = 'invalid';

            end

        end  % ExtMode == 'on'
        
    otherwise
        
        % host sided port (3 = COM1, 4 = COM2, ...)
        portstr = num2str(port - 2);
        portNamestr = ['COM' portstr];

end  % switch


% define 'baudratestr'
baudrate_strings = { ...
    '300', ...
    '600', ...
    '1200', ...
    '2400', ...
    '4800', ...
    '9600', ...
    '19200', ...
    '38400', ...
    '57600', ...
    '115200' ...
    };

baudratestr = baudrate_strings{baudrate};

% keep data_type as is (no index adjustment, e.g. 'data_type = data_type-1') 
% -> this makes the first possible parameter ('1') map to the built-in data
% type 'single'  ('0' = 'double'... which we omit here)  --  fw-03-05

%debug
%disp(['mbc_TxD: data type: ' num2str(data_type) ' (' data_type_str ')'])

% set block parameter of the data conversion block
set_param(myBlocks{DTC}, 'DataType', data_type_str);


% check if each communication channel has only been allocated once
mySendBlocks = find_system(bdroot, 'BlockType', 'SubSystem', 'Tag', 'mcTarget_freePortCommsTX');
kk = str2double(get_param(mySendBlocks, 'channel'));
if length(unique(kk)) < length(kk)
    
    % the same channel number has been used more than once...
    disp('FreePortCommsTX: Warning... at least 2 TxD blocks have been allocated the same channel number!')
    
end


% assemble structure RTWdata (used by TLC)
modelRTWFields = struct( ...
    'portStr', portstr, ...
    'portNameStr', portNamestr, ...
    'baudrateStr', baudratestr, ...
    'formatStr', formatstr ...
    );


% Insert modelRTWFields in the I/O block S-Function containing the Tag 
% 'mcTarget_freePortCommsTX'
MC9S12DriverDataBlock = find_system(gcb, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'S-Function', 'Tag', 'mcTarget_freePortCommsTX');
set_param(MC9S12DriverDataBlock{1}, 'RTWdata', modelRTWFields);
