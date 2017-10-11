% display error message
function mc_errorMsgNoExit(ME)

disp(' ')
disp('---------------------------------------------------------')
disp(['Message: ' ME.message]);
disp(['Identifier: ' ME.identifier]);

myStack = cell(length(ME.stack), 1);
for ii = 1:length(ME.stack)
    myStack{ii} = [ME.stack(ii).file, ' : ', ME.stack(ii).name];
end
disp('Function call stack:')
disp(strvcat(myStack)); %#ok<VCAT>
disp('---------------------------------------------------------')
disp(' ')
