function [] = tif_write_stack(V, tif_file_name)

for ii = 1:size(V,3)
    if ii == 1
        imwrite(V(:,:,ii),tif_file_name, 'Compression','lzw');
    else
        imwrite(V(:,:,ii),tif_file_name,'WriteMode','append', 'Compression','lzw' );
    end
end