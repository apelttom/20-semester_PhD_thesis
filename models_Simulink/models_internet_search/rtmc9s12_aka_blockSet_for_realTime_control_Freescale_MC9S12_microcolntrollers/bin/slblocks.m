function blkStruct = slblocks
%SLBLOCKS Defines the block library for the mc9s12 RT toolbox

% Name of the subsystem which will show up in the
% Simulink Blocksets and Toolboxes subsystem.
blkStruct.Name = sprintf('Real-Time mc9SC12 Toolbox');

% The function that will be called when
% the user double-clicks on this icon.
blkStruct.OpenFcn = 'mc9s12tool';

blkStruct.MaskInitialization = '';

% The argument to be set as the Mask Display for the subsystem.
% You may comment this line out if no specific mask is desired.
%blkStruct.MaskDisplay = ['plot([1:.1:5],', ...
%                         'sin(2*pi*[1:.1:5])./[1:.1:5]./[1:.1:5]);' ...
%                         'text(2.3,.5,''C166tool'')'];

% Define the library list for the Simulink Library browser.
% Return the name of the library model and the name for it
Browser(1).Library = 'mc9s12tool';
Browser(1).Name    = 'Real-Time mc9s12 Toolbox';
Browser(1).IsFlat  = 0;		% Is this library "flat" (i.e. no subsystems)?

blkStruct.Browser = Browser;
% End of slblocks

