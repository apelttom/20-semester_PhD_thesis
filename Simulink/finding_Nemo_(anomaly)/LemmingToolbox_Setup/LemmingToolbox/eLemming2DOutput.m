function [imageRed, imageGreen, imageBlue] = eLemming2DOutput(image, cellID, phi_is, phi_sh, xPath, yPath, coneImage, arrowLength, xposAllCells, yposAllCells, glowImage, startTime, visualization, microscopeDirection, pressedKey, deltaTable) %#ok<INUSL>
% This function provides the visualization for the E. lemming 2D game.

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

persistent enemyLifeStates bulletPositions

if isempty(enemyLifeStates)
    enemyLifeStates = -ones(size(xposAllCells));
    bulletPositions = zeros(0, 3);
end
if isempty(image)
    enemyLifeStates = [];
    bulletPositions = [];
    return;
end
enemyLifeStates(isnan(xposAllCells)) = -1;

%% Print Start Screen
if cputime - startTime < 2
    image = imread(fullfile(matlabroot,'/toolbox/LemmingToolbox/startScreen.jpg'), 'jpg');
    imageRed = reshape(image(:, :, 1), size(image, 1), size(image, 2));
    imageGreen = reshape(image(:, :, 2), size(image, 1), size(image, 2));
    imageBlue = reshape(image(:, :, 3), size(image, 1), size(image, 2));
    return;
end

%% Set basic output image colors to a brownish color
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
    imageRed = image;
    imageGreen = imageRed / 1.5;
    imageBlue = imageRed / 1.5;
end
[imageHeight, imageWidth] = size(imageRed);

%% If no cell is selected, return basic microscope image
if isnan(cellID)
    return;
end
xpos = xposAllCells(cellID);
ypos = yposAllCells(cellID);

%% Shooting
% Configuration
bulletSpeed = 30;
bulletWidth = 3;
deltaBullet = (bulletWidth - 1) / 2;
hitRadius = 20;
startDist = - bulletSpeed + 5 + rand() * 10;

% Hide death cells
for i = find(enemyLifeStates' >= 3 & ~isnan(xposAllCells'))
    hideWidth = 30;
    if xposAllCells(i) < hideWidth / 2 || xposAllCells(i) > imageWidth - hideWidth / 2 || yposAllCells(i) < hideWidth / 2 || yposAllCells(i) > imageHeight - hideWidth / 2
        continue;
    end
    if xposAllCells(i) > imageWidth / 2
        xLeft = xposAllCells(i) - 2 * hideWidth;
    else
        xLeft = xposAllCells(i) + 2 * hideWidth;
    end
    if yposAllCells(i) > imageHeight / 2
        yLeft = yposAllCells(i) - 2 * hideWidth;
    else
        yLeft = yposAllCells(i) + 2 * hideWidth;
    end
    imageRed(yposAllCells(i) - hideWidth/2 + 1 : yposAllCells(i) + hideWidth/2, xposAllCells(i) - hideWidth/2 + 1 : xposAllCells(i) + hideWidth/2) = imageRed(yLeft : yLeft + hideWidth - 1, xLeft : xLeft + hideWidth - 1);
    imageBlue(yposAllCells(i) - hideWidth/2 + 1 : yposAllCells(i) + hideWidth/2, xposAllCells(i) - hideWidth/2 + 1 : xposAllCells(i) + hideWidth/2) = imageBlue(yLeft : yLeft + hideWidth - 1, xLeft : xLeft + hideWidth - 1);
    imageGreen(yposAllCells(i) - hideWidth/2 + 1 : yposAllCells(i) + hideWidth/2, xposAllCells(i) - hideWidth/2 + 1 : xposAllCells(i) + hideWidth/2) = imageGreen(yLeft : yLeft + hideWidth - 1, xLeft : xLeft + hideWidth - 1);
end

% Move bullets if table moved
bulletPositions(:, 1:2) = bulletPositions(:, 1:2) - repmat([deltaTable(2),deltaTable(1)], size(bulletPositions, 1), 1);

% Fire new bullet
if pressedKey == 12 || pressedKey == 32 || pressedKey == 53
    bulletPositions(end + 1, :) = [xpos + startDist * cos(-phi_sh), ypos + startDist * sin(-phi_sh), -phi_sh];
