
function filtered_signal = CAR_filter(signal)
    % signal is T * C in which T is the time length of the signal and C is
    % the number of the channels
    C = size(signal, 2);    
    common_signal = mean(signal, 2);
    filtered_signal = signal - repmat(common_signal, [1, C]);
end