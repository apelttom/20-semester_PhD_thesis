%% search rtmc9s12DebugMsgDictionary for the specified property
% returns index of the message in rtmc9s12DebugMsgDictionary (or -1)

function res = findDbgMsg(dbgMsgDir, property, val, varargin)

% check for presence of 'regexpFlag'
if nargin > 3
    
    % additional options need to be specified in pairs!
    if mod(length(varargin), 2)
        error('Properties have to be specified in pairs.')
    end
    
    switch varargin{1}
        
        case 'regexp'
            
            regexpFlag = varargin{2};
            
        otherwise
            
            % all other options (TODO)
            
    end  % switch
    
else

    % default option 'regexpFlag' (off)
    regexpFlag = 0;
    
end

% select search algorithm
switch property

    case 'message'
        res = findDbgMsg_message(dbgMsgDir, val, regexpFlag);
    case 'crc16ID'
        if ischar(val)
            res = findDbgMsg_crc16ID(dbgMsgDir, val, regexpFlag);
        else
            res = findDbgMsg_crc16ID(dbgMsgDir, num2str(val), regexpFlag);
        end
    case 'level'
        if ischar(val)
            res = findDbgMsg_level(dbgMsgDir, val, regexpFlag);
        else
            res = findDbgMsg_level(dbgMsgDir, num2str(val), regexpFlag);
        end
    case 'type'
        res = findDbgMsg_type(dbgMsgDir, val, regexpFlag);
    otherwise
        error(['Unknown property: ' property]);

end  % switch
