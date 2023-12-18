function [] = registeringg_anno_to_real_space(folder_name, allen_back,allen_anno)
% clear
%%%  %Settings
% folder_name = 'E:\20201219_KN_KN454_p14_F_GOF6_CreNeg_fos561_bg488_4x_reimage';
%registering_ch = 'stitched_01';
% brain_xyz_orientation = [6 3 2];
para_elastx_0 = strcat(pwd, '/elastix/parameter_YT_v2/001_parameters_Rigid.txt'); % parameter_1
para_elastx_1 = strcat(pwd, '/elastix/parameter_YT_v2/002_parameters_BSpline.txt'); % parameter_2

elastix_working_folder = [folder_name, '/elastix_working'];

rotated_chx_file = [elastix_working_folder, '/rotated_chx.tif'];


temp_folder = [pwd, '/temp_folder_1'];




calling_elastix( allen_back, rotated_chx_file, para_elastx_0, para_elastx_1, temp_folder);

file_trans_para_1 = strcat(temp_folder, '\TransformParameters.1.txt');

callingg_transformix(allen_anno, temp_folder, file_trans_para_1);





movefile([temp_folder, '/*'],elastix_working_folder)
