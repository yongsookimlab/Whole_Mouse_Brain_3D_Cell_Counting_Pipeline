function transformix_index_v2(file_index, dir_trans_out, elastix_working_folder)


file_trans_para_1 = [elastix_working_folder, '/TransformParameters.1.txt'];
file_trans_para_0 = [elastix_working_folder, '/TransformParameters.0.txt'];



dir_asd_in = dir(file_trans_para_0);
dir_asd_in = dir_asd_in(1).folder;

dir_asd_in = strrep(dir_asd_in,'\','/')



expression = '\(InitialTransformParametersFileName "(.+)TransformParameters.0.txt"\)';
replace = ['(InitialTransformParametersFileName "', dir_asd_in, '/TransformParameters.0.txt")'];


fid  = fopen(file_trans_para_1,'r');
f=fread(fid,'*char')';
fclose(fid);

f = regexprep(f,expression,replace);

fid  = fopen(file_trans_para_1,'w');
fprintf(fid,'%s',f);
fclose(fid);




transform_command_line = ['transformix -def ' file_index ' -out ' dir_trans_out ' -tp ' file_trans_para_1];
dos(transform_command_line);
