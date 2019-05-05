function [ filt_train, filt_test,W ] = CCA(train_set,train_labbel, test_set ) 
% Using CCA to filter the signal   
%  Input : - concatenated, epoched correct and erronous signal that already has been spectrally filtered 
%          dim :T*M*K with T the time sample, M the channel and K the trials(correct + erroneous) 
%          - Labbel of the train_set 
%  Output : -CCA filtered train_set
%           - CCA filtered test_set 
%            dim : M*M
% When this matrix is applied the resulting signal has for each channel the 
% maximum correlation with the average over all trials of the same channel and is 
% uncorrelated to the average signal of the others channels (whitened)

% Separating the correct and error trials 
corr_trial = train_set(:,:,find(train_labbel == 0)) ;
err_trial = train_set(:,:,find(train_labbel == 1)) ;

% X = cat(3, corr_trial, err_trial);
% X = permute(X, [2, 1, 3]);
% X = reshape(X, [], size(X,2) * size(X,3));
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
 
Y = [repmat(mean_corr, 1, size(corr_trial, 3)), repmat(mean_err, 1, size(err_trial, 3))]; % concatenation of the average
 
% performing the canonical correlation to get the spatial filter W
[W,~] = canoncorr(X',Y');
 
% Applying the spatial filter for every trial for the train and test set  
filt_train = zeros(size(train_set, 1), size(W, 2), size(train_set, 3));
for itrials = 1 : size(train_set, 3)
    filt_train(:,:,itrials) = train_set(:,:,itrials) * W;
end

% removing the average ? 
filt_test = zeros(size(test_set, 1), size(W, 2), size(test_set, 3));
for itrials = 1 : size(test_set, 3)
    filt_test(:,:,itrials) = test_set(:,:,itrials) * W;
end
 
end
