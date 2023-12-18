function transformix_index(file_index, dir_trans_out, file_trans_para)


transform_command_line = ['transformix -def ' file_index ' -out ' dir_trans_out ' -tp ' file_trans_para];
dos(transform_command_line);
