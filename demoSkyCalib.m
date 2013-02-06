%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% demoSkyCalib
%   Top-level function for demo of webcam calibration from the sky. Use
%   this as a starting point to explore the other functions.
% 
% 
% Copyright 2006-2010 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup paths
imagesPath = './images';
gradientPath = 'gradient';
clearDayPath = 'clearDay';
skyMaskPath = './skyMask/mask.jpg';
invCamResponsePath = './invCamResponse/resp.mat';

%% Set parameters

% number of pixels to randomly select per image
nbRandomPixelsToKeep = 1000;

% image dimensions
imgWidth = 720;
imgHeight = 540;

%% Load sky mask
skyMask = im2double(imread(skyMaskPath))>0.5;

%% Load inverse camera response function
load(invCamResponsePath);

%% Estimate focal length and horizon line
% load files
fprintf('*** Estimating focal length and horizon line ***\n');
gradientFileList = dir(fullfile(imagesPath, gradientPath, '*.jpg'));
gradientFileList = {gradientFileList.name};

[xRange, yRange] = meshgrid(1:imgWidth, 1:imgHeight);
xpVec = (xRange - imgWidth/2) - 0.5;
ypVec = (imgHeight/2 - yRange) + 0.5;

% pre-load image information
xp = cell(1, length(gradientFileList));
yp = cell(1, length(gradientFileList));
lp = cell(1, length(gradientFileList));
fprintf('Loading %d images...', length(gradientFileList));
for f=1:length(gradientFileList)
    fprintf('%d..', f);
    [xp{f}, yp{f}, lp{f}] = loadImageInformation(fullfile(imagesPath, gradientPath, gradientFileList{f}), invCamResponse, skyMask, xpVec, ypVec, nbRandomPixelsToKeep);
end

% initialize horizon to lowest sky row
[rSky, cSky] = find(skyMask);
yh0 = ypVec(max(rSky(:)), 1) - 1;

% estimate parameters
fprintf('\nEstimating focal and horizon...');
[focalLength, horizonLine] = fitFocalAndZenith(xp, yp, lp', yh0);
zenithAngle = pi/2+atan2(horizonLine, focalLength);
fprintf('done.\n');

fprintf('Estimated focal length: %.2f px\n', focalLength);
fprintf('Estimated zenith angle: %.2f deg\n', zenithAngle*180/pi);

%% Estimate azimuth angle
fprintf('\n*** Estimating azimuth angle *** \n');
% load files
clearDayFileList = dir(fullfile(imagesPath, clearDayPath, '*.jpg'));
clearDayFileList = {clearDayFileList.name};

% pre-load image information
xp = cell(1, length(clearDayFileList));
yp = cell(1, length(clearDayFileList));
lp = cell(1, length(clearDayFileList));
sunAzimuths = cell(1, length(clearDayFileList));
sunZeniths = cell(1, length(clearDayFileList));
fprintf('Loading %d images...', length(clearDayFileList));
for f=1:length(clearDayFileList)
    fprintf('%d..', f);
    [xp{f}, yp{f}, lp{f}] = loadImageInformation(fullfile(imagesPath, clearDayPath, clearDayFileList{f}), invCamResponse, skyMask, xpVec, ypVec, nbRandomPixelsToKeep);
    
    % load sun position
    load(fullfile(imagesPath, clearDayPath, strrep(clearDayFileList{f}, '.jpg', '.mat')), 'sunZenith', 'sunAzimuth');
    sunZeniths{f} = sunZenith;
    sunAzimuths{f} = sunAzimuth;
end

% estimate parameters
fprintf('\nEstimating azimuth angle...');
azimuthAngle = fitAzimuth(xp, yp, lp, focalLength, horizonLine, sunAzimuths, sunZeniths); 
fprintf('done.\n');

fprintf('Estimated azimuth angle: %.2f deg\n', azimuthAngle*180/pi);