function [] = post_processing2_area(folder_name, loaded_nii, rev_elastix_working_folder,allen_anno)

% counted_mat_file = [folder_name, '/counted_3d_cordinates.mat'];


elastix_working_folder = [folder_name, '/elastix_working'];
% file_trans_para_1 = [elastix_working_folder, '/TransformParameters.1.txt'];

% rev_elastix_working_folder = [folder_name, '/rev_elastix_working'];
temp_folder = [pwd, '/temp_folder_1'];

mkdir(rev_elastix_working_folder);
mkdir(temp_folder);


loaded_nii = niftiread(loaded_nii);
ind_nii = find(loaded_nii);
[xxx, yyy, zzz] = ind2sub(size(loaded_nii), ind_nii);
loaded_nii = loaded_nii(ind_nii);


cell_locations = [xxx, yyy, zzz];

making_text_file_for_elastix(cell_locations,temp_folder);

file_index = [temp_folder, '/indeices_for_elastix.txt'];


transformix_index_v2(file_index, temp_folder, elastix_working_folder);


% save('testing2.mat')

heatmap_using_index_file_area(temp_folder,loaded_nii,allen_anno);

movefile([temp_folder, '/*'],rev_elastix_working_folder)
