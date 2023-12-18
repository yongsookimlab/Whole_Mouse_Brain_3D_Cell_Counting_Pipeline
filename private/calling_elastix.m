function [] = calling_elastix(image_move, image_fix, para_elastx_0, para_elastx_1, dir_out)

%{
local_temp_folder = [pwd, '/local_temp_folder_', num2str(floor(now.*1000000000))];
mkdir(local_temp_folder);

local_temp_folder_wsl = local_temp_folder;
%local_temp_folder_wsl(strfind(local_temp_folder_wsl,'\'))='/';
%local_temp_folder_wsl(1) = lower(local_temp_folder_wsl(1));
%local_temp_folder_wsl(2) = [];
%local_temp_folder_wsl = ['/mnt/', local_temp_folder_wsl];

copyfile(para_elastx_0, local_temp_folder);
aaa = dir(para_elastx_0);
para_elastx_0 = [local_temp_folder_wsl, '/', aaa(1).name];

copyfile(para_elastx_1, local_temp_folder);
aaa = dir(para_elastx_1);
para_elastx_1 = [local_temp_folder_wsl, '/', aaa(1).name];

copyfile(image_move, local_temp_folder);
aaa = dir(image_move);
image_move = [local_temp_folder_wsl, '/', aaa(1).name];

copyfile(image_fix, local_temp_folder);
aaa = dir(image_fix);
image_fix = [local_temp_folder_wsl, '/', aaa(1).name];

cmd_command = ['elastix -m ', image_move, ' -f ', image_fix, ' -p ', para_elastx_0, ' -p ', para_elastx_1, ' -out ' local_temp_folder_wsl ];

system(cmd_command);

expression = '\(InitialTransformParametersFileName "(.+)/TransformParameters.0.txt"\)';
replace = ['(InitialTransformParametersFileName "', local_temp_folder_wsl, '/TransformParameters.0.txt")'];


fid  = fopen(file_trans_para_1,'r');
f=fread(fid,'*char')';
fclose(fid);
f = regexprep(f,expression,replace);
fid  = fopen(file_trans_para_1,'w');
fprintf(fid,'%s',f);
fclose(fid);





copyfile([local_temp_folder, '/*'], dir_out);
rmdir(local_temp_folder, 's')
%}


mkdir(dir_out);

cmd_command = ['elastix -m ', image_move, ' -f ', image_fix, ' -p ', para_elastx_0, ' -p ', para_elastx_1, ' -out ' dir_out ];

system(cmd_command);
