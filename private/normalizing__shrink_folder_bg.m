function [] = normalizing__shrink_folder_bg(background_ch_folder, normalized_bg_images_folder, shrinked_bg_folder, normalizing_intensity_background)

shrink_tif_list = natsortfiles(dir([shrinked_bg_folder '/*.tif']));


parfor jj = 1:length(shrink_tif_list)
    
    img_shrink_temp{1,1,jj} = imread(strcat(shrink_tif_list(jj).folder, '/', shrink_tif_list(jj).name)) ;

end

img_shrink_temp = cell2mat(img_shrink_temp);

shrinked_mean = otsu_mean(img_shrink_temp(:));

nmz_in_tif_list = natsortfiles(dir([background_ch_folder '/*.tif']));



parfor jj = 1:length(nmz_in_tif_list)
    
    img_in_temp = single(imread(strcat(nmz_in_tif_list(jj).folder, '/', nmz_in_tif_list(jj).name))) ./ shrinked_mean .* normalizing_intensity_background;
    imwrite(uint16(img_in_temp), [ normalized_bg_images_folder, '/', nmz_in_tif_list(jj).name ]);
    
end


