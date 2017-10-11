function cellPositions = cellDetection(imageData, cellSizeLowerLimit, cellSizeUpperLimit, threshold, resizeScale)
% This file identifies all cells in an image.
%
% Input arguments: 
% --------------------
% imageData ... image as a two dimensional array of grayscale (uint8) pixels
% cellSizeUpperLimit ...Lower limit of cell area (in square pixels).
%                       All smaller detected objects are sorted out.
% cellSizeLowerLimit... Upper limit of cell area (in square pixels).
%                       All larger detected objects are sorted out.
% threshold ... Threshold used in the edge detection algorithm.
% resizeScale ... Resize the width and the height of the image by this factor. A lower
%               value will increase speed, but possibly lowers quality of detection.
%
% Return value
% -------------------
% Table representing the positions of all detected cells. Rows represent
% the cells, the first column is the cell's x position and the second its y
% position (in pixels).


% Copyright 2010 Thanuja Ambegoda, Moritz Lang
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

%% Configuration
% True if intermediate images should be shown.
debugging = false;

%% Output original image
if debugging
    figure('Name','Original Image','NumberTitle','off'); %#ok<UNRCH>
    colormap(gray);
    imh = image(imageData);
    set(imh, 'CDataMapping', 'scaled');
    set(gca, 'Box', 'on', 'MinorGridLineStyle', 'none', 'XTick', [], 'YTick', []);
end

%% Resize image
if resizeScale ~= 1
    imageData = imresize(imageData, resizeScale);
end
cellSizeLowerLimit = cellSizeLowerLimit * resizeScale^2;
cellSizeUpperLimit = cellSizeUpperLimit * resizeScale^2;

%% Filter the Pixel-Noise
filterImage = imageData;
%filterImage = medfilt2(imageData);
if debugging
    figure('Name','Filtered Image','NumberTitle','off'); %#ok<UNRCH>
    colormap(gray);
    imh = image(filterImage);
    set(imh, 'CDataMapping', 'scaled');
    set(gca, 'Box', 'on', 'MinorGridLineStyle', 'none', 'XTick', [], 'YTick', []);
end

%% Adjust Contrast
contrastImage = filterImage;
%contrastImage = imadjust(filterImage);
if debugging
    figure('Name','Contrast Image','NumberTitle','off'); %#ok<UNRCH>
    colormap(gray);
    imh = image(contrastImage);
    set(imh, 'CDataMapping', 'scaled');
    set(gca, 'Box', 'on', 'MinorGridLineStyle', 'none', 'XTick', [], 'YTick', []);
end

%% Detect edges in the image (=shadows of cell membranes)
BWs = edge(contrastImage,'sobel', threshold);
if debugging
    figure('Name','Detected Edges','NumberTitle','off'); %#ok<UNRCH>
    colormap(gray);
    imh = image(BWs);
    set(imh, 'CDataMapping', 'scaled');
    set(gca, 'Box', 'on', 'MinorGridLineStyle', 'none', 'XTick', [], 'YTick', []);
end

%% Dilate the Image
% The detected edges of a cell usually have holes. However, we need a
% closed boundary of the cell. Thus we are simply enlarging the edges in
% the hope that all holes are filled.
se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);
BWsdil = imdilate(BWs, [se90 se0]);
if debugging
    figure('Name','Dilated Image','NumberTitle','off'); %#ok<UNRCH>
    colormap(gray);
    imh = image(BWsdil);
    set(imh, 'CDataMapping', 'scaled');
    set(gca, 'Box', 'on', 'MinorGridLineStyle', 'none', 'XTick', [], 'YTick', []);
end

%% Fill Interior Gaps 
% We only have cell boundaries, but for the analysis we need the whole
% cells. We thus just fill everything that is completely enclosed by a cell
% membrane/edge
BWdfill = imfill(BWsdil, 'holes');
if debugging
    figure('Name','Filled holes','NumberTitle','off'); %#ok<UNRCH>
    colormap(gray);
    imh = image(BWsdil);
    set(imh, 'CDataMapping', 'scaled');
    set(gca, 'Box', 'on', 'MinorGridLineStyle', 'none', 'XTick', [], 'YTick', []);
end

%% Filter by the Object Area
% At this point, we will (heopfully) have found most cells. However, we
% have also false detection, namely some artefacts being wrongly identified
% as cells. We now filter them out by requiering that every cell has a
% certain size.

% Gives every connected set of pixels (=cell) an own ID
[Lnew,numNew] = bwlabeln(BWdfill); %#ok<NASGU>
% Calculates the area and the center of every connected set of pixels
% (=cell).
statsNew = regionprops(Lnew, {'Area', 'Centroid'});
% Find objects which are not too small and not too big. These objects
% probably are cells. All others probably not.
idx = find(([statsNew.Area] > cellSizeLowerLimit)&([statsNew.Area] < cellSizeUpperLimit));
if debugging
    BWoutline = ismember(Lnew,idx);%#ok<UNRCH>
    figure('Name','BW Outline','NumberTitle','off'); 
    colormap(gray);
    imh = image(BWoutline);
    set(imh, 'CDataMapping', 'scaled');
    set(gca, 'Box', 'on', 'MinorGridLineStyle', 'none', 'XTick', [], 'YTick', []);
end

%% Get positions of the cells
if isempty(idx)
    cellPositions = zeros(0, 2);
else
    cellPositionsTemp = {statsNew(idx).Centroid}';
    cellPositions = cell2mat(cellPositionsTemp) / resizeScale;
end

%% Delete cells that are too close to each other
numCells = size(cellPositions, 1);
cellDist = (repmat(cellPositions(:, 1)', numCells, 1) - repmat(cellPositions(:, 1), 1, numCells)).^2 +...
    (repmat(cellPositions(:, 2)', numCells, 1) - repmat(cellPositions(:, 2), 1, numCells)).^2;
[row, col] = find(cellDist < cellSizeUpperLimit *3);
cellPositions(col(col>row), :) = [];