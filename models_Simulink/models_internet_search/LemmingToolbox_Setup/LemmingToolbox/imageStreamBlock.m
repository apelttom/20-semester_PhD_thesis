function imageStreamBlock(block)
% Level-2 M file S-function for loading image from microscope.


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
function brightImage = getData(folder, index, binning)
    persistent lastFolder images
    if isempty(lastFolder) || ~strcmp(folder, lastFolder)
        imageFileNames = '*.tif';
        folder = strrep(folder, 'matlabroot', matlabroot);
        lastFolder = folder;
        images = dir([folder, '/', imageFileNames]);
    end

    index = mod(index-1, length(images)) + 1;
    brightImage = imread([folder, '/', images(index).name], 'tif');
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
    
    if binning ~= 1
        brightImage = imresize(brightImage, 1 / binning);
    end
%endfunction

%% Initialitzation of the block
function setup(block)
  
  %% Register number of ports
  block.NumInputPorts  = 0;
  block.NumOutputPorts = 1;

  block.OutputPort(1).DatatypeID   = 3; % uint8
  block.OutputPort(1).Complexity   = 'Real';
  block.OutputPort(1).SamplingMode = 'Sample';

  block.SampleTimes = block.DialogPrm(3).Data;
  
  try
        dat = getData(block.DialogPrm(2).Data, 1, block.DialogPrm(1).Data);
  catch
      err = lasterror;
      error('ELemming:MicroscopeError', 'Cannot load image from microscope (%s): %s', err.identifier, err.message);
  end

  block.OutputPort(1).Dimensions = size(dat);
  
  %% Register parameters
  block.NumDialogPrms     = 3;
  block.DialogPrmsTunable = {'Nontunable', 'Nontunable', 'Nontunable'};

  %% Register methods
  block.RegBlockMethod('Outputs', @Output);
  block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
  block.RegBlockMethod('Start', @Start);
  
%endfunction
  
%% Output function of the block
function Output(block)
    try
        block.OutputPort(1).Data = getData(block.DialogPrm(2).Data, block.Dwork(1).Data, block.DialogPrm(1).Data);
        block.Dwork(1).Data = block.Dwork(1).Data + 1;
    catch
        err = lasterror;
        error('ELemming:MicroscopeError', 'Cannot load image from microscope (%s): %s', err.identifier, err.message);
    end
%endfunction

%% Dynamic variable definitions
function DoPostPropSetup(block)
  % Register variables
  block.NumDworks = 1;
  block.Dwork(1).Name = 'currentElement'; 
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 0;
  block.Dwork(1).Complexity      = 'Real';
%endfunction

%% Start function of the block
function Start(block)
    block.Dwork(1).Data = 1;
%endfunction

