%% display converted target debug messages
% inputs: log file name (ASCII) or cell array of already converted messages, debugMsgDictionary
% returns: the converted data as cell array

function convlog = dispTargetLog(tarlog, dbgMsgDict)

% dictionary or filename
if ~strcmp(class(dbgMsgDict), 'mcDebugMsgDictionary')
    
    % not a debug message dictionary
    if ischar(dbgMsgDict)
        
        % possibly a filename
        if exist(dbgMsgDict, 'file')
            
            % file -> load it
            s = load(dbgMsgDict);
            dbgMsgDict = s.debugMsgDictionary;
            clear s;
            
        else
            
            % not a filename either -> issue error
            error('dispTargetLog: Second call-up parameter needs to be a filename or of class ''mcDebugMsgDictionary''')
            
        end
        
    end
    
end
        

% convert
if ischar(tarlog)
    
    % filename given -> convert
    convlog = convertTargetLog(tarlog, dbgMsgDict);
    
elseif iscell(tarlog)
    
    % already converted -> copy to convlog
    convlog = tarlog;
    
else
    
    % unknown format -> error
    error('dispTargetLog: first parameter needs to be the log filename or a previously converted log file (cell array)');
    
end
    
% already converted -> just display
for ii = 1:length(convlog)
    
    % display line by line...
    fprintf(convlog{ii})
    
end
