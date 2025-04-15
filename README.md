# 3D Cell and Pixel Quantification Pipeline for the Whole Mouse Brain 
- Created by the [Yongsoo Kim Lab](https://kimlab.io/)
- README written and updated on 20250415 by J. Liwang and S. Manjila

## Overview
This code package is designed for comprehensive 3D cell counting and pixel counting using whole mouse brain images. The pipeline includes:
1. Implementing a supervised machine learning-based approach (ilastik) for automated cell segmentation via pixel and/or object classification,
2. Image registration of serial two-photon tomography (STPT) or light sheet fluorescence microscopy (LSFM) stitched data to an age-matched reference brain template,
3. Registration of assigned and segmented voxels/"cells" to the reference space based on the common coordinate framework (CCF) system, and
4. Transformation of anatomical annotations (from the reference brain atlas) to the sample image registered to the reference space.

Previously implemented for:
1. Cell type mapping in the early postnatal developing mouse brain: [download epDevAtlas preprint](https://www.biorxiv.org/content/10.1101/2023.11.24.568585v1.full.pdf) / [doi](https://www.biorxiv.org/content/10.1101/2023.11.24.568585v1)
  - Neuroglancer web visualization of generated data and code output for [epDevAtlas Project](https://kimlab.io/brain-map/epDevAtlas/)
2. Brain-wide connectivity mapping of the mouse dorsal endopiriform nucleus (EPd): [download EPd preprint](https://www.biorxiv.org/content/10.1101/2024.09.30.615899v1.full.pdf) / [doi](https://www.biorxiv.org/content/10.1101/2024.09.30.615899v1)
  - Neuroglancer web visualization of generated data for [EPd Connectivity Project](https://kimlab.io/brain-map/epDevAtlas/)

## System Requirements
> Please make sure the following requirements (ie. operating system, software, and tools) are downloaded and installed on your machine prior to code use.

### Hardware
Ideally, a high-performance computer with a 32- or 64-core processor to perform parallel computing in MATLAB.
- Microsoft Windows 10, 64-bit (operating system that the code was built and tested with) 

### Software
- MATLAB (MathWorks): [download](https://www.mathworks.com/products/matlab.html?s_tid=hp_products_matlab)
  - Tested using MATLAB versions R2020a and R2021b
- Fiji (ImageJ2): [download](https://imagej.net/software/fiji/)
  - Tested using ImageJ (1.53t) with Java 1.8.0_172 (64-bit)
- ilastik, for machine learning-based segmentation: [download](https://www.ilastik.org/documentation/basics/installation) or [ilastik github](https://github.com/ilastik/ilastik)
  - Tested using ilastik version 1.4.0
- elastix and transformix: [download](https://elastix.lumc.nl/download.php) or [elastix github](https://github.com/SuperElastix/elastix)
  - Tested using elastix version 4.8
- Python: [download](https://www.python.org/downloads/)
  - Tested using Python versions 3.8.3 and 3.9.7
 
### Data and Tools
- Full-resolution, stitched, STPT imaging data acquired with TissueCyte (TissueVision) or LSFM imaging data acquired with SmartSPIM (LifeCanvas Technologies)
  - A dataset consisting of one STPT-imaged brain with expected data output has been made available for testing/demo purposes: [download here](https://pennstateoffice365-my.sharepoint.com/:f:/g/personal/yuk17_psu_edu/EkTTKApE7aFLs7xzEMAnKloBq24jZ_rrKDmVWUt4mql93A?e=4DCPtz) 
  - Raw STPT and LSFM images acquired elsewhere can be fed through our custom stitching code (available [here for STPT](https://github.com/yongsookimlab/TracibleTissueCyteStitching) and [here for LSFM](https://github.com/yongsookimlab/LSFM_Image_Stitcher)) for file structure and metadata compatibility.
  - Additionally, the Brain Image Library (BIL, RRID:SCR_017272) is a public [database](https://www.brainimagelibrary.org/index.html) of brain imaging data that has STPT and LSFM datasets for download which can be used as input for the counting code.
  -  For reference on how to use the TissueCyte (e.g. microscope set up, brain sample preparation, and image stitching), please see our open-source published [protocol](https://star-protocols.cell.com/protocols/2373).
    
- Mouse brain reference atlas consisting of averaged templates and anatomical labels
  - Early Postnatal Developmental Mouse Brain Atlas (epDevAtlas, RRID:SCR_024725) can be viewed [here](https://kimlab.io/brain-map/epDevAtlas/) and downloaded [here](https://pennstateoffice365-my.sharepoint.com/:f:/g/personal/yuk17_psu_edu/EkS4MIAfRgdKp93QHphJmfoBwOPt4fr2IFERVUMlcR3Rvg?e=tEUQVx).
  - Allen Mouse Brain Reference Atlas (Allen CCFv3, RRID:SCR_002978) can be viewed and downloaded [here](https://mouse.brain-map.org/static/atlas).
  - A modified version of Allen CCFv3 with highlighted fiber tracts for registering LSFM monosynaptic rabies tracing data can be downloaded [here](https://pennstateoffice365-my.sharepoint.com/:u:/g/personal/yuk17_psu_edu/EQ9ppklRoFtClDAzD9fmuP8BDeNxVB1G8Eutxaof_7nqFg?e=stBbJ3).


## How To Use

### Pixel Classification for Cell Segmentation using ilastik
> The Pixel Classification workflow categorizes pixels by utilizing both pixel features and user annotations. This workflow provides flexibility in choosing from a range of generic pixel features, including smoothed pixel intensity, edge filters, and texture descriptors. After selecting the desired features, a Random Forest classifier is trained interactively using user annotations.

- See ilastik's [tutorial](https://www.ilastik.org/documentation/pixelclassification/pixelclassification) on pixel classification for cell segmentation and all related documentation.

In brief:
1. Open the ilastik software for machine learning-based pixel classification.
2. Select new project. Project type: Pixel classification.
3. Input data for ML training.
    - Select and upload stitched STPT data pertaining to specific cell type (and/or age).
    - The number of single TIFs uploaded can vary, but it is good to have at least 5 images representing different brain regions in anterior-posterior axis.
4. Select features.
    - It is recommended to start off with a wider range (10 sigma) of features.
5. Train your classifier.
   - Under the "Group Visibility" section, right-click on **Input Data** to adjust the brightness threshold.
      - Threshold value should remain consistent during across all images during training.
    - Examples of labels (minimum of three for counting code, with Label 3 segmenting your cells of interest):
      - Label 1: empty background
      - Label 2: brain tissue background
      - Label 3: signal of interest for segmentation (can be cells or projection fibers)
      - Label 4: (optional) signal #2, extraneous fibers, etc
6. Click on the **Live Update** button to let the ML training of drawn labels update on the imaged TIFs.
     - Note: Unclick **Live Update** when navigating around image and drawing additional labels because the program can lag.
7. Toggle between **Prediction** and **Segmentation** buttons to view how the trained ML is performing based on user input thus far.
8. **SAVE PROJECT** continually during ML training.
   - Save this .ilp file on a local computer where the counting code will be executed or on a shared network drive.
   - Remember file pathname for input into counting code.


### Cell Counting and Atlas Registration
**Available in this Github repository are the necessary MATLAB scripts designed for 3D cell counting in STPT-imaged whole mouse brains. However, to execute the main pipeline code ***RUN_THIS_FILE.m***, all downloaded scripts from this repository, installed software, and reference atlas files must be gathered in one parent directory. The code is written with a specific folder structure, which can be found by viewing/downloading the entire code package including test sample data [here](https://pennstateoffice365-my.sharepoint.com/:f:/g/personal/yuk17_psu_edu/ElSwPmP7iJ5MgHRibS-t2UoBStedo5zEuEMjOwElt5RBxA?e=OiGXtY).**

> Note: This README provides a general overview of how to run the main MATLAB script **RUN_THIS_FILE.m** that calls on a collective of scripts in the **private** folder. It is crucial to refer to the comments (preceded by % and %%%) in the main script for detailed information on each section and parameter.

1. Open **RUN_THIS_FILE.m** in MATLAB.
2. Ensure that all necessary files, folders, and applications are located in one parent directory for the code package. This folder should be saved on your local computer drive.
3. Outline of steps:
    - Background subtraction (optional): Images in "background_ch_folder" are subtracted from "images_in_ch_folder" to create a "Signal_minus_Noise" image output in "subtracted_ch_folder".
    - Normalization (optional): Normalization of intensity is applied to images in "images_in_ch_folder" and saved in "normalized_images_folder".
    - Registration: Registration is performed using images in "registering_ch_folder" to align with the "reference_brain_background".
    - Cell counting: Various counting methods are applied based on the "counting_switch" value.
    - Reverse registration: Back registration of anatomical labels "allen_anno" to the imaged brain in reference space.
4. Under **Essential Settings**, fill out the necessary input file pathnames for executing the counting code.
    - Update the "targeting_folder" variable with the main cluster folder path containing stitched STPT images.
    - Set the paths for "images_in_ch_folder", "registering_ch_folder", "background_ch_folder", and "subtracted_ch_folder".
    - ***Each input setting is explained in greater detail within the commented code, so please refer to those comments for specific directions.***
5. Set Functional Switches:
     - Adjust the switches (background_subtraction_switch, normalization_switch, counting_switch, etc.) based on your requirements.
6. For running rigid and nonrigid registration (registration_switch), there are two important parameter files for elastix execution:
     - Rigid (EulerTransform) transformation parameters -> 001_parameters_Rigid.txt
     - Nonrigid (BSplineTransform) transformation parameters -> 002_parameters_BSpline.txt
     - In the downloadable folder **elastix**, which should exist in the parent folder of this pipeline code, there are two file versions for each parameter. Each one is optimized for either adult or early postnatal mouse brains.
        - Adult -> **parameter_adult** folder
        - Early postnatal -> **parameter_earlypostnatal** folder
        - Note: It is important to specify which one of these folders will be used in code itself. Additionally, the parameter text files can be edited to improve image registration quality. 
7. Execute **RUN_THIS_FILE.m** when all information has been filled out and the code switches have been configured.
     - Expected code runtime for a single early postnatal brain can range from approximately 3 to 6 hours using a 64-core computer (if no other tasks are running in the background).
     - If running on a normal home desktop computer (average 8 cores), the runtime may last or exceed 24 to 48 hours.
8. Output in sample directory:
    - Spreadsheet (counted_3d_cells.csv) with columns for brain regions (listed in hierarchical order based on CCFv3 ontology), cell counts, cell densities, and volumes per region for an individual brain sample.
      -  This output file is ready for analysis. By implementing this code for multiple,  imaged brains, you can calculate and generated averaged datasets with appropriate statistical measures.
      -  All quantitative results in the related [manuscript](https://www.biorxiv.org/content/10.1101/2023.11.24.568585v1.full) were analyzed using Prism (GraphPad) and Excel (Microsoft).
    - Registration output (elastix folder)
       - All processes and errors during registration are logged (elastix.log) and these files are generated automatically. 
    - Reverse registration output with mapped cells in 3D reference space (cell_counted_refspace.tif)
      - Open this file in Fiji, change image type to 32-bit (Image > Type > 32-bit), and apply a Gaussian filter with 2.0 sigma (Process > Filters > Gaussian blur 3D) for better visualization of the 3D counted cells in the entire TIF stack.
      - Save this edited TIF stack with a new file name. It can now be utilized as input for our isocortical flatmap visualization code, found [here](https://github.com/yongsookimlab/CorticalFlatMap). 
    - **Examples of test data output can be found in the shared folder [here](https://pennstateoffice365-my.sharepoint.com/:f:/g/personal/yuk17_psu_edu/EkTTKApE7aFLs7xzEMAnKloBq24jZ_rrKDmVWUt4mql93A?e=4DCPtz)**


### Quality Check for ML Cell Counting and Image Registration
> The purpose of this section is to utilize the scripts within the **quality_control** folder for quickly checking the segmentation accuracy of the trained ilastik ML for signal-containing voxels/cells and the image registration accuracy. It is helpful to use this tool during ML training and optimization. 

1. Download **quality_control** folder and ensure all components are inside:
     - **Run_QC1_QC2.m**
     - **quality_check_counting_setting_pack.m**
     - **quality_check_background.m**
     - **quality_check_counting.m**
2. Open the script **quality_check_counting_setting_pack.m** in MATLAB and copy settings from **RUN_THIS_FILE.m**. Additionally:
     - Set the stack_thickness = 0 to avoid z-overlapping.
     - Set "radii_draw" to a value (in micrometers) for the program to draw a circle around for the counted cells.
     - The "drawing_range" set to 3000 for the maximum contrast has previously worked for this purpose, but this number can be changed if desired.
3. Open **quality_check_counting.m** in MATLAB for counting quality check (QC1).
     - See commented code for details on input settings.
     - When run, this code will check the full resolution stitched images at the specified z-intervals and draw red circles around each counted cell based on the ilastik ML results. With this QC, it is easy to check whether the trained ML needs improvement. You can also use this to calculate an F-scpre.
4. Open **quality_check_background.m** in MATLAB for registration quality check (QC2).
     - See commented code for details on input settings.
     - When run, this code will use a rotated, downsized image TIF stack of the brain and elastix registration results to align the counted 3D voxels to the chosen 3D reference space. The result is a RGB image (NII and/or PNG file) with the aligned 3D counts in reference space. The warmer colors denote higher counts/density. With this QC, you can quickly check registration quality for specified z-intervals without performing elastix on the full dataset.
5. Save when finished with the settings for all three scripts.
6. Open **Run_QC1_QC2.m** and execute this MATLAB script to perform quality checks for both counting and registration.

   
> Contact: For questions or assistance, please contact the lab's principal investigator, Yongsoo Kim (yuk17@psu.edu).


## Limitations
This code was developed for 3D cell quantification utilizing whole brain imaging with the TissueCyte (TissueVision) STPT system in mind, which has specific parameters that may not apply to other imaging modalities. This code is compatible with 3D whole-brain images acquired with LSFM and is currently being optimized by the Yongsoo Kim Lab to improve the LSFM imaging workflow.


## License
- The epDevAtlas and associated code is licensed under a Creative Commons Attribution 4.0 International License as of December 1, 2023, but it is free and openly accessible for academic use.
- If you use this code anywhere, we would appreciate if you cite the following [preprint](https://www.biorxiv.org/content/10.1101/2023.11.24.568585v1):
  - **epDevAtlas: Mapping GABAergic cells and microglia in postnatal mouse brains**
    - Josephine K. Liwang, Fae A. Kronman, Jennifer A. Minteer, Yuan-Ting Wu, Daniel J. Vanselow, Yoav Ben-Simon, Michael Taormina, Steffy B. Manjila, Deniz Parmaksiz, Sharon W. Way, Hongkui Zeng, Bosiljka Tasic, Lydia Ng, Yongsoo Kim. bioRxiv 2023.11.24.568585; doi: https://doi.org/10.1101/2023.11.24.568585
