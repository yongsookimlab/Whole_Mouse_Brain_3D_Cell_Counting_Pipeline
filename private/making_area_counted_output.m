function [] = making_area_counted_output(brain_xyz_orientation,nmz_in_tif_list, xyz_resolution, targeting_resolution, shrinked_smc_pix_count, targeting_folder, out_file_name)

full_brain_xyz_orientation_1 = ceil(brain_xyz_orientation./2);
[~, full_brain_xyz_orientation_1] = ismember([1 2 3], full_brain_xyz_orientation_1);
full_brain_xyz_orientation_2 = mod(brain_xyz_orientation,2);

img_temp = imread(strcat(nmz_in_tif_list(1).folder, '/', nmz_in_tif_list(1).name));
ImageSize = ceil([size(img_temp), length(nmz_in_tif_list)] .* xyz_resolution ./ targeting_resolution);

ImageSize_t = ImageSize(full_brain_xyz_orientation_1);








centroid_cord_all_area = [];
for jj = 1:length(nmz_in_tif_list)

    s_flagg = find(shrinked_smc_pix_count{jj});
    
    [s_xxx, s_yyy] = ind2sub(size(shrinked_smc_pix_count{jj}), s_flagg);
    s_zzz = s_xxx;
    s_zzz(:) = jj;
    s_count = shrinked_smc_pix_count{jj}(s_flagg);
    centroid_cord_all_area = cat(1, centroid_cord_all_area, [s_xxx, s_yyy, s_zzz, s_count] );

end


centroid_cord_all_area(:,3) = (double(centroid_cord_all_area(:,3))./length(nmz_in_tif_list).*ImageSize(3));

centroid_cord_all_shrink = centroid_cord_all_area(:,1:3);

for ii = 1:3
    if full_brain_xyz_orientation_2(ii) == 0
        centroid_cord_all_shrink(:,ii) =  ImageSize(ii) - centroid_cord_all_shrink(:,ii) ;
    end
end

if ~isequal(full_brain_xyz_orientation_1,[1 2 3])
    centroid_cord_all_shrink(:,:) = centroid_cord_all_shrink(:,full_brain_xyz_orientation_1);
end


centroid_cord_all_shrink(centroid_cord_all_shrink<=0) = 1;

counted_img_shrink_pix = accumarray(ceil(centroid_cord_all_shrink), centroid_cord_all_area(:,4), ImageSize_t);

counted_img_shrink_pix = permute(counted_img_shrink_pix,[2 1 3]);
niftiwrite(counted_img_shrink_pix,out_file_name);

