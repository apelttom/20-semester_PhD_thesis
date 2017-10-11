% (generic) method SUBSASGN
%
% Indexed write access to the elements of 'this' class
%
% fw-06-08

function this = subsasgn(this, index, val)

% number of references...
nRefs = length(index);

if nRefs == 1

    % simple reference, eg. A(2) = B or A(1,3) = B or A.name 'hallo'
    switch index.type

        case '()'

            % ============  indexed access  =============

            % set selected array objects
            this(index.subs{:}) = val;

        case '{}'

            % ============  cell array access  =============
            
            % set selected cell array objects
            this{index.subs{:}} = val;
            
        case '.'

            % ============  dot (structure) access  =============
            
            % virtual function -> implemented as private method of the
            % inheriting class
            this = dotAccessAssign(this, index.subs, val);

    end  % switch index.type

else

    % multi reference, eg. A(3,2).name = 'hallo'

    % resolve first reference
    b = subsref(this, index(1));

    % empty struct array?
    if isempty(b) && isa(b, 'struct')
        
        % yes -> replace by 'real' struct
        currFN = fieldnames(b);
        
        % yes -> replace empty object by real object
        eval(['b(1).' char(currFN(1)) ' = [];']);

    end  % isempty(b) && struct

    % recursive call to deal with the remainder...
    b = subsasgn(b, index(2:end), val);
    
    % return modified object
    switch index(1).type

        case '()'

            % ============  indexed access  =============

            % set selected array objects
            this(index(1).subs{:}) = b;

        case '{}'

            % ============  cell array access  =============

            % set selected cell array objects
            this{index(1).subs{:}} = b;

        case '.'

            % ============  dot (structure) access  =============

            % virtual function -> implemented as private method of the
            % inheriting class
            this = dotAccessAssign(this, index(1).subs, b);

    end  % switch index.type

end
