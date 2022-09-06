% Read the mean and PCA matrix stored in a file
%
% Syntax: 
%   [mean, pcamat] = fvecs_read (filename)     


function [mean, pcamat] = pca_mat_read(filename)

m1 = fvecs_read(filename);

mean = m1(:, 1);

pcamat = m1(:, 2:end)'; 
