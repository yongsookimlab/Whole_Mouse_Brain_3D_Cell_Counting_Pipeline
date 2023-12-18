
%%% Basic Setting

images_in_ch_folder = [targeting_folder, '\stitchedImage_ch2_tileNormalized']  % folder name for the raw image tif
registering_ch_folder = [targeting_folder, '\stitchedImage_ch1'] % folder name for the image tif for

project_name = ['D:\Lab_Members\Josephine\ilastik\20221214_Cx3cr1_HET_microglia_STPT_JL_v1.ilp']

reference_brain_background = ['D:\Lab_Members\Josephine\MATLAB_codes\20220126_YTW_counting_pro_v0_01_JL_BgSubAddOn\reference_brain\STPT\T_P04_STPT_Symmetric20um_template0_masked_iso20um_u16.tif'] % diff ref brain background for STPT vs LSFM


xyz_resolution = [1.00 1.00 50]; % STPT [1.00 1.00 50], LSFM [1.80, 1.80 5]
targeting_resolution = 20;
brain_xyz_orientation = [3 2 5]; % STPT [3 2 5], LSFM [6 3 1]




%%% Pro Settings 

normalized_images_folder = [targeting_folder, '/stitchedImage_chx_n'];  % folder name for the normalized image tif
images_ML_folder = [targeting_folder, '/ml_result'];  % folder name for the ML image tif

normalizing_intensity_target = 1000; % setting for normalization

num_cpu = 16; % setting for 3d fft nuc counting
expected_nuc_size = 10; % expected nucleus size in um % setting for 3d fft nuc counting
intensity_thresh = 0.6; % the intensity of the nuc vs the back ground, 0.6 meaning 60% brighter % setting for 3d fft nuc counting

ilastik_location = [pwd,'/ilastik/ilastik'];

ref_csv_name = ['D:\Lab_Members\Josephine\MATLAB_codes\20220126_YTW_counting_pro_v0_01_JL_BgSubAddOn\reference_brain\16bit_allen_csv_20200916.csv'];
allen_anno = strcat('D:\Lab_Members\Josephine\MATLAB_codes\20220126_YTW_counting_pro_v0_01_JL_BgSubAddOn\reference_brain\STPT\P04_CCFv3_annotations_16b_v3_iso20um_u16.tif');

pixel_counted_nii_name = [targeting_folder, '/pixel_coverage.nii'];
pixel_counted_csv_name = [targeting_folder, '/pixel_coverage.csv'];
pixel_rev_registrated_folder = [targeting_folder, '/pix_rev_registration'];

stack_thickness = 0; % z overlaping 
radii_draw = 15; % circle size
drawing_range = 3000; % contrast max