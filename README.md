# 3D Cell Type Quantification Pipeline for the Whole Mouse Brain 
- Created by the Yongsoo Kim Lab (https://kimlab.io/) in 2021
- For use with Microsoft Windows operating system. Code was built using Windows 10 (x64).

This package consists of codes designed to:
1. Implement a supervised machine learning-based approach (ilastik) for automated cell segmentation via pixel/object classification,
2. Image registration of serial two-photon tomography (STPT) or light sheet fluorescence microscopy (LSFM) stitched data to an age-matched reference brain template,
3. Registration of assigned and segmented voxels/"cells" to the reference space based on the common coordinate framework (CCF) system, and
4. Transformation of anatomical annotations (from the reference brain atlas) to the 

- Previously implemented for cell type mapping in the early postnatally developing mouse brain: https://www.biorxiv.org/content/10.1101/2023.11.24.568585v1 
  - Examples of generated data output (brain region volumes, cell densities, cell counts) from running this code package and its application can be viewed and downloaded here: https://kimlab.io/brain-map/epDevAtlas/

## Prerequisites
The following system requirements include software and tools that must first be downloaded/installed in your machine: 
- Windows 10, x64 operating system (tested) 
- MATLAB (MathWorks)
  - Tested using MATLAB versions R2020a and R2021b
- Fiji (ImageJ2): https://imagej.net/software/fiji/
  - Tested using ImageJ (1.53t) with Java 1.8.0_172 (64-bit)
- ilastik: https://www.ilastik.org/documentation/basics/installation or https://github.com/ilastik/ilastik
- Python: https://www.python.org/downloads/
  - Tested using Python versions 3.8.3 and 3.9.7
- Mouse brain reference atlas of choice (e.g., Allen CCFv3, DevCCF, epDevAtlas, etc) consisting of averaged templates and anatomical labels

Overview
This MATLAB script is designed for a comprehensive 3D cell counting pipeline for whole mouse brain images. The pipeline includes background subtraction, normalization, registration, and cell counting using different methods. The script provides flexibility through various switches, allowing users to customize the workflow based on their specific experimental setup.

## How To Use
MATLAB installed on your machine.
The ilastik software for machine learning-based cell counting. Ensure ilastik is installed and its location is correctly specified in the script.
File Structure
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
Contact:
For questions or assistance, please contact Y. Wu (original author) or J. Liwang (last modifier) in the Kim Lab.

Note: This README provides a general overview. It's crucial to refer to the script comments for detailed information on each section and parameter.



## Limitations


## Environment
The code was developed and tested on
- MATLAB 2019a
- ImageJ (FIJI) win64

## License
Free academic use.
