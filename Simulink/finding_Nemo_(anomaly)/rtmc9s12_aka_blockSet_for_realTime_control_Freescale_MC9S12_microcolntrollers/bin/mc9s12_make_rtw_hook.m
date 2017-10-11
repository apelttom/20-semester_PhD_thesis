% generic RTW callback dispatcher for the build process of microcontroller 
% targets (eg. rtmc9s12)
%
% fw-01-09

function s = mc9s12_make_rtw_hook(method, modelName, rtwRoot, tmf, buildOpts, buildArgs)

% currently known methods:
%
% 'entry'
% 'before_tlc'
% 'after_tlc'
% 'before_make'
% 'after_make'
% 'exit'
% 'error'

global mcBuildPars;

% default return parameter (status = 'no error')
s = 0;
% collect all build parameters in a central (global) object
if ~exist(mcBuildPars, 'var')
    
    % create object mcBuildPars
    mcBuildPars = mcBuildParameters;
    
    % set base path of the toolbox (only do this once)
    mcBuildPars.mcBaseDir = fileparts(fileparts(mfilename('fullpath')));
    
    % using RTW as code generator -> set appropriate 'codeGenerator' option
    mcBuildPars.codeGenerator.codeGeneratorName = 'RTW';
    
end


% populate entries of object 'mcBuildPars' (new values are added 
% with each call to this script)
mcBuildPars.modelName = modelName;
mcBuildPars.codeGenerator.rtwRoot   = rtwRoot;
mcBuildPars.codeGenerator.tmf       = tmf;
mcBuildPars.codeGenerator.buildOpts = buildOpts;
mcBuildPars.codeGenerator.buildArgs = buildArgs;


% assemble hook function name: 'mc_build_<method>.m'
currHook = ['mc_build_' method];

% check for existence and call hook function
if exist(currHook, 'file')

    % callback exists -> call function
    disp(['### Calling build process hook function ''' currHook '''.'])
    eval(currHook);

end
