function [circle_mask] = making_a_circle(radii_draw)



imageSizeX = radii_draw.*2+1;
imageSizeY = radii_draw.*2+1;
[columnsInImage, rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);
% Next create the circle in the image.
centerX = radii_draw+1;
centerY = radii_draw+1;
radius = radii_draw;
circle_mask = round(sqrt((rowsInImage - centerY).^2 ...
    + (columnsInImage - centerX).^2)) == radius;
