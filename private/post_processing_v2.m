function [] = post_processing_v2(folder_name,targeting_resolution, counted_mat_file, out_csv_file)

% counted_mat_file = [folder_name, '/counted_3d_cordinates.mat'];
% out_csv_file = [folder_name, '/counted_3d_cells.csv'];
csv_name = '16bit_allen_csv_20200916.csv';

elastix_working_folder = [folder_name, '/elastix_working'];
file_trans_para_1 = [elastix_working_folder, '/TransformParameters.1.txt'];
anno_traformed = [elastix_working_folder, '/result.mhd'];




cell_locations = load(counted_mat_file);
cell_locations = cell_locations.centroid_cord_all_shrink;
% cell_locations = [cell_locations(:,2),cell_locations(:,1),cell_locations(:,3)];  %%%%


[anno,~] = read_mhd(anno_traformed);
anno = anno.data;

making_csv(cell_locations, csv_name, anno ,out_csv_file, targeting_resolution)