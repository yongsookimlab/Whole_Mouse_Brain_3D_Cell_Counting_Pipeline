
%% Whole Mouse Brain 3D Cell Counting Pipeline v0.01
% Created by the Yongsoo Kim Lab at Penn State College of Medicine
% Written by Y. Wu on 20220126
% Last modified and updated by J. Liwang on 20230214:
% - Background subtraction switch added to start of pipeline. Output folder = Signal_minus_noise
% - Added option to include additional trained classifier value (from ilastik) in "counting_2d_max_addlabel.m" for 2D cell counting using ML + local maximum 

clear
close all

%% Essential Settings - editing required

%%% Input file pathname of main directory with stitched STPT or LSFM imaged data (TIFs); this will also be the data output location.
targeting_folder = 'Y:\Lab_members\Josephine\40c_transfer\CtxLayer_celltype_mapping_LydiaNg_Allen\L1_Slc32a1-Lamp5\663537_M_P10_Slc32a1-Lamp5-Ai65_BIL0539050842'; 

%%% Input file pathname for ilastik ML project file (.ilp)
project_name = ['D:\Lab_Members\Josephine\ilastik\20230321_Slc32a1_Lamp5_Ai65_JL_v1.ilp']; 

%%% Input file pathname for averaged mouse brain template from epDevAtlas or AllenCCFv3 (20um isotropic, unsigned 16 bit, TIF only) 
reference_brain_background = [pwd, '/reference_brain/STPT/T_P10_STPT_Symmetric20um_template0_masked_iso20um_u16.tif'];

%%% Input file pathname for the reference brain annotations (20um isotropic, unsigned 16 bit, TIF only).
allen_anno = strcat(pwd, '/reference_brain/STPT/P10_CCFv3_annotations_16b_v3_iso20um_u16.tif'); 
% Ensure annotation file matches the xyz resolution (ie. 20um isotropic) and orientation of the reference template brain. 


%% Basic Settings - may need editing

%%% Folder name for the stitched image TIFs -> signal channel
images_in_ch_folder = [targeting_folder, '/stitchedImage_ch1']; 

%%% Folder name for the stitched image TIFs -> for registration
registering_ch_folder = [targeting_folder, '/stitchedImage_ch2']; 

%%% Folder name for stitched image TIFs if using background subtraction -> "noise" channel
background_ch_folder = [targeting_folder, '/stitchedImage_ch2']; 

%%% Output images from background subtraction function that may be used for ML counting -> DO NOT CHANGE FOLDER NAME
subtracted_ch_folder = [targeting_folder, '/Signal_minus_Noise']; 

%%% Input file pathname for Allen CCFv3 anatomical labels (.csv) in ontological order with RGB color coding, which should be saved in the same folder as the reference brain template. CSV can be downloaded from -> https://kimlab.io/brain-map/epDevAtlas/
ref_csv_name = [pwd, '/reference_brain/16bit_allen_csv_20200916.csv'];

%%% Set location of the installed ilastik application (.exe) -> This should be saved within the parent directory of code package. Check OneDrive for folder structure.
ilastik_location = [pwd,'/ilastik/ilastik'];

%%% Set the folder name for the ilastik ML output (TIFs). Output will be deposited in targeting folder.
images_ML_folder = [targeting_folder, '/ml_result'];

%%% Orientation: Brain template must be in coronal view, going from posterior to anterior direction as Z-depth increases (e.g. Z001 -> Z625) 
%%% The file location and pathname must be consistent with the folder structure in OneDrive. It should be saved within the parent directory of the code package.

%%% Input the x, y, and z resolution (in micrometers) of the stitched image.
xyz_resolution = [1.00 1.00 50]; % STPT [1.00 1.00 50], LSFM [1.80 1.80 5]

%%% Set the target resolution (in micrometers) for downsized TIFs. 
targeting_resolution = 20;

%%% Confirm the imaged brain's xyz orientation. 
brain_xyz_orientation = [3 2 5]; 
% Usually, our STPT images have [x+, y+, z+] orientation of [3 2 5] -> Example: Coronal brain with its ventral side on the left and dorsal surface facing the right. As Z-depth increases, the brain goes from posterior to anterior.
% Our LSFM images typically have an orientation of [x+, y+, z+] = [6 3 1] -> Example: In horizontal brain images, the anterior (rostral) side faces upward and the posterior (caudal) side faces downward along the acquired Z-plane. The Z-depth progresses from the dorsal to the ventral side of the brain.

%%% Notes about brain_xyz_orientation:
%%% [x+, y+, z+] -> Each variable represents the "direction" of brain orientation 
%%% x+: (image on screen) up->down, y+: (image on screen) left->right, z+: z00->z99
%%% Values connote direction of brain orientation: 
%%% 1: ventral, 2: dorsal
%%% 3: medial, 4: lateral % If imaging a full brain, this will always be medial.
%%% 5: anterior, 6: posterior


%% Optional Settings

%%% Normalization of image intensity:
%%% The code can use a TIF stack to compute the average pixel intensity of the imaged brain. Normalized (adjusted) images will be stored in the "normalized_images_folder" for later use. 
  
%%% Input folder name for normalized image TIFs (only if using additional normalization function).
normalized_images_folder = [targeting_folder, '/stitchedImage_chx_n'];

%%% Set the signal amplification factor (if using additional normalization function).
normalizing_intensity_target = 1000; % This value is usually set to 1000.


%%% Nucleus (or other solid spherical shape) counting using 3D fast Fourier transform (FFT) and water shedding:
%%% The code can utilize simple high intensity peaks for nucleus counting and avoid over-counting in 2D and 3D.

