% CodeWarrior automation for mc9s12 based targets
%
%   This file uses COM automation and invokes the necessary methods via
%   MATLAB's Activex support to invoke Metrowerks CodeWarrior for:
%       - Invoking CodeWarrior (e.g. start a new CodeWarrior session)
%       - Importing a CodeWarrior MCP project file (from an XML file)
%       - Build the project to create a binary
%       - Build and download the binary to the target board
%
% See: Embedded Coder user manual, 
%      Real-Time Workshop Embedded Coder 
%      -> Interfacing to Development Tools
%         -> Interfacing to an Integrated Development Environment 
%            -> Interfacing to the CodeWarrior IDE
%
% fw-01-09

function [errorMsgs, warningMsgs] = mc_cwAutomation(varargin)

global mcBuildPars;


% process input arguments
switch nargin
    
    case 1
        
        % target project
        targetMCP = char(varargin(1));

        % default action: 'build'
        action    = 'build';
        
        % default target name (e.g. 'borrar.mcp')
        targetName = [mcBuildPars.modelName '.mcp'];
        
    case 2
        
        % target project
        targetMCP = varargin{1};
        
        % action as supplied
        action    = varargin{2};
        
        % default target name (e.g. 'borrar.mcp')
        targetName = [mcBuildPars.modelName '.mcp'];
        
    case 3
        
        % target project
        targetMCP = varargin{1};
        
        % action as supplied
        action    = varargin{2};
        
        % target name as supplied
        targetName = varargin{3};
        
    otherwise
        
        error([mfilename, ' supports either one or two input arguments.']);
        
end


% default return parameters
errorMsgs   = {};
warningMsgs = {};


% feedback...
disp(['### Invoking CodeWarrior with action ''' upper(action) '''.'])
disp(['### Target project: ' targetMCP])


% handle all actions
switch lower(action)
    
    case 'build'
        
        % build project 'targetMCP', don't download and run the code
        [errorMsgs, warningMsgs] = i_BuildCW(targetMCP, targetName);

    case 'execute'
        
        % build, download and run project 'targetMCP'
        [errorMsgs, warningMsgs] = i_ExecuteCW(targetMCP, targetName);
        
    case 'kill'
        
        % kill running CW application
        i_CloseCW(i_OpenCW);
        
    otherwise
        
        error([mfilename ' does not provide a method for ' action]);

end  % switch


% done -> inform user
disp(['### Completed target action: ' upper(action)]);





%% local functions

% =========================================================================
function [errorMsgs, warningMsgs, ICodeWarriorApp] = i_BuildCW(targetMCP, targetName)

% open a new CW session
ICodeWarriorApp = i_OpenCW;

% import supplied project 'targetMCP', store as 'targetName'
i_ImportProject(ICodeWarriorApp, targetMCP, targetName);

% remove object code
i_RemoveObjectCode(ICodeWarriorApp);

% build current project
buildMsgs = i_BuildCurrentProject(ICodeWarriorApp);

% determine number of errors / warnings
nErrorMsgs   = buildMsgs.ErrorCount;
nWarningMsgs = buildMsgs.WarningCount;

% retun error messages
if nErrorMsgs == 0

    % no errors
    errorMsgs = {};

else
    
    % fetch error messages
    buildErrors = buildMsgs.Errors;
    
    % there are 'nErrorMsgs' error messages
    errorMsgs = cell(nErrorMsgs, 1);
    for ii = 1:nErrorMsgs
        
        % fetch next error message
        errorMsgs{ii} = buildErrors.Item(ii - 1).MessageText;
        
    end
    
end

% retun warings
if nWarningMsgs == 0

    % no warnings
    warningMsgs = {};

else
    
    % fetch warning messages
    buildWarnings = buildMsgs.Warnings;
    
    % there are 'nWarningMsgs' error messages
    warningMsgs = cell(nWarningMsgs, 1);
    for ii = 1:nWarningMsgs
        
        % fetch next error message
        warningMsgs{ii} = buildWarnings.Item(ii - 1).MessageText;
        
    end
    
end


% =========================================================================
function [errorMsgs, warningMsgs] = i_ExecuteCW(targetMCP, targetName)

% open a new CW session, import and build project
[errorMsgs, warningMsgs, ICodeWarriorApp] = i_BuildCW(targetMCP, targetName);

% 'run' (= debugger -> download)
if isempty(errorMsgs)
    
    % successful build -> download (& possibly launch target code)
    i_ExecuteCurrentProject(ICodeWarriorApp);
    
    % wait a bit... to allow HiWare to open before CW closes
    pause(2);
    
end

% done -> close CW
i_CloseCW(ICodeWarriorApp);


% =========================================================================
function ICodeWarriorApp = i_OpenCW

disp(['### ' mfilename ': Creating COM object to CW']);

try
    
    % create Active-X component
    ICodeWarriorApp = actxserver('CodeWarrior.CodeWarriorApp');
    
    % close all previously opened projects
        i_CloseAllProjects(ICodeWarriorApp);
    
catch ME
    
    % display error message (command window)
    mc_errorMsgNoExit(ME);

end


% =========================================================================
function i_CloseCW(ICodeWarriorApp)

try

    invoke(ICodeWarriorApp, 'Quit', 1);

catch ME
    
    % display error message (command window)
    mc_errorMsgNoExit(ME);

end


% =========================================================================
function i_ImportProject(ICodeWarriorApp, xml_targetMCP, mcp_targetName)

disp(['### ' mfilename ': Importing project ' xml_targetMCP]);

% project name: same as model name
projectName = fullfile(fileparts(xml_targetMCP), mcp_targetName);

try
    
    invoke(ICodeWarriorApp.Application, 'ImportProject', xml_targetMCP, projectName, 1);
    
catch ME
    
    % display error message (command window)
    mc_errorMsgNoExit(ME);

end


% =========================================================================
function i_CloseAllProjects(ICodeWarriorApp)

disp(['### ' mfilename ': Closing all currently opened projects']);

try
    
    % close projects until there are none and try ends
    while ~isempty(ICodeWarriorApp.DefaultProject)
        
        invoke(ICodeWarriorApp.DefaultProject, 'Close');
        
        % ... bug?
        if ~isempty(ICodeWarriorApp.DefaultProject)
            invoke(ICodeWarriorApp.DefaultProject, 'Close');    % twice... !!
        end
        
    end
    
catch ME
    
    % display error message (command window)
    mc_errorMsgNoExit(ME);

end


% =========================================================================
function i_RemoveObjectCode(ICodeWarriorApp)

% try to remove all previously generated object code
try
    
    invoke(ICodeWarriorApp.DefaultProject, 'RemoveObjectCode', 0, 1);
    
catch ME
    
    % display error message (command window)
    mc_errorMsgNoExit(ME);

end


% =========================================================================
function msgs = i_BuildCurrentProject(ICodeWarriorApp)

% try to build the currently active project
try
    
    msgs = invoke(ICodeWarriorApp.DefaultProject, 'BuildAndWaitToComplete');
    
catch ME
    
    % display error message (command window)
    mc_errorMsgNoExit(ME);

end


% =========================================================================
function i_ExecuteCurrentProject(ICodeWarriorApp)

disp(['### ' mfilename ': Starting debugger and downloading...']);

try
    
    invoke(ICodeWarriorApp.DefaultProject, 'BuildWithOptions', 0, 2);
    
catch ME
    
    % display error message (command window)
    mc_errorMsgNoExit(ME);

end
