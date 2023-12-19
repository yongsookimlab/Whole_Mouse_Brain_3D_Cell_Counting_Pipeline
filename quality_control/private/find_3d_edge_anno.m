function [edge_vox] = find_3d_edge_anno(anno_vox)

edge_vox = false(size(anno_vox));

edge_vox(1:end-1,1:end-1,1:end-1) = ...
    anno_vox(1:end-1,1:end-1,1:end-1) ~= anno_vox(2:end,1:end-1,1:end-1) | ...
    anno_vox(1:end-1,1:end-1,1:end-1) ~= anno_vox(1:end-1,2:end,1:end-1) | ...
    anno_vox(1:end-1,1:end-1,1:end-1) ~= anno_vox(2:end,1:end-1,2:end) ;


    