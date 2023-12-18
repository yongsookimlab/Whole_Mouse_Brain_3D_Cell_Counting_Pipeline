function [] = counting_2d_pixel_count(images_out_folder,targeting_folder, xyz_resolution, targeting_resolution, brain_xyz_orientation, out_file_name)


%%%% sanity check
full_brain_xyz_orientation_1 = ceil(brain_xyz_orientation./2);
% full_brain_xyz_orientation_2 = mod(brain_xyz_orientation,2);

[broken_check, ~] = ismember([1 2 3], full_brain_xyz_orientation_1);

if ~all(broken_check)
    error('brain_xyz_orientation wrong')
end
%%%% end of sanity check

%%%% setting


nmz_in_tif_list = natsortfiles(dir([images_out_folder '/*.tif']));
nmz_out_tif_list = natsortfiles(dir([images_out_folder '/*.tif']));

pixel_yes_id = 3;


%%% End of Setting

shrinked_yes_pix_count ={};

parfor jj = 1:length(nmz_in_tif_list)
    
    
    img_out_temp = imread(strcat(nmz_out_tif_list(jj).folder, '/', nmz_out_tif_list(jj).name));
    logic_yes = (img_out_temp == pixel_yes_id);
    
    [s_xxx, s_yyy] = ind2sub(size(logic_yes), find(logic_yes)); 
    s_xxx = ceil(s_xxx.*xyz_resolution(1)./targeting_resolution);
    s_yyy = ceil(s_yyy.*xyz_resolution(2)./targeting_resolution);

    ImageSize = ceil(size(logic_yes) .* xyz_resolution(1:2) ./ targeting_resolution);
    shrinked_yes_pix_count{jj} = accumarray([s_xxx,s_yyy], 1, ImageSize);

    
    
end

fprintf('Counting done \n');

disp( datestr(datetime('now')))

making_area_counted_output(brain_xyz_orientation,nmz_in_tif_list, xyz_resolution, targeting_resolution, shrinked_yes_pix_count, targeting_folder, out_file_name);


% save('testing_asdasd.mat');






































