function [] = make_shrink_file(folder_name, registering_ch, brain_xyz_orientation, xy_resolution, z_resolution, targeting_resolution)

elastix_working_folder = [folder_name, '/elastix_working'];

resized_chx_file = string([elastix_working_folder, '/resized_chx.tif']);
rotated_chx_file = string([elastix_working_folder, '/rotated_chx.tif']);

mkdir(elastix_working_folder)

% registering_ch = [folder_name, '/', registering_ch];
reg_tif_list = natsortfiles(dir([registering_ch '/*.tif']));

im_in = imread(strcat(reg_tif_list(floor(length(reg_tif_list)./2)).folder, '/', reg_tif_list(floor(length(reg_tif_list)./2)).name));
[im_in_mean] = otsu_mean(im_in);

ImageSize = ceil([size(im_in), length(reg_tif_list)] .* [ xy_resolution, xy_resolution, z_resolution] ./ targeting_resolution);


zz_index = [1:1:ImageSize(3)];
zz_index = floor(zz_index .* targeting_resolution ./ z_resolution);

zz_index(zz_index>length(reg_tif_list)) = length(reg_tif_list);
zz_index(zz_index<1) = 1;


shrinked_img = zeros(ImageSize);

parfor zz = 1:1:length(zz_index)
    file_name = strcat(reg_tif_list(zz_index(zz)).folder, '/', reg_tif_list(zz_index(zz)).name);
    shrinked_img(:,:,zz) = imresize(imread(file_name),[ImageSize(1), ImageSize(2)]);
end
readjust_ratio = 99;
readjust_bar = single(prctile(shrinked_img(:),readjust_ratio)).*1.25;
shrinked_img = uint16(single(shrinked_img)./readjust_bar.*65535);

% tif_write_stack(shrinked_img,resized_chx_file);



full_brain_xyz_orientation_1 = ceil(brain_xyz_orientation./2);
[broken_check, full_brain_xyz_orientation_1] = ismember([1 2 3], full_brain_xyz_orientation_1);

if ~all(broken_check)
    error('brain_xyz_orientation wrong')
end

full_brain_xyz_orientation_2 = mod(brain_xyz_orientation,2);

for ii = 1:3
    if full_brain_xyz_orientation_2(ii) == 0
        shrinked_img = flip(shrinked_img, ii);
    end
end

if ~isequal(full_brain_xyz_orientation_1,[1 2 3])
    shrinked_img = permute(shrinked_img,full_brain_xyz_orientation_1);
end


tif_write_stack(shrinked_img,rotated_chx_file);
