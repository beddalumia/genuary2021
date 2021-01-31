%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Assuming $pip3 install block_distortion$ to have been run (v.1.0.1)
%

system('block_dist single --splits 10000 --out matest.jpg ./test.jpg');

% Usage: block_dist single [OPTIONS] IMAGE_PATH
%
%   Produce a single image with distortion effects.
%
% Arguments:
%   IMAGE_PATH  Input file (png, jpg, etc)  [required]
%
% Options:
%   --splits INTEGER  Number of times to split the image  [default: 2000]
%   --out TEXT        Name of output file (gif)  [default: ./output.png]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%