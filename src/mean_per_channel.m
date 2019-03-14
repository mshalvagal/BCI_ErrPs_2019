function [ mean_sig ] = mean_per_channel( signal )
    % Get the signal of all 16 channel for all trials and returns for each
    % channel the average over all trials
    % signal is T * C * N 
    mean_sig = mean(signal, 3);    
end