end

% Calculate next position of bullet
bulletPositionsAfter = [bulletPositions(:, 1) + bulletSpeed * cos(bulletPositions(:, 3)), bulletPositions(:, 2) + bulletSpeed * sin(bulletPositions(:, 3)), bulletPositions(:, 3)];

% % Test if bullet hits
for i = find(~isnan(xposAllCells') & ((xposAllCells' ~= xpos) | (yposAllCells' ~= ypos)))
   hit = ((bulletPositions(:, 1) < xposAllCells(i) + hitRadius/2) & (bulletPositionsAfter(:, 1) > xposAllCells(i) - hitRadius/2) ...
       |  (bulletPositions(:, 1) > xposAllCells(i) - hitRadius/2) & (bulletPositionsAfter(:, 1) < xposAllCells(i) + hitRadius/2)) ...
       & ((bulletPositions(:, 2) < yposAllCells(i) + hitRadius/2) & (bulletPositionsAfter(:, 2) > yposAllCells(i) - hitRadius/2) ...
       |  (bulletPositions(:, 2) > yposAllCells(i) - hitRadius/2) & (bulletPositionsAfter(:, 2) < yposAllCells(i) + hitRadius/2)) ...
       & (enemyLifeStates(i) < 0);
    if any(hit)
        enemyLifeStates(i) = 0;
    end
    bulletPositionsAfter(hit, :) = [];
    bulletPositions(hit, :) = [];
end



% Move bullets
bulletPositions = bulletPositionsAfter;

% Remove bullets which are out of the image
badBullets = bulletPositions(:, 1) - deltaBullet < 1 | bulletPositions(:, 1) + deltaBullet > imageWidth | bulletPositions(:, 2) - deltaBullet < 1 | bulletPositions(:, 2) + deltaBullet> imageHeight;
bulletPositions(badBullets, :) = [];
% Draw bullets
bulletPositionsD = round(bulletPositions(:, 1:2));
imageRed(sub2ind(size(imageRed), bulletPositionsD(:, 2), bulletPositionsD(:, 1))) = intmax('uint8');
imageRed(sub2ind(size(imageRed), bulletPositionsD(:, 2) + 1, bulletPositionsD(:, 1) + 1)) = intmax('uint8');
imageRed(sub2ind(size(imageRed), bulletPositionsD(:, 2) - 1, bulletPositionsD(:, 1) + 1)) = intmax('uint8');
imageRed(sub2ind(size(imageRed), bulletPositionsD(:, 2) + 1, bulletPositionsD(:, 1) - 1)) = intmax('uint8');
imageRed(sub2ind(size(imageRed), bulletPositionsD(:, 2) - 1, bulletPositionsD(:, 1) - 1)) = intmax('uint8');
% Draw explosions
enemyLifeStates(enemyLifeStates>=0) = enemyLifeStates(enemyLifeStates>=0) + 1;
for i = find(enemyLifeStates' > 0 & enemyLifeStates' < 4 & ~isnan(xposAllCells'))
    boomFile = imread(fullfile(matlabroot, sprintf('/toolbox/LemmingToolbox/Boom%g.jpg', enemyLifeStates(i))), 'jpg');
    boomFileR = reshape(boomFile(:, :, 1), size(boomFile, 1), size(boomFile, 2));
    boomFileG = reshape(boomFile(:, :, 2), size(boomFile, 1), size(boomFile, 2));
    boomFileB = reshape(boomFile(:, :, 3), size(boomFile, 1), size(boomFile, 2));
    [boomHeight, boomWidth, boom] = size(boomFileR);
    boomTop = -(boomHeight-1)/2 + yposAllCells(i);
    boomLeft = -(boomWidth-1)/2 + xposAllCells(i);
    if boomTop < 1 || boomTop + boomHeight > imageHeight || boomLeft < 1 || boomLeft + boomWidth > imageWidth
        continue;
    end
    colorIdx = find(boomFileR(:) > 10);
    [colorY, colorX] = ind2sub(size(boomFileR), colorIdx);
    colorY = colorY + boomTop - 1;
    colorX = colorX + boomLeft - 1;
    colorIdxImg = sub2ind(size(imageRed), colorY, colorX);
    imageRed(colorIdxImg) = boomFileR(colorIdx);
    imageGreen(colorIdxImg) = boomFileG(colorIdx);
    imageBlue(colorIdxImg) = boomFileB(colorIdx);
end

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
    coneImage = coneImage(1 + deltaYStart : size(coneImage, 1) + deltaYEnd, 1 + deltaXStart : size(coneImage, 2) + deltaXEnd);

    % Draw cube in yellow.
    imageBlue(yStart + deltaYStart : yEnd + deltaYEnd, xStart + deltaXStart : xEnd + deltaXEnd) = uint8(double(imageBlue(yStart + deltaYStart : yEnd + deltaYEnd, xStart + deltaXStart : xEnd + deltaXEnd)) .* (coneImage * 2 + 1));

end

%% Drawing of "should-direction" 
x_arrow = xpos + round(cos(phi_sh) * (0 : arrowLength));
y_arrow = ypos + round(-sin(phi_sh) * (0 : arrowLength));
magnifications = 2:-1/arrowLength:1;
invalidIdx = x_arrow < 1 | x_arrow > imageWidth | y_arrow < 1 | y_arrow > imageHeight;
x_arrow(invalidIdx) = [];
y_arrow(invalidIdx) = [];
magnifications(invalidIdx) = [];
imageRed(sub2ind(size(imageRed), y_arrow, x_arrow)) = uint8(double(imageRed(sub2ind(size(imageRed), y_arrow, x_arrow))) .* magnifications);
%% Highlight all cells
glowWidth = size(glowImage, 1);
half = (glowWidth-1)/2;
dirLength = 20;
 for i = find(~isnan(xposAllCells') & ~isnan(yposAllCells') & (enemyLifeStates' < 0))
    if xposAllCells(i) - half < 1 || xposAllCells(i) + half > imageWidth...
            || yposAllCells(i) - half < 1 || yposAllCells(i) + half > imageHeight
        % Show direction of cell
        angle = atan2(yposAllCells(i) - 0.5 * imageHeight, xposAllCells(i) - 0.5 * imageWidth);
        dAngle = atan2(imageHeight, imageWidth);
        if(angle >= -pi + dAngle && angle < -dAngle)
            % bottom corner
            xposs = ceil(0.5 * imageWidth + tan(pi/2 - angle) * imageHeight/2 + (0:0.5:dirLength) * cos(angle));
            yposs = ceil(1 - (0:0.5:dirLength) * sin(angle));
        elseif(angle >= -dAngle && angle < dAngle)
            % right corner
            xposs = ceil(imageWidth - (0:0.5:dirLength) * cos(angle));
            yposs = ceil(0.5 * imageHeight + tan(angle) * imageWidth/2 - (0:0.5:dirLength) * sin(angle));
        elseif(angle >= dAngle && angle < pi-dAngle)
            % top corner
            xposs = ceil(0.5 * imageWidth + tan(pi/2 - angle) * imageHeight/2 - (0:0.5:dirLength) * cos(angle));
            yposs = ceil(imageHeight - (0:0.5:dirLength) * sin(angle));
        else
            % left corner
            xposs = ceil(1 - (0:0.5:dirLength) * cos(angle));
            yposs = ceil(0.5 * imageHeight + tan(angle) * imageWidth/2 + (0:0.5:dirLength) * sin(angle));
        end
        imageRed(sub2ind(size(imageRed), yposs, xposs)) = uint8(intmax('uint8'));
        continue;
    end
    if xposAllCells(i) == xpos && yposAllCells(i) == ypos
        imageBlue(yposAllCells(i) - half : yposAllCells(i) + half, xposAllCells(i) - half : xposAllCells(i) + half) = uint8(double(imageBlue(yposAllCells(i) - half : yposAllCells(i) + half, xposAllCells(i) - half : xposAllCells(i) + half)) .* (1 + glowImage * 2));
    else
        imageRed(yposAllCells(i) - half : yposAllCells(i) + half, xposAllCells(i) - half : xposAllCells(i) + half) = uint8(double(imageRed(yposAllCells(i) - half : yposAllCells(i) + half, xposAllCells(i) - half : xposAllCells(i) + half)) .* (1 + glowImage));
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

