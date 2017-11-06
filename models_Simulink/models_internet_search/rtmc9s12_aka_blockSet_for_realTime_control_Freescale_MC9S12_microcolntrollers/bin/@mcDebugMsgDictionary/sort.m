% method SORT
%
% implementation for class rtmc9s12DebugMsgDictionary
%
% fw-08-08

function that = sort(this)

% sort the entries of class rtmc9s12DebugMsgDictionary in ascending order of property crc16ID
[allCrc16IDs, sortIDX] = sort({ this(:).crc16ID });


% return sorted dictionary
that = this(sortIDX);
