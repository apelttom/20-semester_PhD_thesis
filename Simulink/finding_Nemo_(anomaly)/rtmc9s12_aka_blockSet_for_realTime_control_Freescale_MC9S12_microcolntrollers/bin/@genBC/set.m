% (generic) method SET
%
% fw-06-08

function this = set(this, varargin)

% set all specified properties
for ii = 1:2:length(varargin)

    % set property
    this = dotAccessAssign(this, varargin{ii}, varargin{ii + 1});
    
end
