% write consistent options set to the model
function mc_writeOptions(model, targetPrefix, modelResources)

myPars = fieldnames(modelResources);
for ii = 1:length(myPars)
    
    % making use of naming convention to automate this: all parameters have
    % the name prefix 'mc9s12_'. The names of the corresponding object 
    % parameters are without this prefix
    currPar = [targetPrefix myPars{ii}];
    
    % ensure no missing parameters can cause an error here...
    try
        
        % set parameter
        feval(@set_param, model, currPar, modelResources.(myPars{ii}));
        
    catch %#ok<CTCH>
        
        % do nothing
        
    end
    
end
