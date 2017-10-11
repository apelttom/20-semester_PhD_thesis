function imageGeneratorBlock(block)
% Level-2 M file S-function for producing a microscope image look-alike from simulation data.


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

%% Function to get the image from the microscope
function brightImage = getData(xpos, ypos, phi_is, binning)
    brightImage = imread([matlabroot, '/toolbox/LemmingToolbox/emptyBackground.tif'], 'tif');
    % Convert to uint8
    if strcmpi(class(brightImage), 'uint8') 
        % Filetype already the right one...
    elseif strcmpi(class(brightImage), 'uint16')
        brightImage = cast(brightImage / (intmax('uint16') / uint16(intmax('uint8'))), 'uint8');   
    elseif strcmpi(class(brightImage), 'uint32')
        brightImage = cast(brightImage / (intmax('uint32') / uint32(intmax('uint8'))), 'uint8');   
    elseif(strcmpi(class(brightImage), 'int8'))
        brightImage = int16(brightImage);
        brightImage(brightImage<0) = int16(intmax('uint8')) + 1 + brightImage(brightImage<0);
        brightImage = cast(brightImage, 'uint8');
    elseif(strcmpi(class(brightImage), 'int16'))
        brightImage = int32(brightImage);
        brightImage(brightImage<0) = int32(intmax('uint16')) + 1 + brightImage(brightImage<0);
        brightImage = cast(brightImage / (int32(intmax('uint16')) / int32(intmax('uint8'))), 'uint16');
    else
        error('MicroscopeAnalysis:ImageTypeNotSupported', 'Only support 8 and 16 bit grayscale images.')
    end
    
    cellImage = imread([matlabroot, '/toolbox/LemmingToolbox/cell4.tif'], 'tif');
    if strcmpi(class(cellImage), 'uint8') 
        % Filetype already the right one...
    elseif strcmpi(class(cellImage), 'uint16')
        cellImage = cast(cellImage / (intmax('uint16') / uint16(intmax('uint8'))), 'uint8');   
    elseif strcmpi(class(cellImage), 'uint32')
        cellImage = cast(cellImage / (intmax('uint32') / uint32(intmax('uint8'))), 'uint8');   
    elseif(strcmpi(class(cellImage), 'int8'))
        cellImage = int16(cellImage);
        cellImage(cellImage<0) = int16(intmax('uint8')) + 1 + cellImage(cellImage<0);
        cellImage = cast(cellImage, 'uint8');
    elseif(strcmpi(class(cellImage), 'int16'))
        cellImage = int32(cellImage);
        cellImage(cellImage<0) = int32(intmax('uint16')) + 1 + cellImage(cellImage<0);
        cellImage = cast(cellImage / (int32(intmax('uint16')) / int32(intmax('uint8'))), 'uint16');
    else
        error('MicroscopeAnalysis:ImageTypeNotSupported', 'Only support 8 and 16 bit grayscale images.')
    end
    
    if binning ~= 1
        brightImage = imresize(brightImage, 1 / binning);
        cellImage = imresize(cellImage, 1 / binning, 'nearest');
    end
    
    for i=1:length(xpos)
        if ~isnan(xpos(i)) && ~isnan(ypos(i)) && ~isnan(phi_is(i))
            cellImage = imrotate(cellImage, -phi_is(i) * 180/pi);

            [height, width] = size(brightImage);
            xpos(i) = round(xpos(i) * width);
            ypos(i) = round(ypos(i) * height);
            [cellHeight, cellWidth] = size(cellImage);
            dxCell = floor(cellWidth / 2);
            dyCell = floor(cellHeight / 2);

            if xpos(i) - dxCell >= 1 && xpos(i) + cellWidth - dxCell - 1 <= width ...
                    && ypos(i) - dyCell >= 1 && ypos(i) + cellHeight - dyCell - 1 <= height
                idxCell = find(cellImage(:) ~= 0);
                [yposBright, xposBright] = ind2sub(size(cellImage), idxCell);
                yposBright = yposBright + ypos(i) - dyCell - 1;
                xposBright = xposBright + xpos(i) - dxCell - 1;
                idxBright = sub2ind(size(brightImage), yposBright, xposBright);
                brightImage(idxBright) = cellImage(idxCell);
            end
        end
    end
%endfunction

%% Initialitzation of the block
function setup(block)
  
  % Sample Time
  block.SampleTimes = block.DialogPrm(1).Data;
  
  %% Register number of ports
  block.NumInputPorts  = 4;
  block.NumOutputPorts = 1;

  % Override input port properties
  % Cell X-Pos
  block.InputPort(1).DatatypeID  = 0; % double
  block.InputPort(1).Complexity  = 'Real';
  block.InputPort(1).SamplingMode = 'Sample';
  block.InputPort(1).Dimensions = block.DialogPrm(3).Data;
  block.InputPort(1).DirectFeedthrough = true;
  
  % Cell Y-Pos
  block.InputPort(2).DatatypeID  = 0; % double
  block.InputPort(2).Complexity  = 'Real';
  block.InputPort(2).SamplingMode = 'Sample';
  block.InputPort(2).Dimensions = block.DialogPrm(3).Data;
  block.InputPort(2).DirectFeedthrough = true;
  
   % Cell phi_is
  block.InputPort(3).DatatypeID  = 0; % double
  block.InputPort(3).Complexity  = 'Real';
  block.InputPort(3).SamplingMode = 'Sample';
  block.InputPort(3).Dimensions = block.DialogPrm(3).Data;
  block.InputPort(3).DirectFeedthrough = true;
  
  % Table-Position
  block.InputPort(4).DatatypeID  = 0; % double
  block.InputPort(4).Complexity  = 'Real';
  block.InputPort(4).SamplingMode = 'Sample';
  block.InputPort(4).Dimensions = 2;
  block.InputPort(4).DirectFeedthrough = true;
  
  % The Image
  block.OutputPort(1).DatatypeID   = 3; % uint8
  block.OutputPort(1).Complexity   = 'Real';
  block.OutputPort(1).SamplingMode = 'Sample';
  try
        dat = getData(NaN, NaN, NaN, block.DialogPrm(2).Data);
  catch
      err = lasterror;
      error('ELemming:MicroscopeError', 'Cannot load empty background image (%s): %s', err.identifier, err.message);
  end
  block.OutputPort(1).Dimensions = size(dat);
  
  %% Register parameters
  block.NumDialogPrms     = 3;
  block.DialogPrmsTunable = {'Nontunable', 'Nontunable', 'Nontunable'};

  %% Register methods
  block.RegBlockMethod('Outputs', @Output);
  
%endfunction
  
%% Output function of the block
function Output(block)
    try
        block.OutputPort(1).Data = getData(block.InputPort(1).Data - block.InputPort(4).Data(1),...
            block.InputPort(2).Data - block.InputPort(4).Data(2),...
            block.InputPort(3).Data, ...
            block.DialogPrm(2).Data);
    catch
        err = lasterror;
        error('ELemming:MicroscopeError', 'Cannot generate microscope look-alike image (%s): %s', err.identifier, err.message);
    end
%endfunction
