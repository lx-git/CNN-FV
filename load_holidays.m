% Load the set of image descriptors of the Holidays dataset
% and construct the groundtruth.
% Usage: [imlist, sift, qidx, gnd] = load_holidays (dir_sift, load_descriptors)
% 
% Input/Output variables:
%   dir_sift   the directory where the siftgeo files are stored
%   imlist     the list of image number (the number of the files)
%   sift       a cell containing the sift descriptors (set to {} if
%              load_descriptors = 0)
%   gnd        the groundtruth: first value is the query number
%              next are the corresponding matching images
function [imlist, sift, gnd, qidx] = load_holidays (dir_sift, load_descriptors)

% load also descriptors by default
if nargin == 1
  load_descriptors = 1;
end
  
siftfname = struct2cell (dir([dir_sift '*.siftgeo']));
siftfname = siftfname(1, :);

nimg = size (siftfname, 2);

nq = 500;                 % number of queries
imlist = [];              % the set of image number
qidx = [];                % the query identifiers
gnd = cell (nq, 1);       % first element is the query image number
                          % following are the corresponding matching images
sift = cell (nimg, 1);    %  one set of descriptors per image

qno = 0;                  % current query number
for i = 1:nimg
  imno = str2num(siftfname{i}(1:end-8)); 
  imlist = [imlist imno]; % compute image number
  
  if mod(imno, 100) == 0
    qno = qno + 1;
    qidx = [qidx i];
  end
  
  gnd{qno} = [gnd{qno} i];

  if load_descriptors, 
    sift{i} = siftgeo_read_byte ([dir_sift siftfname{i}]);
  else
    sift{i} = [];
  end
  
end 

