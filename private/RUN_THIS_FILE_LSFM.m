
%%% Counting pipeline v0.01

clear
close all

%%% Basic Setting

targeting_folder = 'Z:\LSFM\2022\2022_04\20220419_JL_JL0328_M_P6_Cx3cr1_eGFP_488GFP_561Bg_4x_5umstep_LC_45C_reimaged_Lsht'; % the main cluster folder to put all the output
images_in_ch_folder = [targeting_folder, '/stitched_00'];  % folder name for the raw image tif -> signal channel
registering_ch_folder = [targeting_folder, '/stitched_01']; % folder name for the image tif for registration
background_ch_folder = [targeting_folder, '/stitchedImage_ch3']; % folder name for image tif if using background subtraction -> "noise" channel
subtracted_ch_folder = [targeting_folder, '/Signal_minus_Noise']; % DO NOT CHANGE THIS FOLDER NAME -> output images from background subtraction function

project_name = ['Z:\Lab-Protocols\ilastik\LSFM\JL_working\Microglia_ilastik\20220425_Cx3cr1_eGFP_LSFM_JL_v1.ilp'];

shrinked_folder = [targeting_folder, '/stitched_00_shrink']; % This is for lightsheet normalization
shrinked_file = [targeting_folder, '/warping/20211215_JL_JL0287_M_P8_PV-Cre-Ai14C-8_ch1_p05.tif'];  % this is for STPT normalization, but my stpt stiching is already normalized
reference_brain_background = [pwd, '/reference_brain/TP_artistic_20210721.tif'];
%%% TP_artistic_20210721 for lightsheet, average_template_coronal_10_pa for STPT


xyz_resolution = [1.80 1.80 5]; % STPT [1.00 1.00 50], LSFM [1.80 1.80 5]
targeting_resolution = 20;
brain_xyz_orientation = [6 3 1]; % STPT [3 2 5], LSFM [6 3 1] if anterior brain faces inside of microscope and dorsal side is facing up

%%% [x+, y+, z+]
%%% x+: picture up->down, y+: picture left->right, z+: z00->z99
%%% orientation number 
%%% 1: venteral , 2: dorsal
%%% 3: medial, 4: lateral % full brain is always toward medial
%%% 5: anterial ,  6: posterial


%%% Functional Switch

background_subtraction_switch = 0;
normalization_switch = 0; % if applying ML counting to newly subtracted images, edit "normalization_switch" under "Pipeline" and make all "normalized_images_folder = subtracted_ch_folder"
counting_switch = 2;
registration_switch = 1;
csv_switch = 1;
reverse_registration_switch = 1;

%%% background_subtraction_switch
%%% 0: no, do nothing
%%% 1: yes, perform background subtraction to enhance signal (channel subtraction tifs in separate output folder called Signal_minus_Noise)

%%% normalization_switch
%%% 0: no normalization - if normalization folder does not exist, will redirect to images_in_ch_folder OR subtracted_ch_folder (MUST SPECIFY)
%%% 1: normalize using shrinked_folder (LS),
%%% 2: normalize using shrinked_file (STPT), note, my STPT stitching should already normalize trhe brain

%%% counting_switch
%%% 0: do nothing
%%% 1: 3D nucleus counting using FFT
%%% 2: 3D cell counting using ML
%%% 3: 2D cell counting using ML + local maximum
%%% 4: ML pixel count

%%% registration_switch
%%% 0: no, 1: yes

%%% csv_switch
%%% 0: no, 1: yes, 2: pix

%%% reverse_registration_switch
%%% 0: no, 1: yes (this require the registration) 2: pix




%%% Pro Settings 

normalized_images_folder = [targeting_folder, '/stitchedImage_chx_n'];  % folder name for the normalized image tif
images_ML_folder = [targeting_folder, '/ml_result'];  % folder name for the ML image tif

normalizing_intensity_target = 1000; % setting for normalization

