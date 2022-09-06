% This function reads a siftgeo binary file, keeping only the descriptors and
% returning them as a byte array
%
% Usage: v = siftgeo_read (filename)
%   filename    the input filename
%
% Returned values
%   v           the sift descriptors (1 descriptor per line)

function v = siftgeo_read_byte (filename)

    
  
% open the file and count the number of descriptors
fid = fopen (filename, 'r');

if fid==-1
  error('could not open %s',filename)
end

% size of metadata to skip + dimension of descriptor
skip = 9 * 4 + 4; 

st = fseek(fid, skip, 0);

if st < 0,
  % no descriptor in file
  v = zeros(128, 0); 
  return 
end

% assume 128 D descriptors
d = 128;
v = fread(fid, [d, Inf], '128*uint8=>uint8', skip);

fclose(fid);
