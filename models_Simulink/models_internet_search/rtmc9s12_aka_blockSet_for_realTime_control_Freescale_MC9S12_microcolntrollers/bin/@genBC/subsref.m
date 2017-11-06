% (generic) method SUBSREF
%
% Indexed access to the elements of 'this' class
%
% fw-06-08

function b = subsref(this, index)

% number of references...
nRefs = length(index);

if nRefs == 1

    % simple reference, eg. A(2) or A(1,3) or A(1:4,5) or A.name
    switch index.type

        case '()'

            % ============  indexed access  =============

            % return selected array objects
            b = this(index.subs{:});

        case '{}'

            % ============  cell array access  =============
            
            % return selected cell array objects
            b = this{index.subs{:}};
            
        case '.'

            % ============  dot (structure) access  =============
            
            % virtual function -> implemented as private method of the
            % inheriting class
            b = dotAccess(this, index.subs);
            
    end  % switch index.type

else

    % multi reference, eg. A(3,2).name or A(1:4).name(2)

    % resolve first reference
    b = subsref(this, index(1));

    % recursive call to deal with the remainder...
    b = subsref(b, index(2:end));

end
