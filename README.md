# BoundaryTrack

Boundary segmentation, tracking, calculation of protrusion/retraction velocity, local curvature, fluorescence intensity at each positions.

## DEMO
![demo_movie](https://user-images.githubusercontent.com/40162543/45085779-7e4e1280-b13c-11e8-831c-c95857527164.gif)

## Overview
### Boundary extraction, segmentation and tracking
This algorithm extracts boundary of an object in binarized image, segments into arbitrary number of positions, tracks each position through time course.  Boundary extraction is based on 8-neighbor, and the coordinates of each segmented boundary position are thus defined as floating point number (Figure 1).  Mapping between time frames which minimizes the sum of square distance conserving clockwise index is chosen (Figure 2).  
![figure1_2](https://user-images.githubusercontent.com/40162543/45090629-d5f37a80-b14a-11e8-844b-717225ad444b.png)

### Quantification
Protrusion/Retraction velocity, curvature and fluorescence intensity at each position will be calculated after tracking.  The magnitude of velocity is defined as the displacement projected normal to the cell contour per unit time and averaged over 3 neighboring positions and 3 time points (Figure 3).  The sign of velocity is negative or positive for inward or outward projections, respectively.  The curvature at point 'i' is defined as the reciprocal of the radius of a circle that crosses the cell boundary at point i − 25, i, and i + 25 (Figure 4).  The curvature is positive when the circle contacted the cell boundary from the inner side of the cell and negative otherwise.  Fluorescent intensity at cell boundaries is calculated by taking the average fluorescence intensities for each 3 x 3 pixels regions around rounded coordinates (Figure 5).  Optionally, one can normalize the intensity profile by dividing it by the mean fluorescence intensities of the cytosolic region.
![figure3_4_5](https://user-images.githubusercontent.com/40162543/45090632-dab82e80-b14a-11e8-8312-7812c1222498.png)

## Requrement
- MATLAB (created on ver. R2015b)
- Image Processing Toolbox

## Install
Put BoundaryTrack.m file in 'MATLAB/' or any directory set as MATLAB search path.

## Usage


