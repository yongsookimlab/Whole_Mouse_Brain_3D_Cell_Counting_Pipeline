function [] = normalizing_single_shrink_file(images_in_folder, normalized_images_in_folder, shrinked_file, normalizing_intensity_target)

mkdir(normalized_images_in_folder)

tiff_info = imfinfo(shrinked_file); 
tiff_stack = imread(shrinked_file, 1); 

for ii = 2 : size(tiff_info, 1)
    temp_tiff = imread(shrinked_file, ii);
    tiff_stack = cat(3 , tiff_stack, temp_tiff);
end

shrinked_mean = otsu_mean(tiff_stack(:));

nmz_in_tif_list = natsortfiles(dir([images_in_folder '/*.tif']));



parfor jj = 1:length(nmz_in_tif_list)
    
    img_in_temp = single(imread(strcat(nmz_in_tif_list(jj).folder, '/', nmz_in_tif_list(jj).name))) ./ shrinked_mean .* normalizing_intensity_target;
    imwrite(uint16(img_in_temp), [ normalized_images_in_folder, '/', nmz_in_tif_list(jj).name ]);
    
end


