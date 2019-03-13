function [ mean_sig ] = mean_per_channel( signal )
    % Get the signal of all 16 channel for all trials and returns for each
    % channel the average over all trials
    % signal is T * C * N 
    C = size(signal, 2);
    T = size(signal, 1);
    mean_sig = zeros(T, C);
    
    for i = 1:C
        mean_sig(:,i) = mean(signal(:,i,:),3);
    end 
    
end

