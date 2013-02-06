Overview 
========

This package contains an implementation of the algorithm proposed in 

J.-F. Lalonde, S. G. Narasimhan, and A. A. Efros. What do the sun and the 
sky tell us about the camera?  International Journal on Computer Vision, 
88(1):24?51, May 2010.

J.-F. Lalonde, S. G. Narasimhan, and A. A. Efros. What does the sky tell 
us about the camera?  In European Conference on Computer Vision, 2008.

which estimate 3 important camera parameters (focal length, zenith and 
azimuth angles) from several images of the sky, captured over time by a 
static camera. Please cite the papers above if you use this code.

Getting Started
===============

Run the `demoSkyCalib.m` file. 

High-level description of the sub-directories included with this 
distribution:

- images: contains example images used for the optimization;
- invCamResponse: contains the inverse response function for the test 
  sequence, estimated with the algorithm of [Lin et al., CVPR 2004];
- skyMask: the sky mask (1=sky, 0=no sky), labelled manually.

Requirements
============

It requires my sky model implementation, available at

[http://www.jflalonde.org/software.html#skyModel](http://www.jflalonde.org/software.html#skyModel)

