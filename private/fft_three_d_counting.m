function [] = fft_three_d_counting(folder_name, nor_folder, num_cpu, brain_xyz_orientation, xy_resolution, z_resolution, targeting_resolution,expected_nuc_size,intensity_thresh)

% folder_name = 'Z:\LSFM\2021\2021_08\20210804_SM_ToddB1_Crfr2Cre_488Bg_561RFP_642SynapsinGFP_4x_5umstep_AAVSynapsinLS_FLPMPA';

% normalizing_folder = 'stitched_01';

% num_cpu = 32; %16GB memory per core (half of total core count in 12c 40c 64c)
R = 40; % Frequency for background removal, 0.5x expected_nuc_size in pixel

chunck_size = num_cpu.*2; % Larger take more memory, slightly faster, less than 10 make no sense
final_size_thresh = 3.0;
% xy_resolution = 1.87;
% z_resolution = 5;

% target_resolution = 10;


% expected_nuc_size = 10; %um
% intensity_thresh = 0.6;

%%% End of Setting

% Setting_up_parameters


expected_nuc_size_xy_p = expected_nuc_size./xy_resolution;
expected_nuc_size_z_p = expected_nuc_size./z_resolution;
pix_min = expected_nuc_size_xy_p.*expected_nuc_size_xy_p.*expected_nuc_size_z_p.*0.5;


% nor_folder = [folder_name, '/', normalizing_folder];
nmz_tif_list = natsortfiles(dir([nor_folder '/*.tif']));



% local_window_size_xy = ceil(expected_nuc_size_xy_p.*2.0);
local_window_size_z = ceil(expected_nuc_size_z_p.*1.0);


size_temp_loaded_img = imread(strcat(nmz_tif_list(1).folder, '/', nmz_tif_list(1).name));
size_temp_loaded_img = size(size_temp_loaded_img);

%chunck_size = floor((length(nmz_tif_list)-(local_window_size_z.*2))./para_count);
ii_list = local_window_size_z +1 :chunck_size: length(nmz_tif_list)-local_window_size_z;
para_count = length(ii_list);

im_in = imread(strcat(nmz_tif_list(floor(length(nmz_tif_list)./2)).folder, '/', nmz_tif_list(floor(length(nmz_tif_list)./2)).name));
[im_in_mean] = otsu_mean(im_in)
centroid_cord ={};

disp( datestr(datetime('now')))

lineLength = fprintf('Counting: %2.1f percent',0);

% parfor (jj = 1:para_count, num_cpu)
for jj = 1:para_count
    
    tic

    
    if jj == para_count
        end_z = length(nmz_tif_list);
    else
        end_z = ii_list(jj)+chunck_size+local_window_size_z-1;
    end
    iilist_2 = ii_list(jj)-local_window_size_z:end_z;
    temp_stack = zeros([size_temp_loaded_img, length(iilist_2)]);
    
    
    
    parfor ii = 1:length(iilist_2)
        img_temp = single(imread(strcat(nmz_tif_list(iilist_2(ii)).folder, '/', nmz_tif_list(iilist_2(ii)).name)));
        img_temp(img_temp<im_in_mean) = im_in_mean;
        temp_stack(:,:,ii) = low_pass_substration_devision_mod(img_temp, R);
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    
    %     parfor ii = 1:length(iilist_2)
    %         temp_stack(:,:,ii) = imread(strcat(nmz_tif_list(iilist_2(ii)).folder, '/', nmz_tif_list(iilist_2(ii)).name));
    %     end
    %     temp_stack(temp_stack<im_in_mean) = im_in_mean;
    %
    %
    %     %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     parfor ii = 1:size(temp_stack,3)
    %         temp_stack(:,:,ii) = low_pass_substration_devision_mod(temp_stack(:,:,ii), R);
    %     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %         temp_stack = temp_stack./im_in_mean;
    %
    %     for ii = 1:size(temp_stack,3)
    %         temp_stack(:,:,ii) = low_pass_substration(temp_stack(:,:,ii), R);
    %     end
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    potential_list = (temp_stack>intensity_thresh);
    
    
    conncomp = bwconncomp(potential_list, 6);
    conncomp.length = zeros(length(conncomp.PixelIdxList),1);
    for ii = 1:length(conncomp.PixelIdxList)
        conncomp.length(ii) = length(conncomp.PixelIdxList{ii});
    end
    conncomp.PixelIdxList = conncomp.PixelIdxList(conncomp.length>pix_min );
    
    %         testing_plot
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% sepration
    for ii = 1:length(conncomp.PixelIdxList)
        
        max_pix = max(temp_stack(conncomp.PixelIdxList{ii}));
        conncomp.PixelIdxList{ii} = conncomp.PixelIdxList{ii}(temp_stack(conncomp.PixelIdxList{ii}) > max_pix.*0.25);
        
        [xxx,yyy,zzz] = ind2sub(conncomp.ImageSize,conncomp.PixelIdxList{ii});
        xxx = xxx-min(xxx)+1;
        yyy = yyy-min(yyy)+1;
        zzz = zzz-min(zzz)+1;
        
        bw = false(max(xxx),max(yyy),max(zzz));
        bw(sub2ind(size(bw),xxx,yyy,zzz))=1;
        
        D = zeros(max(xxx),max(yyy),max(zzz));
        D(sub2ind(size(bw),xxx,yyy,zzz))= -temp_stack(conncomp.PixelIdxList{ii});
        
        L = watershed(D);
        L(~bw) = 0;
        L_index = find(bw);
        L = L(L_index);
        temp_pix_id = {};
        for kk = 1:max(L(:))
            temp_pix_id{kk} = conncomp.PixelIdxList{ii}(L==kk);
        end
        conncomp.PixelIdxList(ii) = [];
        conncomp.PixelIdxList = [conncomp.PixelIdxList, temp_pix_id];
    end
    
    %             testing_plot
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% end of sepration
    conncomp.length = zeros(length(conncomp.PixelIdxList),1);
    for ii = 1:length(conncomp.PixelIdxList)
        conncomp.length(ii) = length(conncomp.PixelIdxList{ii});
    end
    conncomp.PixelIdxList = conncomp.PixelIdxList(conncomp.length>pix_min );
    
    
    %             testing_plot
    
    conncomp.centroid_x = zeros(length(conncomp.PixelIdxList),1);
    conncomp.centroid_y = zeros(length(conncomp.PixelIdxList),1);
    conncomp.centroid_z = zeros(length(conncomp.PixelIdxList),1);
    kk = 0;
    for ii = 1:length(conncomp.PixelIdxList)
        [xxx,yyy,zzz] = ind2sub(conncomp.ImageSize,conncomp.PixelIdxList{ii});
        if (max(xxx)-min(xxx))<expected_nuc_size.*final_size_thresh && (max(yyy)-min(yyy))<expected_nuc_size.*final_size_thresh && (max(zzz)-min(zzz))<expected_nuc_size.*final_size_thresh
            kk = kk+1;
            conncomp.centroid_x(kk) = mean(xxx);
            conncomp.centroid_y(kk) = mean(yyy);
            conncomp.centroid_z(kk) = mean(zzz);
        end
    end
    
    %     figure;imshow(max(temp_stack,[],3), [0 2]);hold;
    %     scatter(conncomp.centroid_y,conncomp.centroid_x,60,'r');
    
    centroid_cord{jj}= [conncomp.centroid_x, conncomp.centroid_y, conncomp.centroid_z];
    
    time_laped = toc;
    
    fprintf(repmat('\b',1,lineLength));
    lineLength = fprintf('Counting: %2.1f percent, batch time : %0.2f seconds',[jj./para_count.*100, time_laped]);    
    
