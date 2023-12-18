function [] = making_csv_area(loaded_nii, csv_name, anno, out_csv_file,targeting_resolution) 


index_id = 1;
index_parent_id = 8;
index_name = 2;
index_acronym = 3;
index_structure_order = 7;





T = readtable(csv_name);

ROI_table.id = table2array(T(:,index_id));
ROI_table.parent = table2array(T(:,index_parent_id));

ROI_table.idx = find(ROI_table.id);
[~,ROI_table.p_idx]=ismember(ROI_table.parent,ROI_table.id);
ROI_table.name = table2array(T(:,index_name));
ROI_table.acronym = table2array(T(:, index_acronym));
ROI_table.structure_order = table2array(T(:, index_structure_order));

G = digraph(ROI_table.p_idx(2:end), ROI_table.idx(2:end), 1, ROI_table.name);


for NNN = 1:length(ROI_table.idx)
    
    list_of_all_ROI_inside{NNN} = find(~isinf(distances(G,NNN)));
    
end


transformed_cell_tot = zeros(length(ROI_table.idx),1);

[logi_all, loca_all] = ismember(anno(:),ROI_table.id);





cell_location_ind = find(loaded_nii);
loaded_nii = loaded_nii(cell_location_ind);


[logi, loca] = ismember(anno(cell_location_ind), ROI_table.id);

transformed_cell_loc = accumarray(loca(logi), loaded_nii(logi), size(ROI_table.idx));
transformed_label_loc = accumarray(loca_all(logi_all), 1, size(ROI_table.idx));


for NNN = 1:length(ROI_table.idx)
    transformed_cell_tot(NNN,1) = sum(transformed_cell_loc(ROI_table.idx(list_of_all_ROI_inside{NNN})));
    transformed_label_tot(NNN,1) = sum(transformed_label_loc(ROI_table.idx(list_of_all_ROI_inside{NNN})));
end

transformed_label_tot = transformed_label_tot.*targeting_resolution.*targeting_resolution.*targeting_resolution./1000000000;

transformed_cell_dens = transformed_cell_tot./transformed_label_tot;



finnal_table = cell2table([num2cell(ROI_table.id), ROI_table.name, ROI_table.acronym, num2cell(ROI_table.structure_order ), num2cell(transformed_label_tot), num2cell(transformed_cell_tot), num2cell(transformed_cell_dens)]);
finnal_table.Properties.VariableNames = {'ROI_id', 'ROI_name', 'ROI_accronym', 'Structure_order', 'ROI_Volume_mm_3', 'cell_counted',  'cell_density'};


delete(out_csv_file);
writetable(finnal_table, out_csv_file, 'writevariablenames',1);

































