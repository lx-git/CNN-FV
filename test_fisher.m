

%% Clear your command window, clear variables, breakpoints, cached memory, close all figures.
clc;
clear all;
close all;

%% Set up VlFeat
setup;

% Yael install dir 
dir_yael = 'yael/';

% Where to find Holiday's image descriptors
dir_sift = 'siftgeo/';

% Where to find the learnt data (GMM & PCA matrices)
dir_data = 'data/';

% access to Yael's matlab functions
addpath ([dir_yael '/matlab']);

% nb of Gaussians in the GMM (files for k = 16 and k = 64 given in the package)
k=64;

% SIFT local descriptor PCA matrix 
f_localdesc_pca = [dir_data 'sift_pca_matrix.fvecs'];

% nb of dimensions to keep in local descriptors
localdesc_dd = 64;

% compute Fisher descriptors or use the pre-compiled ones?
do_compute_fisher = true;

% GMM parameters
f_centroids = sprintf('%s/sift_pca64_k%d.gmm', dir_data, k);

% Precomputed Fisher descriptors 
f_precomputed = sprintf('%s/holidays_fisher_k%d.fvecs', dir_data, k);



% PCA matrix for the Fisher vectors 
f_pca_proj = sprintf('%s/fisher_k%d_pca_matrix.fvecs', dir_data, k);

% nb of dimensions to keep after Fisher descriptor is projected
dd = 128;



% during evaluation, how many results per query to keep
shortlistsize = 1000;

%----------------------------------------------------------------------------
% Retrieve the list of images and construct the groundtruth
[imlist, sift, gnd, qidx] = load_holidays (dir_sift, do_compute_fisher);


%----------------------------------------------------------------------------
% compute or load the Fisher descriptors
if do_compute_fisher                 % compute Fisher vecs from SIFT descriptors

  [w, mu, sigma] = gmm_read (f_centroids);    
  [localdesc_mean, localdesc_pca] = pca_mat_read(f_localdesc_pca); 
  
  localdesc_pca = localdesc_pca(1:localdesc_dd,:);
  
  v = compute_fisher (w, mu, sigma, localdesc_mean, localdesc_pca, sift); 
else                               % load them from disk
  v = fvecs_read (f_precomputed);
end
d_fisher = size (v, 1);              % dimension of the Fisher vectors

% power "normalization"
v = sign(v) .* sqrt(abs(v)); 

% L2 normalization (may introduce NaN vectors)
vn = yael_fvecs_normalize (v);

% replace NaN vectors with a large value that is far from everything else
% For normalized vectors in high dimension, vector (0, ..., 0) is *close* to
% many vectors.

vn(find(isnan(vn))) = 123; 

%----------------------------------------------------------------------------
% Full Fisher
% perform the queries (without product quantization nor PCA) and find 
% the rank of the tp. Keep only top results (i.e., keep shortlistsize results). 
% for exact mAP, replace following line by k = length (imlist)

[idx, dis] = yael_nn (vn, vn(:,qidx), shortlistsize + 1);
idx = idx (2:end,:);  % remove the query from the ranking

map_fisher = compute_map (idx, gnd);
fprintf ('Fisher k=%d			%4dD	mAP = %.3f\n', ...
         k, k * localdesc_dd, map_fisher);


%----------------------------------------------------------------------------
% Fisher with PCA projection
% perform the PCA projection, and keep dd components only

% load PCA matrix. There is no mean as the 
pca_proj = fvecs_read (f_pca_proj);
pca_proj = pca_proj (:,1:dd)';

% project the descriptors and compute the results after PCA
vp = pca_proj * vn;

%vp = yael_fvecs_normalize (vp);

[idx, dis] = yael_nn (vp, vp(:,qidx), shortlistsize + 1);
idx = idx (2:end,:);  % remove the query from the ranking

map_fisher_pca = compute_map (idx, gnd);
fprintf ('Fisher + PCA (D''=%d)		%4dD	mAP = %.3f\n', ...
         dd, dd, map_fisher_pca);


