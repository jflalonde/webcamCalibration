%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [fOpt, yhOpt, lzOpt] = fitFocalAndZenith(xp, yp, lp, yh0, f0)
%  Fits the sky model to the sky vertical gradient only in order to recover the horizon
%  line and the focal length of the camera. 
%
% Input parameters:
%  - xp: x-coordinates of all input pixels (with respect to the center of the image
%  - yp: y-coordinates of all input pixels (with respect to the center of the image, y-axis pointing up
%  - lp: raw luminance values observed at each pixel
%  - yh0: image horizon line
%  - f0: initial guess for camera focal length
%
% Output parameters:
%  - fOpt: estimated focal length
%  - yhOpt: estimated horizon line
%  - lzOpt: estimated scale factors
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fOpt, yhOpt, lzOpt] = fitFocalAndZenith(xp, yp, lp, yh0, f0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2010 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% use turbidity-related parameters
t = 2.17;
skyParams = getTurbidityMapping(3)*[t 1]';
a = skyParams(1);
b = skyParams(2);

if ~exist('f0', 'var')
    % focal length init value
    f0 = 500; 
end

% luminance scale factor init value
lz0 = ones(1, length(lp)); 

% setup starting point
x0 = [f0 yh0 lz0];

% setup bounds
lb = [1 -inf zeros(1, length(lz0))]; % focal length cannot be negative or 0
ub = [inf yh0 inf.*ones(1, length(lz0))]; % horizon cannot be in the sky

optFn = @optLuminanceFocalHorizonExact;

% Levenberg-Marquadt non-linear least-squares
options = optimset('Display', 'off', 'Jacobian', 'off');
xOpt = lsqnonlin(optFn, x0, lb, ub, options);

fOpt = xOpt(1);
yhOpt = xOpt(2);
lzOpt = xOpt(3:end);

    % optimizes the focal length, the horizon line, and the zenith luminances
    function F = optLuminanceFocalHorizonExact(x)
        f = x(1); yh = x(2); 
        lz = mat2cell(x(3:end), 1, ones(size(x(3:end)))); % different for each image

        % compute the luminance ratio
        ratio = cellfun(@(xp, yp, lz) exactGradientModelRatio(a, b, f, xp, yp, yh, lz), xp', yp', lz', 'UniformOutput', 0);
        
        F = cellfun(@(lp, r) lp - r, lp, ratio, 'UniformOutput', 0);

        % get single vector for F
        F = cell2mat(F)';
    end
end
