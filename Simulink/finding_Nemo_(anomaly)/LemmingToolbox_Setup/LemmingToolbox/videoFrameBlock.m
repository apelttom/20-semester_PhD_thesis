function videoFrameBlock(block)
% This file creates the figure used as the visual output for the blocks in
% the Lemming Toolbox.

% Copyright 2010 Moritz Lang
% This file is part of the E. lemming Matlab / Simulink Toolbox and was
% developed for the iGEM 2010 project of ETH Zurich. For further information, please
% visit http://2010.igem.org/Team:ETHZ_Basel
% 
% The Lemming Toolbox is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% The Lemming Toolbox is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with the Lemming Toolbox.  If not, see
% <http://www.gnu.org/licenses/>.
setup(block);
  
%endfunction


%%
function setup(block)
  % Sample Time
  block.SampleTimes = block.DialogPrm(1).Data;
  
  % Register number of ports
  block.NumInputPorts  = 3;% (R, G, B)
  block.NumOutputPorts = 0; 
  
  % Override output port properties
  % Red
  block.InputPort(1).DatatypeID   = 3; % uint8
  block.InputPort(1).Complexity   = 'Real';
  block.InputPort(1).SamplingMode = 'Sample';
  
  % Green
  block.InputPort(2).DatatypeID   = 3; % uint8
  block.InputPort(2).Complexity   = 'Real';
  block.InputPort(2).SamplingMode = 'Sample';
  
  % Blue
  block.InputPort(3).DatatypeID   = 3; % uint8
  block.InputPort(3).Complexity   = 'Real';
  block.InputPort(3).SamplingMode = 'Sample';
  
   % Register parameters
  block.NumDialogPrms     = 1;
  block.DialogPrmsTunable = {'Nontunable'};

  % Register Callbacks
  block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
  block.RegBlockMethod('Start', @Start);
  block.RegBlockMethod('Outputs', @Outputs);
  block.RegBlockMethod('Terminate', @Terminate);

%endfunction


function DoPostPropSetup(block)

  % Register variables
  block.NumDworks = 1;
  block.Dwork(1).Name = 'figureH'; 
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 0;
  block.Dwork(1).Complexity      = 'Real';
 
%endfunction

function Start(block)
screen_size = get(0, 'ScreenSize');
 block.Dwork(1).Data = figure('WindowStyle','Modal',...
                            'Name','Live Lemming Stream',...
                            'NumberTitle','off',...
                            'Color', 'black',...
                            'Position', [0 0 screen_size(3) screen_size(4)]);     
 set(gca, 'Color', 'black', 'Box', 'off', 'MinorGridLineStyle', 'none', 'Position', [0,0,1,1], 'XTick', [], 'YTick', []);
% axis off;
%endfunction

function Terminate(block)

    if(ishandle(block.Dwork(1).Data))
        close(block.Dwork(1).Data);
    end
%endfunction  
function Outputs(block)

    if(~ishandle(block.Dwork(1).Data))
        return;
    end
    figure(block.Dwork(1).Data);
    imageData = cat(3, block.InputPort(1).Data, block.InputPort(2).Data, block.InputPort(3).Data);
    image(imageData, 'EraseMode', 'none');
    axis image;
    drawnow();
%endfunction
    
