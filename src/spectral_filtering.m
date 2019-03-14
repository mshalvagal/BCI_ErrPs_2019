
function filteredEEG = spectral_filtering(rawEEG, order, lowcut, highcut)
    % Applies a bandpass butterworth filter of the specified order.
    % Applies filter along first dimension (time)
    [b, a] = butter(order, [lowcut highcut]/256);

    filteredEEG = filtfilt(b, a, rawEEG);
    
end