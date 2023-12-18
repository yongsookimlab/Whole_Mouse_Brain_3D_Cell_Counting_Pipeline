# 3D Cell Type Quantification Pipeline for the Whole Mouse Brain 
- Created by the Yongsoo Kim Lab [(website)](https://kimlab.io/) in 2021
- README last updated on 20231218 by J. Liwang

## Overview
This code package is designed for comprehensive 3D cell counting using whole mouse brain images. The pipeline includes:
1. Implementing a supervised machine learning-based approach (ilastik) for automated cell segmentation via pixel and/or object classification,
2. Image registration of serial two-photon tomography (STPT) stitched data to an age-matched reference brain template,
3. Registration of assigned and segmented voxels/"cells" to the reference space based on the common coordinate framework (CCF) system, and
4. Transformation of anatomical annotations (from the reference brain atlas) to the sample image registered to the reference space.

- Previously implemented for cell type mapping in the early postnatally developing mouse brain: [download](https://www.biorxiv.org/content/10.1101/2023.11.24.568585v1.full.pdf) / [doi](https://www.biorxiv.org/content/10.1101/2023.11.24.568585v1) 
  - Examples of generated data output (brain region volumes, cell densities, cell counts) from running this code package and its application can be viewed and downloaded [here](https://kimlab.io/brain-map/epDevAtlas/).

## System Requirements
> Please make sure the following requirements (ie. operating system, software, and tools) are downloaded and installed on your machine prior to code use.

### Hardware
Ideally, a high-performance computer with a 32- or 64-core processor to perform parallel computing.
- Microsoft Windows 10, 64-bit (operating system that the code was built and tested with) 

### Software
- MATLAB (MathWorks): [download](https://www.mathworks.com/products/matlab.html?s_tid=hp_products_matlab)
  - Tested using MATLAB versions R2020a and R2021b
- Fiji (ImageJ2): [download](https://imagej.net/software/fiji/)
  - Tested using ImageJ (1.53t) with Java 1.8.0_172 (64-bit)
- ilastik, for machine learning-based segmentation: [download](https://www.ilastik.org/documentation/basics/installation) or [ilastik github](https://github.com/ilastik/ilastik)
- elastix: a toolbox for rigid and nonrigid registration of images: [download](https://elastix.lumc.nl/download.php) or [elastix github](https://github.com/SuperElastix/elastix)
- transformix: 
- Python: [download](https://www.python.org/downloads/)
  - Tested using Python versions 3.8.3 and 3.9.7
 
### Data and Tools
- Full-resolution, stitched, STPT imaging data acquired with TissueCyte (TissueVision)
  - Raw STPT images can be fed through our custom stitching code (available [here](https://github.com/yongsookimlab/TracibleTissueCyteStitching)) for file structure and metadata compatibility.
  - Additionally, the Brain Image Library (BIL, RRID:SCR_017272) is a public [database](https://www.brainimagelibrary.org/index.html) of brain imaging data that has STPT datasets for download which can be used as input for the counting code.
  -  For reference on how to use the TissueCyte (e.g. microscope set up, brain sample preparation, and image stitching), please see our open-source published [protocol](https://star-protocols.cell.com/protocols/2373).
    
- Mouse brain reference atlas consisting of averaged templates and anatomical labels
  - Early Postnatal Developmental Mouse Brain Atlas (epDevAtlas, RRID:SCR_024725) can be viewed and downloaded [here](https://kimlab.io/brain-map/epDevAtlas/).
  - Allen Mouse Brain Reference Atlas (Allen CCFv3, RRID:SCR_002978) can be viewed and downloaded [here](https://mouse.brain-map.org/static/atlas).

## How To Use

**Available in this Github repository are the necessary MATLAB scripts designed for 3D cell counting in STPT-imaged whole mouse brains. However, to execute the main pipeline code ***RUN_THIS_FILE.m***, all downloaded scripts from this repository, installed software, and reference atlas files must be gathered in one parent directory. The code is written with a specific folder structure, which can be found by viewing/downloading the code package [here].**

### Pixel Classification using ilastik for Cell Segmentation
1. Open the ilastik software for machine learning-based pixel classification.
2. 

### Cell Counting
1. Open **RUN_THIS_FILE.m** in MATLAB.
> Note: This README provides a general overview of how to run the main MATLAB script **RUN_THIS_FILE.m** that calls on a collective of scripts in the **private** folder. It is crucial to refer to the comments (preceded by %) in the main script for detailed information on each section and parameter.

2. 
Background subtraction: Images in images_in_ch_folder are processed to create a signal minus noise output in subtracted_ch_folder.
Normalization: Normalization is applied to images in images_in_ch_folder and saved in normalized_images_folder.
Registration: Registration is performed using images in registering_ch_folder to match the reference brain background.
Cell Counting: Various counting methods are applied based on the counting_switch value.
Instructions
Basic Settings:

Update the targeting_folder variable with the main cluster folder path.
Set the paths for images_in_ch_folder, registering_ch_folder, background_ch_folder, and subtracted_ch_folder.
Functional Switches:

Adjust the switches (background_subtraction_switch, normalization_switch, counting_switch, etc.) based on your requirements.
Pro Settings:

Set paths for normalized_images_folder, images_ML_folder, and other pro-level settings.
Machine Learning Notes:

Ensure ilastik is properly installed and the project is set up for pixel classification.
Pipeline:

Run the script, and the pipeline will execute based on the configured switches.
Output:

The final results, including cell counts and registration outputs, will be available in the specified folders.
Notes:
For more information about switch options, refer to the comments in the script.
Ensure that all required folders exist before running the script.
Adjust the normalization method based on the experiment type (LS or STPT).

> Contact: For questions or assistance, please contact the lab's principal investigator, Yongsoo Kim (yuk17@psu.edu).





## Limitations
This code was developed for 3D cell quantification utilizing whole brain imaging with the TissueCyte (TissueVision) STPT system in mind, which has specific parameters that may not apply to other imaging modalities. It is possible to use this code with 3D whole brain images acquired via light sheet fluorescence microscopy, but this is currently under optimization by the Yongsoo Kim Lab.


## License
- This work is licensed under a Creative Commons Attribution 4.0 International License as of December 1, 2023, but it is free and openly accessible for academic use.
- If you use this code package anywhere, we would appreciate if you cite the following [preprint](https://www.biorxiv.org/content/10.1101/2023.11.24.568585v1):
  - **epDevAtlas: Mapping GABAergic cells and microglia in postnatal mouse brains**
    - Josephine K. Liwang, Fae A. Kronman, Jennifer A. Minteer, Yuan-Ting Wu, Daniel J. Vanselow, Yoav Ben-Simon, Michael Taormina, Deniz Parmaksiz, Sharon W. Way, Hongkui Zeng, Bosiljka Tasic, Lydia Ng, Yongsoo Kim. bioRxiv 2023.11.24.568585; doi: https://doi.org/10.1101/2023.11.24.568585
