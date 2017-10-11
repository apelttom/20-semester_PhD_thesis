% (generic) method DISPLAY
% Display the properties of 'this' object
%
% fw-12-08

function display(this)

% ans = ...
if isequal(get(0,'FormatSpacing'), 'compact')
    fprintf([inputname(1) ' =\n'])
else
    fprintf(['\n' inputname(1) ' =\n\n'])
end

% determine fieldnames and their maximum length
% ... exclude dummy entry of base class ('genBC')
objFieldNames = fieldnames(this);
[dummy, idx] = setdiff(objFieldNames, 'genBC');
objFieldNames = objFieldNames(sort(idx));
nObjFieldNames = length(objFieldNames);

% determine longest fieldname
longestFieldName = 0;
for kk = 1:nObjFieldNames

    % check next fieldname
    longestFieldName = max(longestFieldName, length(objFieldNames{kk}));

end

% scalar or non-scalar object?
if ~isscalar(this)

    % non-scalar -> display header and fieldnames
    fprintf(['%dx%d ' class(this) ' object with fields:\n'], size(this));

    % display all fieldnames
    for kk = 1:nObjFieldNames

        % fetch next member
        currObjFieldName = objFieldNames{kk};
        disp(['    ' currObjFieldName]);

    end

    % new line
    fprintf('\n')

else

    % single entry -> display contents
    for kk = 1:nObjFieldNames

        % fetch next member
        currObjFieldName = objFieldNames{kk};

        % cannot use dot notation within inherited methods...
        eval(['currMember = get(this, ''' currObjFieldName ''');']);
        %eval(['currMember = this.' objFieldNames{kk} ';']);

        % assemble line for output
        myLine = eval(['sprintf(''%' num2str(longestFieldName + 6) 's'', [objFieldNames{kk} '' : '']);']);

        if isa(currMember, 'char')
            myLine = strrep(sprintf('%s%s', myLine, currMember), char(10), ' ');
            if length(myLine) > 80
                myLine = [myLine(1:80) ' (...)'];
            end
        elseif isa(currMember, 'cell')
            myLine = sprintf('%s%s', myLine, sprintf('%dx%d cell array object', size(currMember)));
        elseif isa(currMember, 'double')
            if ~any(size(currMember) == 1)
                % matrix
                myLine = sprintf('%s%s', myLine, sprintf('%dx%d double array', size(currMember)));
            else
                myLine = sprintf('%s%s', myLine, num2str(currMember));
            end
        elseif isa(currMember, 'logical')
            if ~any(size(currMember) == 1)
                % matrix
                myLine = sprintf('%s%s', myLine, sprintf('%dx%d logical array', size(currMember)));
            else
                myLine = sprintf('%s%s', myLine, num2str(currMember));
            end
        else
            myLine = sprintf('%s%s', myLine, sprintf('%dx%d %s object', size(currMember), class(currMember)));
        end

        % display it...
        fprintf('%s\n', myLine)

    end  % for

    % new line
    fprintf('\n')

end
