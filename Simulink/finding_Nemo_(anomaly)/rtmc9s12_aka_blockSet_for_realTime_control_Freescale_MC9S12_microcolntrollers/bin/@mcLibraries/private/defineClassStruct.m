% define class structure
%
% implementation for class mcLibraries
%
% fw-01-09

function classStruct = defineClassStruct

classStruct = struct( ...
    'rtwlib', mcLibraryEntry(1), ...
    'dsplib', mcLibraryEntry(1) ...
    );
