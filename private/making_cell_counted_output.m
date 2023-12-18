function [] = making_cell_counted_output(brain_xyz_orientation,nmz_in_tif_list, xyz_resolution, targeting_resolution, centroid_cord_pericyte,targeting_folder, out_file_name)

full_brain_xyz_orientation_1 = ceil(brain_xyz_orientation./2);
[~, full_brain_xyz_orientation_1] = ismember([1 2 3], full_brain_xyz_orientation_1);
full_brain_xyz_orientation_2 = mod(brain_xyz_orientation,2);

img_temp = imread(strcat(nmz_in_tif_list(1).folder, '/', nmz_in_tif_list(1).name));
ImageSize = ceil([size(img_temp), length(nmz_in_tif_list)] .* xyz_resolution ./ targeting_resolution);
size_temp_loaded_img = size(img_temp);
ImageSize_t = ImageSize(full_brain_xyz_orientation_1);

centroid_cord_all_pericyte = [];
for jj = 1:length(nmz_in_tif_list)
    if ~isempty(centroid_cord_pericyte{jj})
        centroid_cord_all_pericyte = cat(1, centroid_cord_all_pericyte, centroid_cord_pericyte{jj} );
    end
end

shrink_x_pericyte = ((double(centroid_cord_all_pericyte(:,1))-0.5)./size_temp_loaded_img(1).*ImageSize(1));
shrink_y_pericyte = ((double(centroid_cord_all_pericyte(:,2))-0.5)./size_temp_loaded_img(2).*ImageSize(2));
shrink_z_pericyte = ((double(centroid_cord_all_pericyte(:,3))-0.5)./length(nmz_in_tif_list).*ImageSize(3));

centroid_cord_all_shrink_pericyte = [shrink_x_pericyte, shrink_y_pericyte, shrink_z_pericyte];

for ii = 1:3
    if full_brain_xyz_orientation_2(ii) == 0
        centroid_cord_all_shrink_pericyte(:,ii) =  ImageSize(ii) - centroid_cord_all_shrink_pericyte(:,ii) ;
    end
end

if ~isequal(full_brain_xyz_orientation_1,[1 2 3])
    centroid_cord_all_shrink_pericyte(:,:) = centroid_cord_all_shrink_pericyte(:,full_brain_xyz_orientation_1);
end


counted_img_shrink_pericyte = accumarray(ceil(centroid_cord_all_shrink_pericyte), 1, ImageSize_t);

counted_img_shrink_pericyte = permute(counted_img_shrink_pericyte,[2 1 3]);
niftiwrite(counted_img_shrink_pericyte,[targeting_folder, '/', out_file_name, '.nii']);

counted_img_shrink_pericyte = imgaussfilt3(counted_img_shrink_pericyte,3);
niftiwrite(counted_img_shrink_pericyte,[targeting_folder, '/', out_file_name, '_visual.nii']);



centroid_cord_all_shrink = [centroid_cord_all_shrink_pericyte(:,2),centroid_cord_all_shrink_pericyte(:,1),centroid_cord_all_shrink_pericyte(:,3)];

save([targeting_folder, '/', out_file_name, '_cordinates.mat'], 'centroid_cord_all_shrink');

