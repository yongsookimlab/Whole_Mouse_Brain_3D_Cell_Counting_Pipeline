function [im_in_mean] = otsu_mean(im_in)


[counts,~] = imhist(im_in,65535);
T = otsuthresh(counts);
BW = imbinarize(im_in,T.*0.75);
im_in = double(im_in);

im_in_mean = mean(im_in(BW(:)));