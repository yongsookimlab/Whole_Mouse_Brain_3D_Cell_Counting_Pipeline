# 3D Cell Type Quantification Pipeline for the Whole Mouse Brain 
- Created by the Yongsoo Kim Lab (https://kimlab.io/) in 2021.

This package consists of codes designed to:
1. Implement a supervised machine learning-based approach (ilastik) for automated cell segmentation via pixel/object classification,
2. Image registration of serial two-photon tomography (STPT) or light sheet fluorescence microscopy (LSFM) stitched data to an age-matched reference brain template,
3. Registration of assigned and segmented voxels/"cells" to the reference space based on the common coordinate framework (CCF) system, and
4. Transformation of anatomical annotations (from the reference brain atlas) to the 

- Previously implemented for cell type mapping in the early postnatally developing mouse brain: https://www.biorxiv.org/content/10.1101/2023.11.24.568585v1 
  - Examples of generated data output (brain region volumes, cell densities, cell counts) from running this code package and its application can be viewed and downloaded here: https://kimlab.io/brain-map/epDevAtlas/

## How To Use
The following software and tools must first be downloaded/installed in your computer before code launch: 
- MATLAB
- ImageJ (FIJI): https://imagej.net/software/fiji/
- ilastik: https://www.ilastik.org/documentation/basics/installation
- Python: https://www.python.org/downloads/
- Mouse brain reference atlas of choice (e.g., Allen CCFv3, DevCCF, epDevAtlas, etc) consisting of averaged templates and anatomical labels





## Limitations


## Environment
The code was developed and tested on
- MATLAB 2019a
- ImageJ (FIJI) win64

## License
Free academic use.
