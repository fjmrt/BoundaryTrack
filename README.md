# BoundaryTrack

Boundary segmentation, tracking, calculation of protrusion/retraction velocity, local curvature, fluorescence intensity at each positions.

## DEMO
![demo_movie](https://user-images.githubusercontent.com/40162543/45085779-7e4e1280-b13c-11e8-831c-c95857527164.gif)

## Overview
### Boundary extraction, segmentation and tracking
This program extracts boundary of an object in binarized image, segments into arbitrary number of positions, tracks each position through time course.  Boundary extraction is based on 8-neighbor, and the coordinates of each segmented boundary position are thus defined as floating point number (Figure 1).  Mapping between time frames which minimizes the sum of square distance conserving clockwise index is chosen (Figure 2).  

![figure1_2](https://user-images.githubusercontent.com/40162543/45090629-d5f37a80-b14a-11e8-844b-717225ad444b.png)

### Quantification
Protrusion/Retraction velocity, curvature and fluorescence intensity at each position will be calculated after tracking.  The magnitude of velocity is defined as the displacement projected normal to the cell contour per unit time and averaged over 3 neighboring positions and 3 time points (Figure 3).  The sign of velocity is negative or positive for inward or outward projections, respectively.  The curvature at point 'i' is defined as the reciprocal of the radius of a circle that crosses the cell boundary at point i − 25, i, and i + 25 (Figure 4).  The curvature is positive when the circle contacted the cell boundary from the inner side of the cell and negative otherwise.  Fluorescent intensity at cell boundaries is calculated by taking the average fluorescence intensities for each (2 x neighbor + 1) x (2 x neighbor + 1) pixels regions around rounded coordinates (Figure 5, this is the case that neighbor = 1).  Optionally, one can normalize the intensity profile by dividing it by the mean fluorescence intensities of the cytosolic region.

![figure3_4_5](https://user-images.githubusercontent.com/40162543/45091527-b27dff00-b14d-11e8-8529-6e831fa2d877.png)

## Requrement
- MATLAB (created on ver. R2015b)
- Image Processing Toolbox

## Install
All codes are in single MATLAB file named 'BoundaryTrack.m'.  Put BoundaryTrack.m file in 'MATLAB' or any directory set to MATLAB search path.

## Usage
### 1. Binarization (preprocessing)
Binarized, 8-bit image stack saved as single tiff is required for this program.  It is also required that there is single object of interest in each time frames.  ImageJ should be suitable for binarization.  

### 2. Load image
**This program is written in object-oriented programming.**  Thus, first of all one needs to generate instance, by typing like `data = BoundaryTrack;` in Command Window.  Instance name (`data`, in this case) is arbitrary.  Choose mask image (Figure 6A).  If you select 2 or more mask tiff stack images, they will be imported as each individual data.  After click OK, you will be asked about acquisition parameters, frame interval(sec) and scale(um/pixel).  Velocity and curvature calculation will be performed based on these parameters (Figure 6B).  This can be changed after loading.  When loading is finished, you can see the object named `data`, *1x1 BoundaryTrack* type in workspace.  Next, execute `data.methodpanel;` in command window, then you can get GUI for executing every method (Figure 6C).  Period `data.`  is the access to the method defined in BoundaryTrack program.  Thus, you can run the `appendimage` method by clicking 'appendimage' on methodpanel, or typing `data.appendimage;` in Command Window as well.  There is two ways to import further images: appendimage and leadimage.
<dl>
  <dt>appendimage</dt>
  <dd>This appends selected image to the instance.  You need to choose mask or cellimage or extfield, which correspond to binarized image, raw fluorescent cell image and external field image visualized by fluorescence dissolved in buffer, respectively.</dd>
  <dt>loadimage</dt>
  <dd>This loads image to specific locus in the instance.  This should be used when 2 or more images are alreadly imported.</dd>
</dl> 
After images are loaded, please check the loaded images by clicking 'currentstate'  (Figure 6D).  In Current state window, checkbox show which data are imported.  Note that any RESULTS are not checked before running tracking algorithm.  In Current images @ T = 1 window, the first slice images of each imported tiff stacks are arrayed.  If you imported 2 or more masks, they should be numbered cell#1, cell#2, and so on.  Please confirm that appropriate images are loaded.  If there is any mistakes in image loading, you can change image by 'loadimage' method.

![figure6](https://user-images.githubusercontent.com/40162543/45095304-ba8f6c00-b158-11e8-92b5-78a8b0e73a92.png)

### 3. Boundary tracking and quantification
Boundary tracking and quantification will run by executing 'boundarytracking' method.  Tracking parameters are as you can see (Figure 7A).  Note that the area of florescent intensity calculation is pixel-based.  In the calculation of the fluorescence intensity of external field, distance from boundary is in the direction of outward normal vector to cell boundary.  For the detail of quantification, see Overview.  You can normalize the intensity profile of cell fluorescence by dividing it by the mean fluorescence intensities of the cytosolic region using 'normbycyto' method.  This automatically calculates the cytosolic region intensity at each time frame by shrinking the mask, and divide the fluorescence intensity at the cell boundary by it.  If you click 'currentstate' again, you can see the checkboxes are fullfilled (Figure 7B).  Velocity, curvature, fluorescence intensity of cell, the normalized one, and fluorescence intensity of external field are stored in RESULTS as `velocity`,`curvature`,`fpIntensity`,`fpIntensity_norm`,`extField`, respectinvely.  **RESULTS is structure array**, and RESULTS itself is defined as one of poperties of the BoundaryTrack class.  Thus, you can access RESULTS property by typing `data.RESULTS` in Command Window, then you can see the fields defined in this structure array (Figure 7C).  You can further access the field by like `data.RESULTS.velocity`.  In the same way, loaded images are stored in `data.INPUTDATA`, and parameters are stored in `data.PARAMS` (please check in Command Window).

![figure7](https://user-images.githubusercontent.com/40162543/45097024-da289380-b15c-11e8-9604-4fc877fa9681.png)

### 4. Visualization
'vismap' method visualizes quantified velocity, curvature, etc (Figure 8A).  You can specify the cell# visualized. If not, data of all cell# will be shown.  In this algorithm, position '1' has no meaning, thus it is arbitrary.  You can rotate the number by a slider.  Colormap, and color range of heat map are also configurable.  'vistracking' method visualizes the mapping between successive frame (Figure 8B).  If you see irregular dynamics like too high/low velocity or curvaturein the maps, please check whether the mapping is reasonable.

![figure8](https://user-images.githubusercontent.com/40162543/45098552-2fb26f80-b160-11e8-9d8a-9da8f16ed29b.png)

### 5. Saving
Generated instance can be saved as mat file by Save Workspace (MATLAB UI).

## VS
There are so many algorithms and papers about the quantification of cell morphology using similar method.  Especially, *Dictyostelium* cells, soil living highly motile amoeba, is extensively studied using the minimization of sum of squared distance method<sup>1,2,3,4,5,6</sup>.  The method is also used in the studies of keratocyte migration<sup>7,8,9</sup>.  In one of those studies<sup>9</sup>, velocity calculation by displacement vector projection to normal to cell boundary is also used.  Since cells are sometimes so deformable that the minimization of sum of squared distance method fails to grasp detail dynamics, there are some alternatives which are more sensitive to local deformation, such as QuimP method<sup>10,11,12,13,14</sup>, or level set method<sup>15,16</sup>.  When cells are deformable but show no net displacement, R-theta plot is also effective<sup>17,18,19</sup>.  It is important to select the appropriate method depending on what dynamics you want to focus on.  Compared to these previously described methods, the alrogirthm used in this BoundaryTrack program is a kind of simple method for the sake of ease.

## Author
The author is [Taihei Fujimori](https://github.com/fjmrt).  Please contact me if you have any questions!

## References
1. Driscoll MK et al., Phys. Biol., 2011.
2. Driscoll MK et al., PLOS Comp. Biol., 2012.
3. Driscoll MK et al., ACS Nano, 2014.
4. Wang C et al., J. R. Soc. Interface, 2014.
5. Nagel O et al., PLOS One, 2014.
6. Driscoll MK et al., Cytoskeleton, 2015.

7. Pincus Z & Theriot JA, J. Microsc., 2007.
8. Lou SS et al., J. Cell Biol., 2014.
9. Barnhart EL et al., PLOS Biol., 2011.

10. Dormann D et al., Cell Motil. Cytoskeleton, 2002.
11. Tyson RA et al., Math. Model Nat. Phenom., 2010.
12. Van Haastert PJM & Bosgraaf L, HFSP J., 2009.
13. Bosgraaf L & Van Haastert PJM, PLOS One, 2009.
14. Tyson RA et al., PNAS, 2015.

15. Machacek M & Danuser G, Biophys. J., 2006.
16. Cai D et al., Cell, 2014.

17. Maeda YT et al., PLOS One, 2008.
18. Arai Y et al., PNAS, 2010.
19. Welf ES et al., J. Cell Biol., 2010.




