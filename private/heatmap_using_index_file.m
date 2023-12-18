function [] = heatmap_using_index_file(rev_elastix_working_folder,allen_anno)

% allen_anno = strcat(pwd, '/allen_10_anno_16bit_pa.tif'); 
tiff_info = imfinfo(allen_anno);

heat_map_file_temp = [pwd, '/cell_counted_ref_space.tif']; 
output_index_file = [rev_elastix_working_folder, '/outputpoints.txt']; 

A = readmatrix(output_index_file,'Delimiter',' ');
trans_location = round(A(:,26:28));

% A = readmatrix(output_index_file);
% trans_location = round(A(:,31:33));




trans_location(:,[1 2]) = trans_location(:,[2 1]);

logi = (trans_location(:,1)>=1) & (trans_location(:,2)>=1) & (trans_location(:,3)>=1) &(trans_location(:,1))<=tiff_info(1).Height &(trans_location(:,2))<=tiff_info(1).Width &(trans_location(:,3))<=length(tiff_info)  ;

trans_location = trans_location(logi,:);

trans_location = accumarray(trans_location,1, [tiff_info(1).Height,tiff_info(1).Width, length(tiff_info)]);


tif_write_stack(uint16(trans_location),heat_map_file_temp);

movefile(heat_map_file_temp,rev_elastix_working_folder)


