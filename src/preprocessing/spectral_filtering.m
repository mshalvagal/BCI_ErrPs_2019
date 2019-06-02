function filteredEEG = spectral_filtering(rawEEG, order, lowcut, highcut, type)
    % Applies filter along first dimension (time)
    if strcmp(type, 'butter')
        % Applies a bandpass butterworth filter of the specified order.
        [b, a] = butter(order, [lowcut highcut]/256);
        filteredEEG = filtfilt(b, a, rawEEG);
    elseif strcmp(type, 'fir')
        b = fir1(48, [lowcut highcut]/256);
        filteredEEG = filter(b, 1, rawEEG);
    end
end