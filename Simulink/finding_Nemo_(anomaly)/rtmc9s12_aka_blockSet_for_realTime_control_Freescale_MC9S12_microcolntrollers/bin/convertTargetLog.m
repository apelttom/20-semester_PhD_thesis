%% convert mangled debug target messages
% inputs: log file (ASCII), debugMsgDictionary
% returns: cell array of the converted messages

function outCell = convertTargetLog(logFileName, dbgMsgDict)

% 'uniquify' dbgMsgDict (criterion: crc16ID)
dbgMsgDict = unique(dbgMsgDict, 'crc16ID');

% read log file
fh = fopen(logFileName, 'r');
logText = fscanf(fh, '%s');
fclose(fh);

% display of level info
myLevelTab = {'', '-', '--', '---', '----', '-----'};

% determine the number of mangled messages
[myTokens, startToken, stopToken] = regexp(logText, '\^(\w*)@', 'tokens', 'start', 'end');
[myNonTokens, startNonToken, stopNonToken] = regexp(logText, '@(\w+)\^', 'tokens', 'start', 'end');

% reformat tokens to simple cell arrays
myTokens = [myTokens{:}];
myNonTokens = [myNonTokens{:}];

% number of tokens and non-tokens and elements in total
nTokens = length(myTokens);
nNonTokens = length(myNonTokens);

% initialize output variable
outCell = cell(nTokens + nNonTokens, 2);

outIDX    = 1;
currIDX   = 1;
iToken    = 1;
iNonToken = 1;
while (iToken <= nTokens) && (iNonToken <= nNonTokens)

    % token?
    if currIDX == startToken(iToken)
            
        % token -> store in column #1
        outCell{outIDX, 1} = myTokens{iToken};
        outCell{outIDX, 2} = '';
        outIDX = outIDX + 1;

        % done with this message
        currIDX = stopToken(iToken) + 1;

        % next token
        iToken = iToken + 1;

    elseif currIDX == startNonToken(iNonToken) + 1
        
        % non-Token -> store in column #2
        outCell{outIDX, 1} = '';
        outCell{outIDX, 2} = myNonTokens{iNonToken};
        outIDX = outIDX + 1;
        
        % done with this message
        currIDX = stopNonToken(iNonToken);
        
        % next non-Token
        iNonToken = iNonToken + 1;

    else

        % unexpected gap
        disp(['Unexpected gap at currIDX = ' num2str(currIDX)])
        
        % store in both columns
        outCell{outIDX, 1} = '### GAP ###';
        outCell{outIDX, 2} = '### GAP ###';
        outIDX = outIDX + 1;  % ??? fw-04-10
        
        % increas currIDX until we reach a token or a non-Token
        currIDX = currIDX + 1;
        
    end
    
end  % while

% trim outCell (if necessary)
outCell = outCell(1:outIDX - 1, :);

% only look up every token once
[myUniqueTokens, idxUniqueTokens] = unique(myTokens);
nUniqueTokens = length(myUniqueTokens);

% define [TOKEN ERROR]
errorMsg = mcDebugMsgDictionary('message', '[TOKEN ERROR]', 'crc16ID', '', 'level', '0', 'type', 'error');

% expand mangled messages
errorCount = 0;

% loop over all tokens
for iToken = 1:nUniqueTokens
    
    % token -> look it up in the dictionary
    currToken = myUniqueTokens{iToken};
    
    % index of current token in original field ('myTokens')
	origTokenIdx = idxUniqueTokens(iToken);
    
    % find current token in list of all tokens
    currTokenIdx = find(~strcmp(regexp(outCell(:, 1), currToken, 'match', 'once'), ''));
    
    % look up token in dictionary
    myMsgDef = find(dbgMsgDict, 'isa', 'mcDebugMsgDictionary', 'property', {'crc16ID', currToken});
    
    % found it?
    if isempty(myMsgDef)
        
        % token not found in dictionary
        myMsgDef         = errorMsg;
        myMsgDef.crc16ID = currToken;           % offending CRC
        errorCount       = errorCount + 1;
        
        % is there another start character (^) before the stop character?
        if (origTokenIdx < nTokens) && (startToken(origTokenIdx + 1) < stopToken(origTokenIdx))
            
            % yep -> discard next startToken
            disp('Format error: found a start character where it shouldn''t be...')
            
        end
        
    end  % token found in dictionary
    
    % myMsgDef has now been set to the definition of the current token
    % (or a general error message)
    
    % process each message according to its message type
    switch myMsgDef.type
        
        case 'name'
            
            % store function name
            for ii = 1:length(currTokenIdx)
                outCell{currTokenIdx(ii), 1} = myMsgDef.message;
            end
            
        case 'raw'
            
            % store raw text
            for ii = 1:length(currTokenIdx)
                
                % currently done 'sub-optimally'... fw-04-10
                if strcmp(myMsgDef.message, ' 0x')
                    outCell{currTokenIdx(ii), 1} = [' ' outCell{currTokenIdx(ii) + 1, 2}];
                else
                    outCell{currTokenIdx(ii), 1} = myMsgDef.message;
                end
                
            end
            
        case 'text'
            
            % store function name
            for ii = 1:length(currTokenIdx)

                % determine display level
                myLevel = str2double(myMsgDef.level);

                % assemble display
                outCell{currTokenIdx(ii), 1} = sprintf('%s[%d] %s: %s', myLevelTab{myLevel + 1}, myLevel, outCell{currTokenIdx(ii) - 1, 1}, myMsgDef.message);
                
                % remove used names
                outCell{currTokenIdx(ii) - 1, 1} = '';
                outCell{currTokenIdx(ii) - 1, 2} = '';

            end
            
        case 'NL'
            
            % store delimiter
            for ii = 1:length(currTokenIdx)
                outCell{currTokenIdx(ii), 1} = '\n';
            end
            
        case 'error'
 
            % store error message
            for ii = 1:length(currTokenIdx)
                outCell{currTokenIdx(ii), 1} = ['\n\n' myMsgDef.message ' (' myMsgDef.crc16ID ')\n\n'];
            end
            
    end  % switch
    
end  % for

% display
disp(['Conversion complete. Found ' num2str(errorCount) ' erroneous tokens.'])

% display formatted result
fprintf([outCell{:,1}]);
fprintf('\n\n')


