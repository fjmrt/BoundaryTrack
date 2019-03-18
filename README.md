# BoundaryTrack

Boundary segmentation, tracking, calculation of protrusion/retraction velocity, local curvature, fluorescence intensity at each position.

## DEMO
![demo_movie](https://user-images.githubusercontent.com/40162543/45279915-795adb80-b50d-11e8-8b62-4d16312e53bf.gif)

## Overview
### Boundary extraction, segmentation, and tracking
This program extracts boundary of an object in a binarized image stack, segments into an arbitrary number of positions, tracks each position through time course.  Boundary extraction is based on 8-neighbor, and the coordinates of each segmented boundary position are thus defined as floating point number (Figure 1).  Mapping between time frames which minimizes the sum of square distance conserving clockwise index is chosen (Figure 2).  

![figure1_2](https://user-images.githubusercontent.com/40162543/45090629-d5f37a80-b14a-11e8-844b-717225ad444b.png)

### Quantification
Protrusion/retraction velocity, curvature and fluorescence intensity at each position will be calculated after tracking.  The magnitude of velocity is defined as the displacement projected normal to the cell contour per unit time and averaged over 3 neighboring positions and 3 time points (Figure 3).  Note that 3 frames are cut due to the requirement of the calculation of difference and averaging.  ***If you analyze the data with N time points, the quantification results correspond to frame #2 ~ #N-2.***  Velocity at the frame #1 ~ #N-1 is output, then frame #1 and #N-1 are cut due to the absence of neighbor in averaging step.  The sign of velocity is negative or positive for inward or outward projections, respectively.  The curvature at point 'i' is defined as the reciprocal of the radius of a circle that crosses the cell boundary at point i − 25, i, and i + 25 (Figure 4).  The curvature is positive when the circle contacted the cell boundary from the inner side of the cell and negative otherwise.  Fluorescent intensity at cell boundaries is calculated by taking the average fluorescence intensities for each (2 x neighbor + 1) x (2 x neighbor + 1) pixels regions around rounded coordinates (Figure 5, this is the case that neighbor = 1).  Optionally, one can normalize the intensity profile by dividing it by the mean fluorescence intensities of the cytosolic region.  

![figure3_4_5](https://user-images.githubusercontent.com/40162543/45091527-b27dff00-b14d-11e8-8529-6e831fa2d877.png)

## Requrement
- MATLAB (>= R2015b)
- Image Processing Toolbox

## Install
All codes are in single MATLAB file named 'BoundaryTrack.m'.  Put BoundaryTrack.m file in 'MATLAB' or any directory set to MATLAB search path.

## Usage
### 1. Binarization (preprocessing)
Binarized, 8-bit image stack saved as a single tiff file is required for this program.  It is also required that there is a single object of interest in each time frames.  ImageJ should be suitable for binarization.  

### 2. Load image
**This program is written in object-oriented programming.**  Thus, first of all, you need to generate an instance, by executing e.g. `data = BoundaryTrack;` in Command Window.  Instance name (`data`, in this case) is arbitrary.  Choose a binarized image stack saved as a tiff file (Figure 6A).  If you select 2 or more mask tiff stack images, they will be imported as each individual data.  After click OK, you will be asked about acquisition parameters, frame interval(sec) and scale(um/pixel).  Velocity and curvature calculation will be performed based on these parameters (Figure 6B).  This can be changed after loading.  After loading, you can see the object named `data`, *1x1 BoundaryTrack* type in workspace.  Next, execute `data.methodpanel;` in Command Window, then you can get GUI for executing every method (Figure 6C).  Period `data.`  is the access to the method defined in BoundaryTrack program.  Thus, you can run the `appendimage` method by clicking 'appendimage' on methodpanel, or executing `data.appendimage;` in Command Window as well.  There are two ways to import further images: appendimage and loadimage.
<dl>
  <dt>appendimage</dt>
  <dd>This appends selected image to the instance.  You need to choose mask or cellimage or extfield, which correspond to the binarized image you want to add, raw fluorescent cell image and external field image visualized by fluorescence dissolved in buffer, respectively.</dd>
  <dt>loadimage</dt>
  <dd>This loads image to a specific locus in the instance.  This should be used when 2 or more images are already imported.</dd>
</dl> 
After images are loaded, please check the loaded images by clicking 'currentstate'  (Figure 6D).  In 'Current state' window, checkbox show which data are imported.  Note that any RESULTS are not checked before running tracking algorithm.  In 'Current images @ T = 1' window, the first slice images of each imported tiff stacks are arrayed.  If you imported 2 or more masks, they should be numbered cell#1, cell#2, and so on.  Please confirm that appropriate images are loaded.  If there are any mistakes in image loading, you can change image by 'loadimage' method.

![figure6](https://user-images.githubusercontent.com/40162543/45095304-ba8f6c00-b158-11e8-92b5-78a8b0e73a92.png)

### 3. Boundary tracking and quantification
Boundary tracking and quantification will run by executing 'boundarytracking' method.  Tracking parameters are as you can see (Figure 7A).  Note that the area of fluorescent intensity calculation is pixel-based.  In the calculation of the fluorescence intensity of the external field, distance from the boundary is in the direction of outward normal vector to cell boundary.  For the detail of quantification, see Overview.  You can normalize the intensity profile of cell fluorescence by dividing it by the mean fluorescence intensities of the cytosolic region using 'normbycyto' method.  This automatically calculates the cytosolic region intensity at each time frame by shrinking the mask and divide the fluorescence intensity at the cell boundary by it.  If you click 'currentstate' again, you can see the checkboxes are fullfilled (Figure 7B).  Velocity, curvature, fluorescence intensity of cell, the normalized one, and fluorescence intensity of external field are stored in RESULTS as `velocity`,`curvature`,`fpIntensity`,`fpIntensity_norm`,`extField`, respectinvely.  **RESULTS is structure array**, and RESULTS itself is defined as one of properties of the BoundaryTrack class.  Thus, you can access RESULTS property by executing `data.RESULTS` in Command Window, then you can see the fields defined in this structure array (Figure 7C).  You can further access the field by a period (`data.RESULTS.velocity`, in the case of velocity).  In the same way, loaded images are stored in `data.INPUTDATA`, and parameters are stored in `data.PARAMS` (please check in Command Window).

![figure7](https://user-images.githubusercontent.com/40162543/45097024-da289380-b15c-11e8-9604-4fc877fa9681.png)

### 4. Visualization
'vismap' method visualizes quantified velocity, curvature, etc (Figure 8A).  You can specify the cell# visualized. If not, data of all cell# will be shown.  In this algorithm, position '1' has no meaning, thus it is arbitrary.  You can rotate the number by a slider.  Colormap and color range of heat map are also configurable.  'vistracking' method visualizes the mapping between successive frames (Figure 8B).  If you see irregular dynamics in the maps *e.g. spots with too high/low value*, please check whether the mapping is reasonable.

![figure8](https://user-images.githubusercontent.com/40162543/45098552-2fb26f80-b160-11e8-9d8a-9da8f16ed29b.png)

### 5. Saving
The generated instance can be saved as mat file by Save Workspace (MATLAB UI).

## VS
There are so many algorithms and papers about the quantification of cell morphology using a similar method.  Especially, *Dictyostelium discoideum*, soil-living highly motile amoeba, is extensively studied using the minimization of the sum of squared distance method<sup>1,2,3,4,5,6</sup>.  The method is also used in the studies of keratocyte migration<sup>7,8,9</sup>.  In one of those studies<sup>9</sup>, velocity calculation by displacement vector projection to normal to cell boundary is also used.  Since cells are sometimes so deformable that the minimization of the sum of squared distance method fails to grasp detail dynamics, there are some alternatives which are more sensitive to local deformation, such as QuimP method<sup>10,11,12,13,14</sup>, or level set method<sup>15,16</sup>.  When cells are deformable but show no net displacement, R-theta plot is also effective<sup>17,18,19</sup>.  It is important to select the appropriate method depending on what dynamics you want to focus on.  Compared to these previously described methods, the algorithm used in this BoundaryTrack program is a kind of simple method for the sake of fast computation.  This program was used in my previous works on cell migration<sup>20,21</sup>.

## Author
The author is [Taihei Fujimori](https://github.com/fjmrt).  Please contact me if you have any questions!

## License
BoundaryTrack.m is released under the MIT License, see LICENSE.txt.

## References
1. Driscoll MK *et al.*, *Phys. Biol.*, 2011.
2. Driscoll MK *et al.*, *PLOS Comp. Biol.*, 2012.
3. Driscoll MK *et al.*, *ACS Nano*, 2014.
4. Wang C *et al.*, *J. R. Soc. Interface*, 2014.
5. Nagel O *et al.*, *PLOS One*, 2014.
6. Driscoll MK *et al.*, *Cytoskeleton*, 2015.

7. Pincus Z & Theriot JA, *J. Microsc.*, 2007.
8. Lou SS *et al.*, *J. Cell Biol.*, 2014.
9. Barnhart EL *et al.*, *PLOS Biol.*, 2011.

10. Dormann D *et al.*, *Cell Motil. Cytoskeleton*, 2002.
11. Tyson RA *et al.*, *Math. Model Nat. Phenom.*, 2010.
12. Van Haastert PJM & Bosgraaf L, *HFSP J.*, 2009.
13. Bosgraaf L & Van Haastert PJM, *PLOS One*, 2009.
14. Tyson RA *et al.*, *PNAS*, 2015.

15. Machacek M & Danuser G, *Biophys. J.*, 2006.
16. Cai D *et al.*, *Cell*, 2014.

17. Maeda YT *et al.*, *PLOS One*, 2008.
18. Arai Y *et al.*, *PNAS*, 2010.
19. Welf ES *et al.*, *J. Cell Biol.*, 2010.

20. [Nakajima A *et al.*, *Lab on a Chip*, 2016.](https://pubs.rsc.org/en/content/articlelanding/2016/lc/c6lc00898d#!divAbstract)
21. [Fujimori T *et al.*, *PNAS*, 2019.](https://www.pnas.org/content/116/10/4291)
