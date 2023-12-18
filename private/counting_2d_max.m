function [] = counting_2d_max(images_in_folder, images_out_folder,targeting_folder, xyz_resolution, targeting_resolution, brain_xyz_orientation)


%%%% sanity check
full_brain_xyz_orientation_1 = ceil(brain_xyz_orientation./2);
[broken_check, full_brain_xyz_orientation_1] = ismember([1 2 3], full_brain_xyz_orientation_1);

if ~all(broken_check)
    error('brain_xyz_orientation wrong')
end
%%%% end of sanity check

%%%% setting

threshhold = 50;
cell_size_r = 8;


nmz_in_tif_list = natsortfiles(dir([images_in_folder '/*.tif']));
nmz_out_tif_list = natsortfiles(dir([images_out_folder '/*.tif']));

%%% End of Setting

centroid_cord ={};




parfor jj = 1:length(nmz_in_tif_list)
    
    
    
    img_in_temp = imread(strcat(nmz_in_tif_list(jj).folder, '/', nmz_in_tif_list(jj).name));
    img_out_temp = imread(strcat(nmz_out_tif_list(jj).folder, '/', nmz_out_tif_list(jj).name));
    
    img_in_temp = imgaussfilt(img_in_temp,2);
    [xxx,yyy]=local_maximum_finder(img_in_temp, threshhold, cell_size_r);
    

    
    indd = sub2ind(size(img_in_temp),xxx,yyy);
    flagg = (img_out_temp(indd) == 3); % set trained classifier value for counting
    
    xxx = xxx(flagg);
    yyy = yyy(flagg);
    
    zzz = xxx;
    zzz(:) = jj;
    
    centroid_cord{jj}= [xxx, yyy, zzz];
    
end

fprintf('Counting done \n');

disp( datestr(datetime('now')))


img_temp = imread(strcat(nmz_in_tif_list(1).folder, '/', nmz_in_tif_list(1).name));

centroid_cord_all = [];
for jj = 1:length(nmz_in_tif_list)
    if ~isempty(centroid_cord{jj})
        centroid_cord_all = cat(1, centroid_cord_all, centroid_cord{jj} );
    end
end


ImageSize = ceil([size(img_temp), length(nmz_in_tif_list)] .* xyz_resolution ./ targeting_resolution);

size_temp_loaded_img = size(img_temp);

shrink_x = ((double(centroid_cord_all(:,1))-0.5)./size_temp_loaded_img(1).*ImageSize(1));
shrink_y = ((double(centroid_cord_all(:,2))-0.5)./size_temp_loaded_img(2).*ImageSize(2));
shrink_z = ((double(centroid_cord_all(:,3))-0.5)./length(nmz_in_tif_list).*ImageSize(3));

centroid_cord_all_shrink = [shrink_x, shrink_y, shrink_z];



full_brain_xyz_orientation_2 = mod(brain_xyz_orientation,2);

for ii = 1:3
    if full_brain_xyz_orientation_2(ii) == 0
        centroid_cord_all_shrink(:,ii) =  ImageSize(ii) - centroid_cord_all_shrink(:,ii) ;
    end
end


if ~isequal(full_brain_xyz_orientation_1,[1 2 3])
    centroid_cord_all_shrink(:,:) = centroid_cord_all_shrink(:,full_brain_xyz_orientation_1);
end



ImageSize = ImageSize(full_brain_xyz_orientation_1);


xyxx = round(centroid_cord_all_shrink);

xyxx(xyxx(:)<= 1) = 1;
temppp = xyxx(:,1);
temppp(temppp>=ImageSize(1)) = ImageSize(1);
xyxx(:,1) = temppp;
temppp = xyxx(:,2);
temppp(temppp>=ImageSize(2)) = ImageSize(2);
xyxx(:,2) = temppp;
temppp = xyxx(:,3);
temppp(temppp>=ImageSize(3)) = ImageSize(3);
xyxx(:,3) = temppp;


counted_img_shrink = accumarray(xyxx, 1, ImageSize);


counted_img_shrink = permute(counted_img_shrink,[2 1 3]);
niftiwrite(counted_img_shrink,[targeting_folder, '/counted_3d.nii']);

counted_img_shrink = imgaussfilt3(counted_img_shrink,3);
niftiwrite(counted_img_shrink,[targeting_folder, '/counted_3d_visual.nii']);



centroid_cord_all_shrink = [centroid_cord_all_shrink(:,2),centroid_cord_all_shrink(:,1),centroid_cord_all_shrink(:,3)];

save([targeting_folder, '/counted_3d_cordinates.mat'], 'centroid_cord_all_shrink');



