% class constructor for generic base class 'genBC'
%
% fw-12-08

function obj = genBC

% construct generic base class
obj = class(struct('genBCDummyEntry', []), 'genBC');
