function [ W ] = CCA(corr_trial, err_trial) 
% Using CCA to filter the signal   
%  Input : epoch signal that already has been spectrally filtered for
%           correct and erronous trials
%          dim :T*M*K with T the time sample, M the channel and K the trial 
%  Output : Filtering Matrix.When this matrix is applied the resulting signal has for each channel the maximum 
%           correlation with the average over all trials of the same channel and is 
%           uncorrelated to the average signal of the others channels (whitened)
%           dim : M*M
%  denaoted by X and the average over all trials  denoted by Y 
% therefore correcting mostly for noise (which is not part of the average) 

%Setting all signal to 0 mean 
%corr_trial = corr_trial-repmat(mean(corr_trial,1),size(corr_trial,1),1,1);
% Create a matrix concatenating all trials for each channel
concatc = permute(corr_trial,[2 1 3]);
size_concatc = size(concatc);
Corr_cat = reshape(concatc,[],size_concatc(2)*size_concatc(3)); % concatenation of the two class 
concate = permute(err_trial,[2 1 3]);
size_concate = size(concate);
Err_cat = reshape(concate,[],size_concate(2)*size_concate(3));
X = [Corr_cat,Err_cat];
 
%Create the average matrix 
mean_corr = (mean_per_channel(corr_trial)).';
mean_err = (mean_per_channel(err_trial)).';
 
Y = [repmat(mean_corr,1,size_concatc(3)),repmat(mean_err,1,size_concate(3))]; % concatenation of the average
 
% performing the canonical correlation to get the spatial filter W
[W,~] = canoncorr(X',Y');
 

 
end
