function [ mean_sig ] = mean_per_channel( signal )
%Get the signal of all 16 channel for all trials and returns for each
% channel the average over all trials 
sig_size = size(signal);
mean_sig = zeros(sig_size(2),sig_size(1));
for i = 1:sig_size(2)
    mean_sig(i,:) = mean(signal(:,i,:),3);
    
end 

end

