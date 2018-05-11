function [imageRed, imageGreen, imageBlue] = scientificOutput(image, cellID, phi_is, phi_sh, xPath, yPath, coneImage, arrowLength, xposAllCells, yposAllCells, glowImage, startTime, visualization, microscopeDirection) %#ok<INUSL,INUSD>
% This function generates the visualization for the PhyB/PIF3 chemotaxis
% localization system.

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

%% Set basic output image colors to gray
if visualization(1)
    % Red light
    imageRed = image;
    imageGreen = image / 2;
    imageBlue = image / 2;
elseif visualization(2)
    % Far red light
    imageRed = image * 2;
    imageGreen = image;
    imageBlue = image;
else
    % No light
    imageRed = image;
    imageGreen = image;
    imageBlue = image;
end
[imageHeight, imageWidth] = size(imageRed);

%% If the position is invalid, return basic microscope image
if ~isnan(cellID) && cellID >= 1
    xpos = xposAllCells(cellID);
    ypos = yposAllCells(cellID);
    
%% Draw path
    validIdx = yPath >= 1 & yPath <= imageHeight & xPath >= 1 & xPath <= imageWidth;
    imageGreen(sub2ind(size(imageRed), yPath(validIdx), xPath(validIdx))) = intmax('uint8');
    imageRed(sub2ind(size(imageRed), yPath(validIdx), xPath(validIdx))) = intmax('uint8');

%% Drawing of the light cone
    if ~isnan(phi_is)
        % Get parameters
        [coneHeightOrg, coneWidthOrg] = size(coneImage); %#ok<ASGLU>

        % Rotate image of light cone
        coneImage = imrotate(coneImage, phi_is * 180/pi, 'nearest');
        coneWidth = size(coneImage, 2);
        coneHeight = size(coneImage, 1);

        % Correction of the position due to the rotating
        dx = round((1-cos(phi_is)) * coneWidthOrg/2 + (coneWidth-coneWidthOrg) / 2);
        dy = round(sin(phi_is)* coneWidthOrg/2);

        % Where to draw the rotated image
        yStart = ypos - floor((coneHeight - 1) / 2) - dy;
        yEnd = ypos + ceil((coneHeight - 1) / 2) - dy;
        xStart = xpos - dx;
        xEnd = xpos + coneWidth - 1 - dx;

        % prevent that image is drawn out of the screen
        deltaYStart = 0;
        if yStart < 1
            deltaYStart = 1 - yStart;
        end
        deltaXStart = 0;
        if xStart < 1
            deltaXStart = 1 - xStart;
        end
        deltaYEnd = 0;
        if yEnd > size(imageRed, 1);
            deltaYEnd = size(imageRed, 1) - yEnd;
        end
        deltaXEnd = 0;
        if xEnd > size(imageRed, 2);
            deltaXEnd = size(imageRed, 2) - xEnd;
        end
        
        if ((1 + deltaYStart) <= (size(coneImage, 1) + deltaYEnd)) && ((1 + deltaXStart) <= (size(coneImage, 2) + deltaXEnd)) ...
                && (yStart + deltaYStart < yEnd + deltaYEnd) && (xStart + deltaXStart < xEnd + deltaXEnd)
            
            coneImage = coneImage(1 + deltaYStart : size(coneImage, 1) + deltaYEnd, 1 + deltaXStart : size(coneImage, 2) + deltaXEnd);

            % Draw cube in yellow.
            imageRed(yStart + deltaYStart : yEnd + deltaYEnd, xStart + deltaXStart : xEnd + deltaXEnd) = uint8(double(imageRed(yStart + deltaYStart : yEnd + deltaYEnd, xStart + deltaXStart : xEnd + deltaXEnd)) .* (coneImage+1));
            imageGreen(yStart + deltaYStart : yEnd + deltaYEnd, xStart + deltaXStart : xEnd + deltaXEnd) = uint8(double(imageGreen(yStart + deltaYStart : yEnd + deltaYEnd, xStart + deltaXStart : xEnd + deltaXEnd)) .* (coneImage+1));
        end
    end

