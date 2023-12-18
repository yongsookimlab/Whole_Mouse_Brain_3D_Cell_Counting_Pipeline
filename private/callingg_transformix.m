function callingg_transformix(file_index, dir_elastix_working, file_trans_para_1)

%file_trans_para_1 = [dir_elastix_working, '/TransformParameters.1.txt']; 
%file_trans_para_0 = [dir_elastix_working, '/TransformParameters.0.txt']; 



%dir_elestix_in = 
%{
expression = '\(InitialTransformParametersFileName "(.+)TransformParameters.0.txt"\)';
replace = ['(InitialTransformParametersFileName "', dir_elestix_in, '/TransformParameters.0.txt")'];


fid  = fopen(file_trans_para_1,'r');
f=fread(fid,'*char')';
fclose(fid);

f = regexprep(f,expression,replace);

fid  = fopen(file_trans_para_1,'w');
fprintf(fid,'%s',f);
fclose(fid);
%}

mkdir(dir_elastix_working);
transform_command_line = [pwd, '/transformix -in ' file_index, ' -out ' dir_elastix_working ' -tp ' file_trans_para_1];

system(transform_command_line);