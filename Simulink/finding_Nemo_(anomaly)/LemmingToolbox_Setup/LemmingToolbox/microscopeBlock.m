function microscopeBlock(block)
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
function brightImage = getData(synchron)
    global microscopeController;
    if ~exist('microscopeController', 'var') || isempty(microscopeController)
        error('ELemming:MicroscopeNotInitialized', 'Microscope is not initialized');
    end
    
    jobManager = microscopeController.jobManager;
    job0  = microscopeController.imageJob;
      
    if synchron
        % Make synchron image in the first execution
        jobManager.startJob(job0);
    end
    
    % Get last image from microscope
    brightImageType = char(job0.getLastImageCoding());
    brightImage = reshape(typecast(job0.getNewImagePixels(1000), brightImageType), job0.getLastImageWidth(), job0.getLastImageHeight())';
    
    % Make asynchron image in the latter executions.
    % This image is then used in the next call. Thus, we can continue
    % computing although the microscope is busy.
    jobManager.startAsynchron(job0);
    
    % Convert to uint8
    if strcmpi(class(brightImage), 'uint8') 
        % Filetype already the right one...
    elseif strcmpi(class(brightImage), 'uint16')
        %brightImage = cast(brightImage / (intmax('uint16') / uint16(intmax('uint8'))), 'uint8');   
        brightImage = uint8(brightImage / (intmax('uint16') / uint16(intmax('uint8'))));   
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
%endfunction

%% Initialitzation of the block
function setup(block)
  
  %% Register number of ports
  block.NumInputPorts  = 0;
  block.NumOutputPorts = 1;
  
  block.SampleTimes = block.DialogPrm(1).Data;
  
  %% Setup functional port properties
  block.OutputPort(1).DatatypeID   = 3; % uint8
  block.OutputPort(1).Complexity   = 'Real';
  block.OutputPort(1).SamplingMode = 'Sample';

  try
        dat = getData(true);
  catch
      err = lasterror;
      error('ELemming:MicroscopeError', 'Cannot load image from microscope (%s): %s', err.identifier, err.message);
  end
  block.OutputPort(1).Dimensions = size(dat);
  
  %% Register parameters
  block.NumDialogPrms     = 1;
  block.DialogPrmsTunable = {'Nontunable'};

  %% Register methods
  block.RegBlockMethod('Outputs',                 @Output);
   
%endfunction

%% Output function of the block
function Output(block)
    try
        dat = getData(false);
        block.OutputPort(1).Dimensions = size(dat);
        block.OutputPort(1).Data = dat;
    catch
        err = lasterror;
        error('ELemming:MicroscopeError', 'Cannot load image from microscope (%s): %s', err.identifier, err.message);
    end
%endfunction

