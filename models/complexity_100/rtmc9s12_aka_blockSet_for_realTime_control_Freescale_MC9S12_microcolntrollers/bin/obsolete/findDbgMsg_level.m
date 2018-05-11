%% search rtmc9s12DebugMsgDictionary for the specified level
% NOTE: uses regular expressions!

function res = findDbgMsg_level(dbgMsgDir, searchLevel, regexpFlag)

% get cell array of all levels
allLevels = { dbgMsgDir.level };

% find matching message entries
if regexpFlag

    % use regular expression search
    myLevelIDX = ~strcmp(regexp(allLevels, searchLevel, 'match', 'once'), '');

else

    % use exact match search
    myLevelIDX = ~strcmp(regexp(allLevels, ['^' searchLevel '$'], 'match', 'once'), '');

end
res = dbgMsgDir(myLevelIDX);

% eliminate double entries
res = unique(res);
