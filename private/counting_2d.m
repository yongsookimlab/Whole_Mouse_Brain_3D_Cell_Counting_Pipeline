function [] = counting_2d(images_out_folder,targeting_folder, xyz_resolution, targeting_resolution, brain_xyz_orientation);


%%%% sanity check
full_brain_xyz_orientation_1 = ceil(brain_xyz_orientation./2);
[broken_check, full_brain_xyz_orientation_1] = ismember([1 2 3], full_brain_xyz_orientation_1);

if ~all(broken_check)
    error('brain_xyz_orientation wrong')
end
%%%% end of sanity check

%%%% setting

expected_nuc_size_range = [10 400]; %pixels
nmz_tif_list = natsortfiles(dir([images_out_folder '/*.tif']));

%%% End of Setting

centroid_cord ={};

% disp( datestr(datetime('now')))

% lineLength = fprintf('Counting: %2.1f percent',0);


parfor jj = 1:length(nmz_tif_list)
    
    %     tic
    
    
    img_temp = imread(strcat(nmz_tif_list(jj).folder, '/', nmz_tif_list(jj).name));
    
    
    
    conncomp = bwconncomp(img_temp == 3, 8);
    conncomp.length = zeros(length(conncomp.PixelIdxList),1);
    
    for ii = 1:length(conncomp.PixelIdxList)
        conncomp.length(ii) = length(conncomp.PixelIdxList{ii});
    end
    conncomp.PixelIdxList = conncomp.PixelIdxList(conncomp.length>expected_nuc_size_range(1) &  conncomp.length<expected_nuc_size_range(2));
    
    
    conncomp.centroid_x = zeros(length(conncomp.PixelIdxList),1);
    conncomp.centroid_y = zeros(length(conncomp.PixelIdxList),1);
    conncomp.centroid_z = zeros(length(conncomp.PixelIdxList),1);
    kk = 0;
    for ii = 1:length(conncomp.PixelIdxList)
        [xxx,yyy] = ind2sub(conncomp.ImageSize,conncomp.PixelIdxList{ii});
        kk = kk+1;
        conncomp.centroid_x(kk) = mean(xxx);
        conncomp.centroid_y(kk) = mean(yyy);
        conncomp.centroid_z(kk) = jj;
    end
    
    centroid_cord{jj}= [conncomp.centroid_x, conncomp.centroid_y, conncomp.centroid_z];
    
    %     time_laped = toc;
    
    %     fprintf(repmat('\b',1,lineLength));
    %     lineLength = fprintf('Counting: %2.1f percent, batch time : %0.2f seconds',[jj./length(nmz_tif_list).*100, time_laped]);
    
end
% fprintf(repmat('\b',1,lineLength));

fprintf('Counting done \n');

disp( datestr(datetime('now')))


img_temp = imread(strcat(nmz_tif_list(1).folder, '/', nmz_tif_list(1).name));

centroid_cord_all = [];
for jj = 1:length(nmz_tif_list)
    if ~isempty(centroid_cord{jj})
        centroid_cord_all = cat(1, centroid_cord_all, centroid_cord{jj} );
    end
end


ImageSize = ceil([size(img_temp), length(nmz_tif_list)] .* xyz_resolution ./ targeting_resolution);

size_temp_loaded_img = size(img_temp);

shrink_x = ((double(centroid_cord_all(:,1))-0.5)./size_temp_loaded_img(1).*ImageSize(1)+0.5);
shrink_y = ((double(centroid_cord_all(:,2))-0.5)./size_temp_loaded_img(2).*ImageSize(2)+0.5);
shrink_z = ((double(centroid_cord_all(:,3))-0.5)./length(nmz_tif_list).*ImageSize(3)+0.5);

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


counted_img_shrink = accumarray(round(centroid_cord_all_shrink), 1, ImageSize);


counted_img_shrink = permute(counted_img_shrink,[2 1 3]);
niftiwrite(counted_img_shrink,[targeting_folder, '/counted_3d.nii']);

counted_img_shrink = imgaussfilt3(counted_img_shrink,3);
niftiwrite(counted_img_shrink,[targeting_folder, '/counted_3d_visual.nii']);



centroid_cord_all_shrink = [centroid_cord_all_shrink(:,2),centroid_cord_all_shrink(:,1),centroid_cord_all_shrink(:,3)];

save([targeting_folder, '/counted_3d_cordinates.mat'], 'centroid_cord_all_shrink');



