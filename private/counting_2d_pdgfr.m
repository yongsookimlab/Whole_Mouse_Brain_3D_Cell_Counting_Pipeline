function [] = counting_2d_pdgfr(images_in_folder, images_out_folder,targeting_folder, xyz_resolution, targeting_resolution, brain_xyz_orientation)


%%%% sanity check
full_brain_xyz_orientation_1 = ceil(brain_xyz_orientation./2);
% full_brain_xyz_orientation_2 = mod(brain_xyz_orientation,2);

[broken_check, ~] = ismember([1 2 3], full_brain_xyz_orientation_1);

if ~all(broken_check)
    error('brain_xyz_orientation wrong')
end
%%%% end of sanity check

%%%% setting


nmz_in_tif_list = natsortfiles(dir([images_in_folder '/*.tif']));
nmz_out_tif_list = natsortfiles(dir([images_out_folder '/*.tif']));

pericite_id = 1;
smc_id = 3;

minimum_pericyte_pixel = 25;
maximum_pericyte_pixel = inf;
minimum_smc_toucing = 5;

dialte_size = 1;
SE = strel('disk',dialte_size);


%%% End of Setting

centroid_cord_pericyte ={};
centroid_cord_pericyte_smc_touching ={};
shrinked_smc_pix_count ={};

parfor jj = 1:length(nmz_in_tif_list)
    
    
    img_out_temp = imread(strcat(nmz_out_tif_list(jj).folder, '/', nmz_out_tif_list(jj).name));
    logic_pericyte = (img_out_temp == pericite_id);
    logic_smc = (img_out_temp == smc_id);
    
    indx_smc_touching_pericyte = find(imdilate(logic_smc,SE) & logic_pericyte);
    
    pericyte_counting = bwconncomp(logic_pericyte,4);
    pericyte_counting.voxel_count = zeros(size(pericyte_counting.PixelIdxList));
    for kk = 1:length(pericyte_counting.PixelIdxList)
        pericyte_counting.voxel_count(kk) = length(pericyte_counting.PixelIdxList{kk});
    end
    
    flagg = (pericyte_counting.voxel_count >= minimum_pericyte_pixel) & (pericyte_counting.voxel_count <=maximum_pericyte_pixel);
    
    pericyte_counting.voxel_count = pericyte_counting.voxel_count(flagg);
    pericyte_counting.PixelIdxList = pericyte_counting.PixelIdxList(flagg);

    pericyte_counting.smc_touching_yes = false(size(pericyte_counting.PixelIdxList));
	pericyte_counting.xxx = zeros(size(pericyte_counting.PixelIdxList));
	pericyte_counting.yyy = zeros(size(pericyte_counting.PixelIdxList));
    
    for kk = 1:length(pericyte_counting.PixelIdxList)
        pericyte_counting.smc_touching_yes(kk) = (nnz(ismember(pericyte_counting.PixelIdxList{kk}, indx_smc_touching_pericyte)) >= minimum_smc_toucing);
        
        [xxx_temp, yyy_temp] = ind2sub(pericyte_counting.ImageSize,pericyte_counting.PixelIdxList{kk});
        pericyte_counting.xxx(kk) = mean(xxx_temp);
        pericyte_counting.yyy(kk) = mean(yyy_temp);
    end
    
    
    pericyte_counting.zzz = pericyte_counting.xxx;
    pericyte_counting.zzz(:) = jj;
    
    centroid_cord_pericyte{jj}= [pericyte_counting.xxx(~pericyte_counting.smc_touching_yes)', pericyte_counting.yyy(~pericyte_counting.smc_touching_yes)', pericyte_counting.zzz(~pericyte_counting.smc_touching_yes)'];
    centroid_cord_pericyte_smc_touching{jj}= [pericyte_counting.xxx(pericyte_counting.smc_touching_yes)', pericyte_counting.yyy(pericyte_counting.smc_touching_yes)', pericyte_counting.zzz(pericyte_counting.smc_touching_yes)'];
    
    [s_xxx, s_yyy] = ind2sub(size(logic_smc), find(logic_smc)); 
    s_xxx = ceil(s_xxx.*xyz_resolution(1)./targeting_resolution);
    s_yyy = ceil(s_yyy.*xyz_resolution(2)./targeting_resolution);

    ImageSize = ceil(size(logic_smc) .* xyz_resolution(1:2) ./ targeting_resolution);
    shrinked_smc_pix_count{jj} = accumarray([s_xxx,s_yyy], 1, ImageSize);

    
    
end

fprintf('Counting done \n');

disp( datestr(datetime('now')))

making_cell_counted_output(brain_xyz_orientation,nmz_in_tif_list, xyz_resolution, targeting_resolution, centroid_cord_pericyte, targeting_folder, 'pericyte_mv');
making_cell_counted_output(brain_xyz_orientation,nmz_in_tif_list, xyz_resolution, targeting_resolution, centroid_cord_pericyte_smc_touching, targeting_folder, 'pericyte_smc');

making_area_counted_output(brain_xyz_orientation,nmz_in_tif_list, xyz_resolution, targeting_resolution, shrinked_smc_pix_count, targeting_folder,'smc_coverage');


% save('testing_asdasd.mat');






































