function [] = conting_v_func(targeting_folder_str, fram_skipping ,out_folder)

% targeting_folder_str = ans
targeting_folder = targeting_folder_str.folder_list;

quality_check_counting_setting_pack;


loaded_crap = load([targeting_folder, '/counted_3d_cordinates.mat']);

centroid_cord_all_shrink = [loaded_crap.centroid_cord_all_shrink(:,2),loaded_crap.centroid_cord_all_shrink(:,1),loaded_crap.centroid_cord_all_shrink(:,3)];

nmz_in_tif_list = natsortfiles(dir([images_in_ch_folder '/*.tif']));
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


shrink_x = round((centroid_cord_all_shrink(:,1)).*size_temp_loaded_img(1)./ImageSize(1)+0.5);
shrink_y = round((centroid_cord_all_shrink(:,2)).*size_temp_loaded_img(2)./ImageSize(2)+0.5);
shrink_z = round((centroid_cord_all_shrink(:,3)).*length(nmz_in_tif_list)./ImageSize(3)+0.5);

[circle_mask] = double(making_a_circle(radii_draw));



frame_inspecting = fram_skipping:fram_skipping:length(nmz_in_tif_list);


for jj = frame_inspecting
    
    img_in_temp = imread(strcat(nmz_in_tif_list(jj).folder, '/', nmz_in_tif_list(jj).name));
    
    for kk = jj-stack_thickness : jj+stack_thickness-1
        img_in_temp = max(cat(3,img_in_temp,imread(strcat(nmz_in_tif_list(kk).folder, '/', nmz_in_tif_list(kk).name))),[],3);
    end
    
%     ImageSize = ceil([size(img_in_temp), length(nmz_in_tif_list)] .* xyz_resolution ./ targeting_resolution);
    
%     size_temp_loaded_img = size(img_in_temp);
    
    %         figure('units','normalized','outerposition',[0 0 2 2]);
    %         imshow(img_in_temp, [0 2000]);hold;
    img_in_temp = double(img_in_temp)./drawing_range;
    img_in_temp(img_in_temp>drawing_range) = drawing_range;
    img_in_temp(img_in_temp<0) = 0;
    
    img_in_temp = cat(3,img_in_temp,img_in_temp,img_in_temp);
    
    flagg = (shrink_z > jj-stack_thickness-0.5) & ...
        ( shrink_z < jj+stack_thickness+0.5) &...
        (shrink_x >radii_draw) &...
        (shrink_y >radii_draw) &...
        (shrink_x < size(img_in_temp,1)-radii_draw) &...
        (shrink_y < size(img_in_temp,2)-radii_draw);
    
    for kk = find(flagg)'
        img_in_temp(shrink_x(kk)-radii_draw:shrink_x(kk)+radii_draw, shrink_y(kk)-radii_draw:shrink_y(kk)+radii_draw, 1) = img_in_temp(shrink_x(kk)-radii_draw:shrink_x(kk)+radii_draw, shrink_y(kk)-radii_draw:shrink_y(kk)+radii_draw, 1) + circle_mask;
        img_in_temp(shrink_x(kk)-radii_draw:shrink_x(kk)+radii_draw, shrink_y(kk)-radii_draw:shrink_y(kk)+radii_draw, 2) = img_in_temp(shrink_x(kk)-radii_draw:shrink_x(kk)+radii_draw, shrink_y(kk)-radii_draw:shrink_y(kk)+radii_draw, 2) - circle_mask;
        img_in_temp(shrink_x(kk)-radii_draw:shrink_x(kk)+radii_draw, shrink_y(kk)-radii_draw:shrink_y(kk)+radii_draw, 3) = img_in_temp(shrink_x(kk)-radii_draw:shrink_x(kk)+radii_draw, shrink_y(kk)-radii_draw:shrink_y(kk)+radii_draw, 3) - circle_mask;
    end
    img_in_temp(img_in_temp>1.0) = 1.0;
    img_in_temp(img_in_temp<0.0) = 0.0;
    
    imwrite(img_in_temp,[out_folder, '/', targeting_folder_str.internal_name, '_', num2str(jj),'.png']);
    
    %     flagg = (shrink_z > jj-stack_thickness-0.5) &( shrink_z < jj+stack_thickness+0.5);
    
    %     scatter(shrink_y(flagg),shrink_x(flagg),60,'r');
    %     print('BarPlot','-dpng')
    
end
