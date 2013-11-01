function [xp, yp, lp] = loadImageInformation(imgPath, invCamResponse, ...
    skyMask, xp, yp, nbRandomPixelsToKeep, varargin)
% Loads image information necessary for the sky fitting stages.
%
%   [xp, yp, lp] = loadImageInformation(imgPath, invCamResponse, ...
%       skyMask, xp, yp, nbRandomPixelsToKeep, ...)
%
%   [xp, yp, lp] = loadImageInformation(img, invCamResponse, ...
%       skyMask, xp, yp, nbRandomPixelsToKeep, varargin)
%
% Supports both the path to the image, or the image itself.
%
% Input parameters:
%  - imgPath: path to the input image
%  - invCamResponse: inverse camera response function
%  - skyMask: mask indicating the sky (1=sky, 0=no sky)
%  - xp: [imgHeight x imgWidth], array indicating the x-coordinates of each pixel in the image
%  - yp: [imgHeight x imgWidth], array indicating the x-coordinates of each pixel in the image
%  - nbRandomPixelsToKeep: number of pixels to select from each image
%
% Output parameters:
%  - xp: x-coordinates of all input pixels (with respect to the center of the image
%  - yp: y-coordinates of all input pixels (with respect to the center of the image, y-axis pointing up
%  - lp: raw luminance values observed at each pixel
%
% ----------
% Jean-Francois Lalonde

% saturation threshold
threshUnSat = 254/255;

% darkness threshold 
threshDark = 2/255;

% use luminance only?
luminanceOnly = true;

parseVarargin(varargin{:});

% Read and correct the image
if ischar(imgPath)
    % we're given the image's path
    origImg = im2double(imread(imgPath));
else
    % we're given the image directly
    origImg = im2double(imgPath);
end

% correct for non-linearities
img = correctImage(origImg, invCamResponse);

if luminanceOnly
    img = rgb2gray(img);
end
img = reshape(img, [], size(img, 3));

% Find correctly exposed sky pixels
indUnSat = any(img < threshUnSat, 2);
indDark = any(img > threshDark, 2);

indPx = indUnSat & indDark;
indUnSatSky = find(indPx & skyMask(:)); 

% Keep randomly chosen pixels only
randInd = randperm(length(indUnSatSky)); randInd = randInd(1:nbRandomPixelsToKeep);

lp = img(indUnSatSky(randInd), :);
xp = xp(indUnSatSky(randInd));
yp = yp(indUnSatSky(randInd));

