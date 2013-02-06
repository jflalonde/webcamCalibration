%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [xp, yp, lp] = loadImageInformation(imgPath, invCamResponse, skyMask, xp, yp, nbRandomPixelsToKeep)
%  Loads image information necessary for the sky fitting stages.
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xp, yp, lp] = loadImageInformation(imgPath, invCamResponse, skyMask, xp, yp, nbRandomPixelsToKeep)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2010 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Read and correct the image
origImg = im2double(imread(imgPath));

% correct for non-linearities
img = correctImage(origImg, invCamResponse);
imgLuminance = rgb2gray(img);

%% Find correctly exposed sky pixels
threshUnSat = 254/255;
indUnSat = img(:,:,1) < threshUnSat & img(:,:,2) < threshUnSat & img(:,:,3) < threshUnSat;

threshDark = 2/255;
indDark = img(:,:,1) > threshDark & img(:,:,2) > threshDark & img(:,:,3) > threshDark;

indPx = indUnSat & indDark;
indUnSatSky = find(indPx & skyMask); 

%% Keep randomly chosen pixels only
randInd = randperm(length(indUnSatSky)); randInd = randInd(1:nbRandomPixelsToKeep);

lp = imgLuminance(indUnSatSky(randInd));
xp = xp(indUnSatSky(randInd));
yp = yp(indUnSatSky(randInd));