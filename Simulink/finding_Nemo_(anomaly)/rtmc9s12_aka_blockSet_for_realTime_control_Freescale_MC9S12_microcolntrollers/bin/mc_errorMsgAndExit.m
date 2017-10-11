% display error message and exit
function mc_errorMsgAndExit(currMFile, ME)

% display error message (command window)
mc_errorMsgNoExit(ME);

% exit
error([currMFile ': ' ME.message])