%%% Set the expected cell and nucleus size (in micrometers) and settings for 3D fast Fourier transform (FFT)-based nucleus counting.
num_cpu = 16; % Setting for 3D FFT-based nucleus counting. Do not change.
expected_nuc_size = 10; % Expected nucleus size.
intensity_thresh = 0.6; % The intensity of the cell vs the background; 0.6 meaning 60% brighter -> Setting for 3D FFT-based counting


%%% Pixel counting:
%%% If performing pixel counting, set the file names for the output.
pixel_counted_nii_name = [targeting_folder, '/pixel_coverage.nii'];
pixel_counted_csv_name = [targeting_folder, '/pixel_coverage.csv'];
pixel_rev_registrated_folder = [targeting_folder, '/pix_rev_registration'];

%%% Ignore below:
%shrinked_folder = [targeting_folder, '/stitched_00_shrink'];
%shrinked_file = [targeting_folder, '/warping/20211215_JL_JL0287_M_P8_PV-Cre-Ai14C-8_ch1_p05.tif'];



%% Functional Switches for Cell Counting Pipeline - see notes below

background_subtraction_switch = 0;
normalization_switch = 0; % if applying ML counting to newly subtracted images, edit "normalization_switch" under "Pipeline" and make all "normalized_images_folder = subtracted_ch_folder"
counting_switch = 3; % 2 for LSFM, 3 for STPT
registration_switch = 1;
csv_switch = 1;
reverse_registration_switch = 1;
normalization_ratio = 2; % 2 for STPT. Do not change.


%% Notes for Functional Switches:

%%% background_subtraction_switch
%%% 0: Do not perform background subtraction.
%%% 1: Perform background subtraction to enhance signal (channel subtraction tifs in separate output folder called Signal_minus_Noise).

%%% normalization_switch
%%% 0: Do not perform normalization. If normalization folder does not exist, code will redirect to images_in_ch_folder OR subtracted_ch_folder (THIS MUST BE SPECIFIED BELOW)
%%% 1: Normalize using shrinked_folder (LSFM).
%%% 2: Normalize using shrinked_file (STPT). There is no need to do this if "TracibleTissueCyteStitching" code (on GitHub) was used for STPT stitching since normalization is already built in.

%%% counting_switch
%%% 0: Do not perform any counting.
%%% 1: Perform 3D nucleus counting using FFT
%%% 2: Perform 3D cell counting using ML -> This option avoids over counting in Z direction, but two touching cells in 2D/3D will be counted as one cell. This is the switch used for LSFM cell counting.
%%% 3: Perform 2D cell counting using ML + local maximum -> Use this as the go-to switch for STPT-based cell counting. This option avoids over counting in X and Y directions, but will count two cells as one if touching in Z direction. Since STPT z-sections are 50um, there is no issue and 1.4x factor is applied for 2D to 3D conversion.
%%% 4: Perform pixel counting using ML

%%% registration_switch
%%% 0: Do not perform image registration using elastix. 
%%% 1: Use elastix to perform image registration of imaged brain sample to the reference brain template.

%%% csv_switch
%%% 0: Do not create a CSV file of cell counts. 
%%% 1: Create a CSV file with binned cell counts based on registration of imaged brain to reference brain. 
%%% 2: Create a CSV for pixel counting only.

%%% reverse_registration_switch
%%% 0: Do not perform reverse registration.
%%% 1: Perform reverse registration of atlas labels to the imaged brain in reference space (this requires elastix registration to be done first) 
%%% 2: Reverse registration for pixel counting only.



%% Pipeline:

switch background_subtraction_switch
    case 0
    case 1
        RUN_BgSubtractor(images_in_ch_folder, background_ch_folder, normalization_ratio)
end


switch normalization_switch
    case 0
        if ~isfolder(normalized_images_folder)
            normalized_images_folder = images_in_ch_folder; % Use "images_in_ch_folder" for acquired signal channel images, change to "subtracted_ch_folder" for new background-subtracted images
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
        mkdir(images_ML_folder);
        ilastik_loop_all_img(ilastik_location, project_name, normalized_images_folder, images_ML_folder);
        counting_3d(images_ML_folder,targeting_folder, xyz_resolution, targeting_resolution, brain_xyz_orientation);
    case 3
        mkdir(images_ML_folder);
        ilastik_loop_all_img(ilastik_location, project_name, normalized_images_folder, images_ML_folder);
        counting_2d_max(normalized_images_folder, images_ML_folder,targeting_folder, xyz_resolution, targeting_resolution, brain_xyz_orientation);
        %counting_2d_max_addlabel(normalized_images_folder, images_ML_folder,targeting_folder, xyz_resolution, targeting_resolution, brain_xyz_orientation); % If intending to count an additional labeled classifier.
    case 4
        mkdir(images_ML_folder);
        ilastik_loop_all_img(ilastik_location, project_name, normalized_images_folder, images_ML_folder);
        counting_2d_pixel_count(images_ML_folder,targeting_folder, xyz_resolution, targeting_resolution, brain_xyz_orientation, pixel_counted_nii_name);
end


switch registration_switch
    case 0
    case 1
        make_shrink_file(targeting_folder, registering_ch_folder, brain_xyz_orientation, xyz_resolution(1), xyz_resolution(3), targeting_resolution);
        %registeringg_anno_to_real_space_adult(targeting_folder, reference_brain_background,allen_anno); % For adult brain.
        registeringg_anno_to_real_space_earlypostnatal(targeting_folder, reference_brain_background,allen_anno); % For early postnatal brain
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

