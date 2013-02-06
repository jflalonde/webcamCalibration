%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function corrImg = correctImage(img, camInvResponse)
%   Corrects the image according to the inverse response function
%  
% 
% Input parameters:
%  - img: input image
%  - camInvResponse: inverse response function (Nx3)
%
% Output parameters:
%  - corrImg: corrected image
%   
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function corrImg = correctImage(img, camInvResponse)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2010 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% reshape and rescale in the [0,1] interval
imgVec = reshape(img, size(img,1)*size(img,2), size(img,3));
maxVal = max(imgVec, [], 1);
imgVec = imgVec ./ repmat(maxVal, size(img,1)*size(img,2), 1);

% clamp in [0,1] interval
imgVec = min(max(imgVec, 0), 1);

% correct
corrImgVec = zeros(size(imgVec));
for i=1:3
     corrImgVec(:,i) = interp1(linspace(0, 1, length(camInvResponse(:,i))), camInvResponse(:,i), imgVec(:,i), 'linear');
end

% rescale and reshape back to original format
corrImgVec = corrImgVec .* repmat(maxVal, size(img,1)*size(img,2), 1);
corrImg = reshape(corrImgVec, size(img,1), size(img,2), size(img,3));
