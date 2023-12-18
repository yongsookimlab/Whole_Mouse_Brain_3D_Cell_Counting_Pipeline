function [] = ilastik_loop_all_img(ilastik_location, project_name, images_in_folder, images_out_folder)

numcores = 10; % Number of cores for parallelization. Original was 8

project_name = ['"',project_name,'"'];
tif_list = dir([images_in_folder,'/*.tif']);

parfor (ii = 1:length(tif_list), numcores)
    
    images_in = [tif_list(ii).folder, '/', tif_list(ii).name];
    disp(['Running: ', images_in])
    images_in = ['"',images_in,'"'];
    
    ilatiks_command_line = strcat(ilastik_location, ...
        '  --headless', ...
        '  --readonly', ...
        '  --output_format=tif', ...
        '  --output_filename_format="', images_out_folder,'/{nickname}.tif"', ...
        '  --project=', project_name,...
        '  --export_source="simple segmentation"', ...
        '  --raw_data=',images_in);
    
    [~,~] = system(ilatiks_command_line)
    
end