%% Drawing of "should-direction" 
    x_arrow = xpos + round(cos(phi_sh) * (0 : arrowLength));
    y_arrow = ypos + round(-sin(phi_sh) * (0 : arrowLength));
    magnifications = 2:-1/arrowLength:1;
    invalidIdx = x_arrow < 1 | x_arrow > imageWidth | y_arrow < 1 | y_arrow > imageHeight | isnan(x_arrow);
    x_arrow(invalidIdx) = [];
    y_arrow(invalidIdx) = [];
    magnifications(invalidIdx) = [];
    if ~isempty(x_arrow) && ~isempty(y_arrow)
        imageRed(sub2ind(size(imageRed), y_arrow, x_arrow)) = uint8(double(imageRed(sub2ind(size(imageRed), y_arrow, x_arrow))) .* magnifications);
    end
end

%% Highlight all cells
glowWidth = size(glowImage, 1);
half = (glowWidth-1)/2;
for i = find(~isnan(xposAllCells') & ~isnan(yposAllCells'))
    if xposAllCells(i) - half < 1 || xposAllCells(i) + half > imageWidth...
            || yposAllCells(i) - half < 1 || yposAllCells(i) + half > imageHeight
        continue;
    end
    if xposAllCells(i) == xpos && yposAllCells(i) == ypos
        imageGreen(yposAllCells(i) - half : yposAllCells(i) + half, xposAllCells(i) - half : xposAllCells(i) + half) = uint8(double(imageGreen(yposAllCells(i) - half : yposAllCells(i) + half, xposAllCells(i) - half : xposAllCells(i) + half)) .* (1 + glowImage));
        imageRed(yposAllCells(i) - half : yposAllCells(i) + half, xposAllCells(i) - half : xposAllCells(i) + half) = uint8(double(imageRed(yposAllCells(i) - half : yposAllCells(i) + half, xposAllCells(i) - half : xposAllCells(i) + half)) .* (1 + glowImage));
    else
        imageBlue(yposAllCells(i) - half : yposAllCells(i) + half, xposAllCells(i) - half : xposAllCells(i) + half) = uint8(double(imageBlue(yposAllCells(i) - half : yposAllCells(i) + half, xposAllCells(i) - half : xposAllCells(i) + half)) .* (1 + glowImage));
    end
end

%% Print arrow if microscope moved
if ~isnan(microscopeDirection)
    arrowImage = imread([matlabroot, '/toolbox/LemmingToolbox/arrowRight.tif'], 'tif');
    arrowImage = imrotate(arrowImage, microscopeDirection * 180/pi, 'nearest');
    [arrowHeight, arrowWidth, temp] = size(arrowImage); %#ok<NASGU>
    xArrowStart = ceil(imageWidth / 2 - arrowWidth / 2);
    yArrowStart = ceil(imageHeight / 2 - arrowHeight / 2);
    imageRed(yArrowStart : yArrowStart + arrowHeight-1, xArrowStart : xArrowStart + arrowWidth-1) = uint8(imageRed(yArrowStart : yArrowStart + arrowHeight-1, xArrowStart : xArrowStart + arrowWidth-1) + arrowImage(:, :, 1));
    imageGreen(yArrowStart : yArrowStart + arrowHeight-1, xArrowStart : xArrowStart + arrowWidth-1) = uint8(imageGreen(yArrowStart : yArrowStart + arrowHeight-1, xArrowStart : xArrowStart + arrowWidth-1) + arrowImage(:, :, 2));
    imageBlue(yArrowStart : yArrowStart + arrowHeight-1, xArrowStart : xArrowStart + arrowWidth-1) = uint8(imageBlue(yArrowStart : yArrowStart + arrowHeight-1, xArrowStart : xArrowStart + arrowWidth-1) + arrowImage(:, :, 3));
end
