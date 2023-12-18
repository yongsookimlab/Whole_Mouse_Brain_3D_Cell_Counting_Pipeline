function [] = Quality_control(targeting_folder, images_in_folder, xyz_resolution, targeting_resolution, brain_xyz_orientation, frame_inspecting, stack_thickness)

% Settings

% targeting_folder = 'Z:/STPT/GliaMorph_processed/20210917_JL_JL0245_X_P17_Aldh1l1-GFP'
% targeting_folder = 'Z:/STPT/GliaMorph_processed/20210920_JL_JL0243_X_P8_Aldh1l1-GFP'
% targeting_folder = 'Z:\STPT\GliaMorph_processed\20210927_JL_JL0241_X_P4_Aldh1l1-GFP'
% targeting_folder = 'Z:\STPT\GliaMorph_processed\20210923_JL_JL0258_X_P15_MOBP-EGFP_O-MAP2'
% targeting_folder = 'Z:\STPT\GliaMorph_processed\20211001_JM_JL0259_X_P21_MOBP-EGFP_O-MAP3'
% targeting_folder = 'Z:/STPT/DevCCF_processed/GAD2/P56/20210709_JL_JL0006_F_P56_GAD2-Cre_Ai14C-6-1'
% targeting_folder = 'Z:/LSFM/2021/2021_06/20210624_SM_K644_C57_42_6_M_Gbg_ROXT_fRAVP_rshtlsht_4x';
% targeting_folder = 'Z:/LSFM/2021/2021_06/20210623_SM_K641_C57_42_6_M_Gbg_ROXT_fRAVP_rshtlsht_4x';
% 
% images_in_folder = [targeting_folder, '/stitched_01']
% registering_ch = [targeting_folder, '/stitched_01']

% shrinked_folder = [targeting_folder, '/stitchedImage_ch1']  %%% For LS
% shrinked_file = [targeting_folder, '/warping/20210927_JL_JL0241_X_P4_Aldh1l1-GFP_ch2_p05.tif']  %%% For 2P

% normalized_images_in_folder = [targeting_folder, '/normalized']
% images_out_folder = [targeting_folder, '/out']

% ilastik_location = [pwd,'/ilastik/ilastik']
% project_name = ['E:\astrocyte_counting/MyProject.ilp']
% mkdir(images_out_folder);

% normalizing_intensity_target = 1000;

% xyz_resolution = [1.87 1.87 5];
% targeting_resolution = 10;
% 
% brain_xyz_orientation = [6 3 2];
%%% x: picture down, y: picture right, z: z00->z99
%%% orientation number
%%% 1: venteral , 2: dorsal
%%% 3: medial, 4: lateral % full brain is always toward medial
%%% 5: anterial ,  6: posterial


load([targeting_folder, '/counted_3d_cordinates.mat']);

centroid_cord_all_shrink = [centroid_cord_all_shrink(:,2),centroid_cord_all_shrink(:,1),centroid_cord_all_shrink(:,3)];

nmz_in_tif_list = natsortfiles(dir([images_in_folder '/*.tif']));
% nmz_out_tif_list = natsortfiles(dir([images_out_folder '/*.tif']));

img_in_temp = imread(strcat(nmz_in_tif_list(1).folder, '/', nmz_in_tif_list(1).name));

ImageSize = ceil([size(img_in_temp), length(nmz_in_tif_list)] .* xyz_resolution ./ targeting_resolution);

size_temp_loaded_img = size(img_in_temp);
% 


full_brain_xyz_orientation_1 = ceil(brain_xyz_orientation./2);

full_brain_xyz_orientation_2 = mod(brain_xyz_orientation,2);


if ~isequal(full_brain_xyz_orientation_1,[1 2 3])
    centroid_cord_all_shrink(:,full_brain_xyz_orientation_1) = centroid_cord_all_shrink(:,:);
end

for ii = 1:3
    if full_brain_xyz_orientation_2(ii) == 0
        centroid_cord_all_shrink(:,ii) =  ImageSize(ii) - centroid_cord_all_shrink(:,ii) ;
    end
end


shrink_x = (centroid_cord_all_shrink(:,1)).*size_temp_loaded_img(1)./ImageSize(1)+0.5;
shrink_y = (centroid_cord_all_shrink(:,2)).*size_temp_loaded_img(2)./ImageSize(2)+0.5;
shrink_z = (centroid_cord_all_shrink(:,3)).*length(nmz_in_tif_list)./ImageSize(3)+0.5;




% stack_thickness = 2;


for jj = frame_inspecting
    
    img_in_temp = imread(strcat(nmz_in_tif_list(jj).folder, '/', nmz_in_tif_list(jj).name));
    
    for kk = jj-stack_thickness : jj+stack_thickness-1
        img_in_temp = max(cat(3,img_in_temp,imread(strcat(nmz_in_tif_list(kk).folder, '/', nmz_in_tif_list(kk).name))),[],3);
    end
    
    
    ImageSize = ceil([size(img_in_temp), length(nmz_in_tif_list)] .* xyz_resolution ./ targeting_resolution);
    
    size_temp_loaded_img = size(img_in_temp);
    
    
    figure;imshow(img_in_temp, [0 2000]);hold;
    
    
    flagg = (shrink_z >= jj-stack_thickness-0.5) &( shrink_z <= jj+stack_thickness+0.5);
    
    scatter(shrink_y(flagg),shrink_x(flagg),60,'r');
    
end






% 

