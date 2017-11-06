%% convert mangled debug target messages
% inputs: log file (ASCII), debugMsgDictionary
% returns: cell array of the converted messages

function outCell = convertTargetLog(logFileName, dbgMsgDict)

% read log file
fh = fopen(logFileName, 'r');
logText = fscanf(fh, '%s');
fclose(fh);

% display of level info
myLevelTab = {'', '-', '--', '---', '----', '-----'};

% determine the number of mangled messages
stopMsg = strfind(logText, '@');      % indices of '@' (stop) character

% ensure logText ends on '@'
logText(stopMsg(end):end) = [];
logText(end+1) = '@';

startMsg = strfind(logText, '^');     % indices of '^' (start) character

% ensure logText starts with '^'
logText(1:startMsg(1)) = [];
logText = ['^' logText];

% re-count stops
stopMsg = strfind(logText, '@');      % indices of '@' (stop) character

% number of starts and stops can differ (TOKEN ERROR)
nMsgs = min(length(startMsg), length(stopMsg));

% define [TOKEN ERROR]
errorMsg = mcDebugMsgDictionary('message', '[TOKEN ERROR]', 'crc16ID', '', 'level', '0', 'type', 'error');

% expand mangled messages
inIDX = 1;
outText = '';
outCell = {};
errorCount = 0;
for ii = 1:nMsgs

    % feedback
    if mod(ii,50) == 0
        disp(['Converting mangled messages (' num2str(ii) '/' num2str(nMsgs) ')'])
    end

    % non-mangled text?
    if inIDX < startMsg(ii)

        % yes -> copy non-mangled text
        outText = [outText logText(inIDX:startMsg(ii)-1)];

    end

    % are the current start/stop indices plausible?
    if startMsg(ii) < stopMsg(ii)

        % yep -> fetch message
        myMsg = logText(startMsg(ii)+1:stopMsg(ii)-1);

        % at this stage 'myMsg' is set to the next message -> convert
        % some capture tools save the data as unicode ASCII... remove
        % non-ASCII content ('0')
        myMsg(myMsg == 0) = [];

        % look up entry in the dictionary
        myMsgDef = findDbgMsg(dbgMsgDict, 'crc16ID', ['0x' myMsg]);

        if length(myMsgDef) >= 1

            % should never be larger than '1'... just in case.
            myMsgDef = myMsgDef(1);

        else

            % length(myMsgDef) == 0  --  [TOKEN ERROR]
            myMsgDef = errorMsg;
            errorCount = errorCount + 1;

            % is there another start character (^) before the stop character?
            if (ii < nMsgs) && (startMsg(ii+1) < stopMsg(ii))

                % yep -> discard next startMsg
                startMsg(ii+1) = [];
                startMsg(end+1) = startMsg(end);

            end

        end
        
    else
        
        % current message start/stop indices are not plausible 
        % ('^' not before '@')
        myMsgDef = errorMsg;
        errorCount = errorCount + 1;
        
        % discard current stopMsg
        stopMsg(ii) = [];
        stopMsg(end+1) = stopMsg(end);

    end


    % myMsgDef now set to the definition of the current token (or error)
    switch myMsgDef.type

        case 'name'

            % determine function name
            myName = myMsgDef.message;

        case 'text'

            % determine display level
            myLevel = str2double(myMsgDef.level);

            % display
            outText = [outText sprintf('%s[%d] %s: %s', myLevelTab{myLevel + 1}, myLevel, myName, myMsgDef.message)];

            % avoid accidental re-use of outdated information
            myName = 'Unknown Function';

        case 'raw'

            outText = [outText myMsgDef.message];

        case 'NL'

            % delimiter -> store outText in outCell
            outCell{end+1} = [outText '\n'];
            outText = '';

        case 'error'

            outCell{end+1} = [outText '\n\n' myMsgDef.message '\n\n'];
            outText = '';

    end  % switch
    
    % done with this message
    inIDX = stopMsg(ii) + 1;

end  % for all mangled messages

% display
disp(['Conversion complete. Found ' num2str(errorCount) ' erroneous tokens.'])
