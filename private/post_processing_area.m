function [] = post_processing_area(folder_name,targeting_resolution, nii_file_name, out_csv_file, csv_name)

% counted_mat_file = [folder_name, '/counted_3d_cordinates.mat'];
% out_csv_file = [folder_name, '/counted_3d_cells.csv'];
% csv_name = '16bit_allen_csv_20200916.csv';

elastix_working_folder = [folder_name, '/elastix_working'];
% file_trans_para_1 = [elastix_working_folder, '/TransformParameters.1.txt'];
anno_traformed = [elastix_working_folder, '/result.mhd'];


loaded_nii = niftiread(nii_file_name);

% cell_locations = [cell_locations(:,2),cell_locations(:,1),cell_locations(:,3)];  %%%%


[anno,~] = read_mhd(anno_traformed);
anno = anno.data;

if all(size(loaded_nii) ~= size(anno))
    error(['size mismatch', num2str(size(loaded_nii)), num2str(size(anno))]);
end


making_csv_area(loaded_nii, csv_name, anno ,out_csv_file, targeting_resolution)