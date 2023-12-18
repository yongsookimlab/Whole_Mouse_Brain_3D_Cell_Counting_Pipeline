function [] = post_processing2_v2(folder_name, counted_mat_file, rev_elastix_working_folder)

% counted_mat_file = [folder_name, '/counted_3d_cordinates.mat'];


elastix_working_folder = [folder_name, '/elastix_working'];
file_trans_para_1 = [elastix_working_folder, '/TransformParameters.1.txt'];

% rev_elastix_working_folder = [folder_name, '/rev_elastix_working'];
temp_folder = [pwd, '/temp_folder_1'];

mkdir(rev_elastix_working_folder);
mkdir(temp_folder);


cell_locations = load(counted_mat_file);
cell_locations = cell_locations.centroid_cord_all_shrink;

making_text_file_for_elastix(cell_locations,temp_folder);

file_index = [temp_folder, '/indeices_for_elastix.txt'];


transformix_index_v2(file_index, temp_folder, elastix_working_folder);

heatmap_using_index_file(temp_folder);

movefile([temp_folder, '/*'],rev_elastix_working_folder)
