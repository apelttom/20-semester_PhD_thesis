% define class structure
%
% implementation for class mcLibraryEntry
%
% fw-01-09

function classStruct = defineClassStruct

classStruct = struct( ...
    'libName', '', ...
    'libVersion', '', ...
    'libBlocksPath', '', ...
    'libBlocks', [] ...
    );
