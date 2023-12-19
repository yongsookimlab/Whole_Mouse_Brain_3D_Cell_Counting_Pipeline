
%%% Essential Settings for Running QC1 and QC2 Together

stack_thickness = 0; % Z-overlapping 
radii_draw = 15; % Size (in micrometers) of red circle to be drawn around counted cell
drawing_range = 3000; % Contrast maximum

%% For input settings below, you can copy the settings from RUN_THIS_FILE.m

% Input folder name for stitched image TIFs containing signal-of-interest.
images_in_ch_folder = [targeting_folder, '\stitchedImage_ch2']; 

% Input folder name for stitched image TIFs containing background autofluorescence for registration.
registering_ch_folder = [targeting_folder, '\stitchedImage_ch1']; 

% Input ilastik project folder name and path.
project_name = ['D:\Lab_Members\Josephine\ilastik\20221214_Cx3cr1_HET_microglia_STPT_JL_v1.ilp'];

% Input file pathname for averaged mouse brain template from epDevAtlas or AllenCCFv3 (20um isotropic, unsigned 16 bit, TIF only) 
reference_brain_background = ['D:\Lab_Members\Josephine\MATLAB_codes\20220126_YTW_counting_pro_v0_01_JL_BgSubAddOn\reference_brain\STPT\T_P04_STPT_Symmetric20um_template0_masked_iso20um_u16.tif']; 

% Input the x, y, and z resolution (in micrometers) of the stitched image.
xyz_resolution = [1.00 1.00 50]; % STPT [1.00 1.00 50]

% Input file pathname for Allen CCFv3 anatomical labels (.csv) in ontological order with RGB color coding, which should be saved in the same folder as the reference brain template. CSV can be downloaded from -> https://kimlab.io/brain-map/epDevAtlas/
ref_csv_name = ['D:\Lab_Members\Josephine\MATLAB_codes\20220126_YTW_counting_pro_v0_01_JL_BgSubAddOn\reference_brain\16bit_allen_csv_20200916.csv'];

% Input file pathname for the reference brain annotations (20um isotropic, unsigned 16 bit, TIF only).
allen_anno = strcat('D:\Lab_Members\Josephine\MATLAB_codes\20220126_YTW_counting_pro_v0_01_JL_BgSubAddOn\reference_brain\STPT\P04_CCFv3_annotations_16b_v3_iso20um_u16.tif');

% Set the target resolution (in micrometers) for downsized TIFs.
targeting_resolution = 20;

% Confirm the imaged brain's xyz orientation.
brain_xyz_orientation = [3 2 5]; % STPT [3 2 5]

% Set location of the installed ilastik application (.exe) -> This should be saved within the parent directory of code package. Check OneDrive for folder structure.
ilastik_location = [pwd,'/ilastik/ilastik'];

% Output folder name for the ML image TIFs
images_ML_folder = [targeting_folder, '/ml_result'];  



%%% Optional Settings

% Input folder name for normalized image TIFs (only if using additional normalization function).
normalized_images_folder = [targeting_folder, '/stitchedImage_chx_n']; 

% Set the signal amplification factor (if using additional normalization function).
normalizing_intensity_target = 1000; % setting for normalization

% Set the expected cell and nucleus size (in micrometers) and settings for 3D fast Fourier transform (FFT)-based nucleus counting.
num_cpu = 16; % setting for 3d fft nuc counting
expected_nuc_size = 10; % expected nucleus size in um % setting for 3d fft nuc counting
intensity_thresh = 0.6; % the intensity of the nuc vs the back ground, 0.6 meaning 60% brighter % setting for 3d fft nuc counting

%%% If performing pixel counting, set the file names for the output.
pixel_counted_nii_name = [targeting_folder, '/pixel_coverage.nii'];
pixel_counted_csv_name = [targeting_folder, '/pixel_coverage.csv'];
pixel_rev_registrated_folder = [targeting_folder, '/pix_rev_registration'];