num_cpu = 16; % setting for 3d fft nuc counting
expected_nuc_size = 10; % expected nucleus size in um % setting for 3d fft nuc counting
intensity_thresh = 0.6; % the intensity of the nuc vs the back ground, 0.6 meaning 60% brighter % setting for 3d fft nuc counting

ilastik_location = [pwd,'/ilastik/ilastik'];

ref_csv_name = [pwd, '/reference_brain/16bit_allen_csv_20200916.csv'];
allen_anno = strcat(pwd, '/reference_brain/allen_20_anno_16bit_pa.tif');

pixel_counted_nii_name = [targeting_folder, 'pixel_coverage.nii'];
pixel_counted_csv_name = [targeting_folder, '/pixel_coverage.csv'];
pixel_rev_registrated_folder = [targeting_folder, '/pix_rev_registration'];


%%% Machine Learning Notes
% system([pwd,'/ilastik/ilastik'])

%%% the above line is not really a matlab code rather a short cut
%%% run ilastik using this line above or just go into the ilastik
%%% folder and click on the ilastik.exe
%%% - your project should be 'pixel classifacation'
%%% - label 1 empty background
%%% - label 2 brain tissue background
%%% - label 3 cell (signal #1)
%%% - label 4.. optional (signal #2..)



%%% Pipeline

switch background_subtraction_switch
    case 0
    case 1
        RUN_BgSubtractor(images_in_ch_folder, background_ch_folder)
end


switch normalization_switch
    case 0
        if ~isfolder(normalized_images_folder)
            normalized_images_folder = images_ch_folder; % FOR ALL "images_in_ch_folder" for acquired signal ch images, change to "subtracted_ch_folder" for newly subtracted ch images
        end
    case 1
        mkdir(normalized_images_folder);
        normalizing__shrink_folder(images_in_ch_folder, normalized_images_folder, shrinked_folder, normalizing_intensity_target);
    case 2
        mkdir(normalized_images_folder);
        normalizing_single_shrink_file(images_in_ch_folder, normalized_images_folder, shrinked_file, normalizing_intensity_target);
end


switch counting_switch
    case 0
    case 1
        fft_three_d_counting(targeting_folder, images_in_ch_folder, num_cpu, brain_xyz_orientation, xyz_resolution(1), xyz_resolution(3), targeting_resolution, expected_nuc_size, intensity_thresh);
    case 2
        %mkdir(images_ML_folder);
        %ilastik_loop_all_img(ilastik_location, project_name, normalized_images_folder, images_ML_folder);
        counting_3d(images_ML_folder,targeting_folder, xyz_resolution, targeting_resolution, brain_xyz_orientation);
    case 3
        
        mkdir(images_ML_folder);
        ilastik_loop_all_img(ilastik_location, project_name, normalized_images_folder, images_ML_folder);
        counting_2d_max(normalized_images_folder, images_ML_folder,targeting_folder, xyz_resolution, targeting_resolution, brain_xyz_orientation);
    case 4
        mkdir(images_ML_folder);
        ilastik_loop_all_img(ilastik_location, project_name, normalized_images_folder, images_ML_folder);
        
        counting_2d_pixel_count(images_ML_folder,targeting_folder, xyz_resolution, targeting_resolution, brain_xyz_orientation, pixel_counted_nii_name);
end


switch registration_switch
    case 0
    case 1
        make_shrink_file(targeting_folder, registering_ch_folder, brain_xyz_orientation, xyz_resolution(1), xyz_resolution(3), targeting_resolution);
        registeringg_anno_to_real_space(targeting_folder, reference_brain_background,allen_anno)
end

switch csv_switch
    case 0
    case 1
        post_processing(targeting_folder,targeting_resolution,ref_csv_name);
    case 2
        post_processing_area(targeting_folder,targeting_resolution, pixel_counted_nii_name, pixel_counted_csv_name, ref_csv_name);
end

switch reverse_registration_switch
    case 0
    case 1
        post_processing2(targeting_folder,allen_anno);
    case 2
        post_processing2_area(targeting_folder, pixel_counted_nii_name, pixel_rev_registrated_folder, allen_anno);
end