end
    fprintf(repmat('\b',1,lineLength));

fprintf('Counting done \n');

disp( datestr(datetime('now')))



centroid_cord_all = [];
for jj = 1:para_count
    if ~isempty(centroid_cord{jj})
        flag = (centroid_cord{jj}(:,3)>local_window_size_z) & (centroid_cord{jj}(:,3)<= (chunck_size + local_window_size_z));
        centroid_cord{jj} = round(centroid_cord{jj}(flag,:));
        flag = ...
            centroid_cord{jj}(:,1) >= 1 & ...
            centroid_cord{jj}(:,1) <= size_temp_loaded_img(1) & ...
            centroid_cord{jj}(:,2) >= 1 & ...
            centroid_cord{jj}(:,2) <= size_temp_loaded_img(2);
        centroid_cord{jj} = centroid_cord{jj}(flag,:);
        centroid_cord_all = cat(1, centroid_cord_all, centroid_cord{jj} + [0 0 (ii_list(jj)-local_window_size_z)].*ones(size(centroid_cord{jj},1),1));
    end
end


ImageSize = ceil([size(im_in), length(nmz_tif_list)] .* [ xy_resolution, xy_resolution, z_resolution] ./ targeting_resolution);


shrink_x = ((double(centroid_cord_all(:,1))-0.5)./size_temp_loaded_img(1).*ImageSize(1)+0.5);
shrink_y = ((double(centroid_cord_all(:,2))-0.5)./size_temp_loaded_img(2).*ImageSize(2)+0.5);
shrink_z = ((double(centroid_cord_all(:,3))-0.5)./length(nmz_tif_list).*ImageSize(3)+0.5);

centroid_cord_all_shrink = [shrink_x, shrink_y, shrink_z];





full_brain_xyz_orientation_1 = ceil(brain_xyz_orientation./2);
[broken_check, full_brain_xyz_orientation_1] = ismember([1 2 3], full_brain_xyz_orientation_1);

if ~all(broken_check)
    error('brain_xyz_orientation wrong')
end


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
niftiwrite(counted_img_shrink,[folder_name, '/counted_3d.nii']);

counted_img_shrink = imgaussfilt3(counted_img_shrink,3);
niftiwrite(counted_img_shrink,[folder_name, '/counted_3d_visual.nii']);



centroid_cord_all_shrink = [centroid_cord_all_shrink(:,2),centroid_cord_all_shrink(:,1),centroid_cord_all_shrink(:,3)];

save([folder_name, '/counted_3d_cordinates.mat'], 'centroid_cord_all_shrink');



