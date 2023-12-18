function [xxx,yyy]=local_maximum_finder(A, threshhold, cell_size_r)


% cell_size_r = 8;

BW = imregionalmax(A);
local_max_list = find(BW);


H = fspecial('disk',ceil(cell_size_r.*4));
blurred = imfilter(A,H); 
local_max_list = local_max_list( A(local_max_list)>blurred(local_max_list)+threshhold & blurred(local_max_list) > 50);


[xxx,yyy] = ind2sub(size(A),local_max_list);

flag = (xxx>cell_size_r & xxx < size(A,1)-cell_size_r & yyy>cell_size_r & yyy < size(A,2)-cell_size_r);

xxx = xxx(flag);
yyy = yyy(flag);

flag = false(size(xxx));

cross_center = ceil((cell_size_r.*2+1).*(cell_size_r.*2+1)./2);
mask=FullDiskMask(cell_size_r.*cell_size_r);

for ii = 1:length(xxx)
    
    zone =  A(xxx(ii)-cell_size_r:xxx(ii)+cell_size_r,yyy(ii)-cell_size_r:yyy(ii)+cell_size_r);
    zone(~mask) = 0;
    [~,I] = max(zone(:));
    if I == cross_center
        flag(ii) = 1;
        
    end
end

xxx = xxx(flag);
yyy = yyy(flag);

