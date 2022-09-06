% Compute the Fisher descriptors for a set of images
% Usage: V = compute_fisher (gmm, S)
%
% where
%   gmm     is the dictionary of centroids 
%   S       is a cell structure. Each cell is a set of descriptors for an image
%
% Both centroids and descriptors are stored per column
function V = compute_fisher (w, mu, sigma, localdesc_mean, localdesc_pca, S); 

nimg = length (S);
k = size (mu, 2);
d = size (mu, 1);
V = zeros (2* k * d, nimg, 'single');

for i = 1:nimg
  
  descs = single(S{i});
  
  % apply PCA to the descriptors
  
  ndescs = size(descs, 2);
    
  descs_centered = descs - repmat(localdesc_mean, 1, ndescs);

  descs_pca = localdesc_pca * descs_centered;
  
 % V(:, i) = yael_fisher (descs_pca, w', mu, sigma, 'nonorm');
 %V(:, i) = vl_fisher (descs_pca, mu, sigma, w);
 enc = vl_fisher (descs_pca, mu, sigma, w);
 V(:,i) = enc;
    
end
