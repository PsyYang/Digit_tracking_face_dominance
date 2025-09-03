function heat_map = filter_2d_heat_map(heat_map, ksstdx, ksstdy)
%FILTER_3D_HEAT_MAP Apply a guassian filter to the provided 3D image
%
%   HEAT_MAP = FILTER_3D_HEAT_MAP(HEAT_MAP_3D, KSSTDX, KSSTDY, KTSTD)
%
%   HEAT_MAP_3D is a 3D image with third dimension being time
%
%   KSSTDX is the standard deviation of the gaussian filter in the X
%   direction
%
%   KSSTDY is the standard deviation of the gaussian filter in the Y
%   direction
%
%   KTSTD is the standard deviation of the gaussian filter in the time
%   direction

size = 6; % 6 * kernel size give 99% of distribution density

l = -ceil(ksstdx*size):ceil(ksstdx*size);
hx = exp(-(l.^2/(2*ksstdx^2)));
hx = hx/sum(hx(:));
hx = reshape(hx, [1, length(hx), 1]);

l = -ceil(ksstdy*size):ceil(ksstdy*size);
hy = exp(-(l.^2/(2*ksstdy^2)));
hy = hy/sum(hy(:));
hy = reshape(hy, [length(hy), 1, 1]);

heat_map = convn(heat_map, hy, 'same');
heat_map = convn(heat_map, hx, 'same');

end
