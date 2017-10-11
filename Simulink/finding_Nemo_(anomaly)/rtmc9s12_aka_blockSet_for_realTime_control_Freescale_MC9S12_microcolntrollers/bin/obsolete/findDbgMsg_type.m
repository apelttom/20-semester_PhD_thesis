%% search rtmc9s12DebugMsgDictionary for the specified type
% NOTE: uses regular expressions!

function res = findDbgMsg_type(dbgMsgDir, searchType, regexpFlag)

% get cell array of all levels
allTypes = { dbgMsgDir.type };

% find matching message entries
if regexpFlag

    % use regular expression search
    myTypeIDX = ~strcmp(regexp(allTypes, searchType, 'match', 'once'), '');

else

    % use exact match search
    myTypeIDX = ~strcmp(regexp(allTypes, ['^' searchType '$'], 'match', 'once'), '');

end
res = dbgMsgDir(myTypeIDX);

% eliminate double entries
res = unique(res);
