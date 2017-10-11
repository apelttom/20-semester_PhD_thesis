%% search rtmc9s12DebugMsgDictionary for the specified message
% NOTE: uses regular expressions!

function res = findDbgMsg_message(dbgMsgDir, searchMessage, regexpFlag)

% get cell array of all messages
allMessages = { dbgMsgDir.message };

% find matching message entries
if regexpFlag

    % use regular expression search
    myMsgIDX = ~strcmp(regexp(allMessages, searchMessage, 'match', 'once'), '');

else

    % use exact match search
    myMsgIDX = ~strcmp(regexp(allMessages, ['^' searchMessage '$'], 'match', 'once'), '');

end
res = dbgMsgDir(myMsgIDX);

% eliminate double entries
res = unique(res);
