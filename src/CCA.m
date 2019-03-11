function [ corr_cca, err_cca ] = CCA(corr_trials, err_trials)
% Using CCA to filter the signal   
%  W is the tranformation that maximize the correlation between the signal
%  denaoted by X and the average over all trials  denoted by Y 
% therefore correcting mostly for noise (which is not part of the average) 
% First create a matrix concatenating all trials for each channel
corr_p = permute(corr_trials,[2 1 3]);
corr_s = size(corr_p);
Corr_cat = reshape(corr_p,[],corr_s(2)*corr_s(3)); 
err_p = permute(err_trials,[2 1 3]);
err_s = size(err_p);
Err_cat = reshape(err_p,[],err_s(2)*err_s(3));
% Concatenating the two class of matrix
X = [Corr_cat,Err_cat];
% creating the average matrix 
mean_corr = mean_per_channel(corr_trials);
mean_err = mean_per_channel(err_trials);
Y = [mean_corr,mean_err];
Y = repmat(Y,1,(corr_s(3)+err_s(3))/2);
% finding the filter 
[W,~] = canoncorr(X,Y);
disp(size(W));
disp(size(squeeze(corr_trials(:,1,:))));
% applying the filter to each channels 
corr_cca = W.' .* squeeze(corr_trials(:,1,:));

%err_cca = W.'.*err_trials;

end

