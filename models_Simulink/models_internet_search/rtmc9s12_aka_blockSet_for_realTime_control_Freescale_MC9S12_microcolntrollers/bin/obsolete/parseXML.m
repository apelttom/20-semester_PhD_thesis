% PARSEXML Convert XML file to a MATLAB structure
% slightly modified to avoid storage of non-tags (fw-05-08)
function theStruct = parseXML(varargin)

% debug stage only: defining a default name...
if nargin == 1
    % determine filenname
    filename = varargin{1};
else
    % default name (debug stage)
    filename = 'rtw_dp256_flash_flat\rtw_dp256_flash_flat.mcp.xml';
end

% read XML
try
    tree = xmlread(filename);
catch
    error('Failed to read XML file %s.', filename);
end

% reCURSE over child nodes. 
% NOTE: This could run into problems with very deeply nested trees.
try
    theStruct = parseChildNodes(tree);
catch
    error('Unable to parse XML file %s.', filename);
end


% ----- Subfunction PARSECHILDNODES -----
function children = parseChildNodes(theNode)
% Recurse over node children.
children = [];
if theNode.hasChildNodes
    childNodes = theNode.getChildNodes;
    numChildNodes = childNodes.getLength;
    allocCell = cell(1, numChildNodes);

    children = struct(             ...
        'Name', allocCell, 'Attributes', allocCell,    ...
        'Data', allocCell, 'Children', allocCell);

    count = 1;
    writeIDX = 1;
    while count <= numChildNodes

        theChild = childNodes.item(count-1);
        theCurrNode = makeStructFromNode(theChild);

        if ~isempty(theCurrNode)

            % valid node -> store
            children(writeIDX) = theCurrNode;
            writeIDX = writeIDX + 1;

        else

            % invalid node (not a tag / just a 'new line') 
            % -> one less node, shorten struct
            children = children(1:end-1);

        end

        % next tag
        count = count + 1;
            
    end

    % avoid storage of zero sized entries
    if all(size(children) == [1 0])
        children = [];
    end

end

% ----- Subfunction MAKESTRUCTFROMNODE -----
function nodeStruct = makeStructFromNode(theNode)
% Create structure of node info.

theNodeName = char(theNode.getNodeName);

% avoid storage of tags beginning with '#' (eg. #text, #comment)
if isempty(strfind(theNodeName, '#')) || strfind(theNodeName, '#') ~= 1

    % valid node (proper tag)
    nodeStruct = struct(                        ...
        'Name', theNodeName,       ...
        'Attributes', parseAttributes(theNode),  ...
        'Data', '',                              ...
        'Children', parseChildNodes(theNode));

    if any(strcmp(methods(theNode), 'getData'))
        nodeStruct.Data = char(theNode.getData);
    else
        % try to read 'local text' (in between the tags)
        mm = theNode.getLastChild;
        if ~isempty(mm) && isempty(regexp(char(mm.getNodeValue), '^\n *', 'once' ))
            % there is a local text in between the tags which isn't just
            % the regular formatting, i.e. one LF (10) followed by a number
            % of space characters (32)
            nodeStruct.Data = mm.getNodeValue;
        else
            % no raw information stored in this tag
            nodeStruct.Data = [];
        end
    end

else

    % indicate the occurrence of a 'non-tag' to the calling function
    nodeStruct = [];

end

% ----- Subfunction PARSEATTRIBUTES -----
function attributes = parseAttributes(theNode)
% Create attributes structure.

attributes = [];
if theNode.hasAttributes
    theAttributes = theNode.getAttributes;
    numAttributes = theAttributes.getLength;
    allocCell = cell(1, numAttributes);
    attributes = struct('Name', allocCell, 'Value', ...
        allocCell);

    for count = 1:numAttributes
        attrib = theAttributes.item(count-1);
        attributes(count).Name = char(attrib.getName);
        attributes(count).Value = char(attrib.getValue);
    end
end
