%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [fOpt, yhOpt, phiOpt, lzOpt] = fitAzimuth(xp, yp, lp, f0, yh0, phiSun, thetaSun)
%  Fits the sky model to images in order to estimate the camera azimuth
%
% Input parameters:
%  - xp: x-coordinates of all input pixels (with respect to the center of the image
%  - yp: y-coordinates of all input pixels (with respect to the center of the image, y-axis pointing up
%  - lp: raw luminance values observed at each pixel
%  - f0: camera focal length
%  - yh0: image horizon line
%  - phiSun: sun azimuth
%  - thetaSun: sun zenith
%
% Output parameters:
%  - phiOpt: estimated camera azimuth
%  - lzOpt: estimated scale factors
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [phiOpt, lzOpt] = fitAzimuth(xp, yp, lp, f0, yh0, phiSun, thetaSun)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2010 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% use turbidity-related parameters
t = 2.17; 
skyParams = getTurbidityMapping(3)*[t 1]';
a = skyParams(1); b = skyParams(2); c = skyParams(3); d = skyParams(4); e = skyParams(5);

lz0 = ones(1, length(lp));

% setup starting point
phi0 = 0;

x0 = [phi0 lz0];

lb = [-inf zeros(1, length(lz0))];
ub = [inf inf.*ones(1, length(lz0))];

f = f0;
yh = yh0;

% initial guess for sun-camera angle
phiRange = 0:pi/2:3*pi/2;
% phiRange = 0;

xOpt = zeros(length(phiRange), length(x0));
minValue = zeros(length(phiRange), 1);
for k = 1:length(phiRange)
    phi0 = phiRange(k);
    
    fprintf('Optimizing for phi0 = %.2f...', phi0);
    
    % Levenberg-Marquadt non-linear least-squares
    options = optimset('Display', 'off', 'Jacobian', 'off');
   
    x0 = [phi0 lz0];
    xOpt(k,:) = lsqnonlin(@optPhiLuminance, x0, lb, ub, options);
    minValue(k) = sum(optPhiLuminance(xOpt(k,:)).^2);
end

[m, mInd] = min(minValue);

phiOpt = xOpt(mInd,1);
lzOpt = xOpt(mInd,2:end);

% function that we're trying to optimize
    function F = optPhiLuminance(x)
        phi = x(1);
        lz = reshape(x(2:end), size(xp));
        
        % compute the full-sky luminance ratio
        ratio = arrayfun(@(xp, yp, lz, phiSun, thetaSun) exactSkyModelRatio(a, b, c, d, e, f, xp{1}, yp{1}, yh, lz, phi, phiSun{1}, thetaSun{1}), xp, yp, lz, phiSun, thetaSun, 'UniformOutput', 0);

        F = cellfun(@(lp, r) lp - r, lp, ratio, 'UniformOutput', 0);
        
        % get single vector for F
        F = cell2mat(F')';
    end


    % function that we're trying to optimize
    function F = optAll(x)
        f = x(1); yh = x(2); phi = x(3);
        lz = mat2cell(x(4:end), 1, ones(size(x(4:end)))); % different for each image

        % compute the full-sky luminance ratio
        ratio = cellfun(@(xp, yp, lz, phiSun, thetaSun) exactSkyModelRatio(a, b, c, d, e, f, xp, yp, yh, lz, phi, phiSun, thetaSun), xp', yp', lz', phiSun, thetaSun, 'UniformOutput', 0);

        F = cellfun(@(lp, r) lp - r, lp, ratio, 'UniformOutput', 0);
        
        % get single vector for F
        F = cell2mat(F)';
    end
end


