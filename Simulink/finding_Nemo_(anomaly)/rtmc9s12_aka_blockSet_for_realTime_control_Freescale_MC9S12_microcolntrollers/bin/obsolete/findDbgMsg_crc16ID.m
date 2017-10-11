%% search rtmc9s12DebugMsgDictionary for the specified crc16ID
% NOTE: uses regular expressions!

function res = findDbgMsg_crc16ID(dbgMsgDir, searchCRC, regexpFlag)

% get cell array of all crc16ID
allCRCs = { dbgMsgDir.crc16ID };

% find matching message entries
if regexpFlag

    % use regular expression search
    myCRCIDX = ~strcmp(regexp(allCRCs, searchCRC, 'match', 'once'), '');

else

    % use exact match search
    myCRCIDX = ~strcmp(regexp(allCRCs, ['^' searchCRC '$'], 'match', 'once'), '');

end
res = dbgMsgDir(myCRCIDX);

% eliminate double entries
res = unique(res);
