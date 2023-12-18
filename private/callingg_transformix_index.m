function callingg_transformix_index(file_index, dir_elestix_working, file_trans_para_1)

%file_trans_para_1 = [dir_elestix_working, '/TransformParameters.1.txt'];
%file_trans_para_0 = [dir_elestix_working, '/TransformParameters.0.txt'];



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

transform_command_line = [pwd, '/transformix -def ' file_index, ' -out ' dir_elestix_working ' -tp ' file_trans_para_1];

system(transform_command_line);