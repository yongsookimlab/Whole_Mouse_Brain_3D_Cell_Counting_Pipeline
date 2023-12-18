function [] = normalizing__shrink_folder(images_in_folder, normalized_images_in_folder, shrinked_folder, normalizing_intensity_signal)

shrink_tif_list = natsortfiles(dir([shrinked_folder '/*.tif']));


parfor jj = 1:length(shrink_tif_list)
    
    img_shrink_temp{1,1,jj} = imread(strcat(shrink_tif_list(jj).folder, '/', shrink_tif_list(jj).name)) ;

end

img_shrink_temp = cell2mat(img_shrink_temp);

shrinked_mean = otsu_mean(img_shrink_temp(:));

nmz_in_tif_list = natsortfiles(dir([images_in_folder '/*.tif']));



parfor jj = 1:length(nmz_in_tif_list)
    
    img_in_temp = single(imread(strcat(nmz_in_tif_list(jj).folder, '/', nmz_in_tif_list(jj).name))) ./ shrinked_mean .* normalizing_intensity_signal;
    imwrite(uint16(img_in_temp), [ normalized_images_in_folder, '/', nmz_in_tif_list(jj).name ]);
    
end


