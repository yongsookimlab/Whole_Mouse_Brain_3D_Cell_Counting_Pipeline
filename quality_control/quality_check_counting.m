clear
close all
 %% setting
folder_list = {
    'Z:\STPT\Glia_processed\Microglia\P14\20230811_JL_JL0774_F_P14_Cx3cr1-eGFP-8_Het';
    };

out_folder = 'Z:\STPT\Glia_processed\Microglia\P14\20230811_JL_JL0774_F_P14_Cx3cr1-eGFP-8_Het\QC\QC1';


skipping_z = 20;


%% code

for ii = 1:length(folder_list)
    C = strsplit(folder_list{ii},{'/','\\'});
    brain_list(ii).folder_list = folder_list{ii};
    brain_list(ii).internal_name = C{end};
end
mkdir(out_folder);


for kk = 1:length(brain_list)
    
        conting_v_func(brain_list(kk), skipping_z, out_folder)
end

