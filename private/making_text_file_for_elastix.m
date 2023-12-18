function [] = making_text_file_for_elastix(cell_locations,rev_elastix_working_folder)



file_index = [rev_elastix_working_folder, '/indeices_for_elastix.txt'];


delete(file_index)

tic

S = cellstr(num2str(cell_locations)) ;


fileID = fopen(file_index,'w');
fprintf(fileID,'point\n');
fprintf(fileID,'%i\n',size(cell_locations,1));
fprintf(fileID,'%s\n',S{:});


fclose(fileID);


toc