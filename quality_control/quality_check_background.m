clear
close all

%% Settings for Background Quality Check (QC2)
% When run, this code will use a rotated, downsized image TIF stack of the brain and elastix registration results to align the counted 3D voxels to the chosen 3D reference space. The result is a RGB image (NII and/or PNG file) with the aligned 3D counts in reference space. The warmer colors denote higher counts/density. With this QC, you can quickly check registration quality for specified z-intervals without performing elastix on the full dataset.

% Input folder pathname of directory containing STPT sample images and ML counting output.
folder_list = {
    'Z:\STPT\Glia_processed\Microglia\P14\20230811_JL_JL0774_F_P14_Cx3cr1-eGFP-8_Het';
    };

% Specify QC output folder name and location with the full path.
out_folder = 'Z:\STPT\Glia_processed\Microglia\P14\20230811_JL_JL0774_F_P14_Cx3cr1-eGFP-8_Het\QC\QC2';

% Specify the z-interval at which the QC code will run on the full TIF stack. Example, if skipping_z is set equal to 50, code will run QC on z050, z100, z150, and so on.
skipping_z = 50;

showing_figure = 0;
saving_nii = 1;
saving_png = 1;


%% Code

for ii = 1:length(folder_list)
    C = strsplit(folder_list{ii},{'/','\\'});
    brain_list(ii).folder_list = folder_list{ii};
    brain_list(ii).internal_name = C{end};
end

mkdir(out_folder);


% for kk = 1:2

for kk = 1:length(brain_list)
    
    RRR = niftiread([brain_list(kk).folder_list, '/counted_3d_visual.nii']);
    GGG = permute(FastTiff([brain_list(kk).folder_list,'/elastix_working/rotated_chx.tif']),[ 2 1 3]);
    
    BBB = read_mhd([brain_list(kk).folder_list,'/elastix_working/result.mhd']);
    BBB = BBB.data;
    BBB = find_3d_edge_anno(BBB);
    
    
    RRR = RRR./max(RRR(:));
    GGG = GGG./max(GGG(:));
    BBB = BBB./max(BBB(:));
    
    RGB = cat(4, single(RRR).*3,single(GGG).*0.75,single(BBB));
    
    visual_rgb = {};
    for ii = skipping_z:skipping_z:size(RGB,2)
        visual_rgb{ii./skipping_z,1} = squeeze(RGB(:,ii,:,:));
    end
    for jj = skipping_z:skipping_z:size(RGB,3)
        visual_rgb{jj./skipping_z,2} = squeeze(RGB(:,:,jj,:));
    end
    
    for ii = 2:length(visual_rgb(:))
        if isempty(visual_rgb{ii})
            visual_rgb{ii} = visual_rgb{ii-1}.*0.0;
        end
    end
    visual_rgb = cell2mat(visual_rgb);
    if showing_figure
        figure;imshow(visual_rgb);
    end
    if saving_nii
        niftiwrite(visual_rgb,[out_folder,'/',brain_list(kk).internal_name,'.nii']);
    end
    if saving_png
        imwrite(visual_rgb,[out_folder,'/',brain_list(kk).internal_name,'.png']);
    end
    
end

