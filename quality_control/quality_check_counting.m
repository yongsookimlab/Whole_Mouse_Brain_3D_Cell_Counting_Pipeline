clear
close all

%% Settings for Counting Quality Check (QC1)
% When run, this code will check the full resolution stitched images at the specified z-intervals and draw red circles around each counted cell based on the ilastik ML results. With this QC, it is easy to check whether the trained ML needs improvement. You can also use this to calculate an F-scpre.

% Input folder pathname of directory containing STPT sample images and ML counting output.
folder_list = {
    'Z:\STPT\Glia_processed\Microglia\P14\20230811_JL_JL0774_F_P14_Cx3cr1-eGFP-8_Het';
    };

% Specify QC output folder name and location with the full path.
out_folder = 'Z:\STPT\Glia_processed\Microglia\P14\20230811_JL_JL0774_F_P14_Cx3cr1-eGFP-8_Het\QC\QC1';

% Specify the z-interval at which the QC code will run on the full TIF stack. Example, if skipping_z is set equal to 20, code will run QC on z020, z040, z060, and so on.
skipping_z = 20;


%% Code

for ii = 1:length(folder_list)
    C = strsplit(folder_list{ii},{'/','\\'});
    brain_list(ii).folder_list = folder_list{ii};
    brain_list(ii).internal_name = C{end};
end
mkdir(out_folder);


for kk = 1:length(brain_list)
    
        conting_v_func(brain_list(kk), skipping_z, out_folder)
end

