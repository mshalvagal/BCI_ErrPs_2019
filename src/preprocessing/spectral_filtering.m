function [filteredEEG, varargout] = spectral_filtering(rawEEG, order, lowcut, highcut, type, online, varargin)
    % Applies filter along first dimension (time)
    if strcmp(type, 'butter')
        % Applies a bandpass butterworth filter of the specified order.
        [b, a] = butter(order, [lowcut highcut]/256);
        % filteredEEG = filtfilt(b, a, rawEEG);
    elseif strcmp(type, 'fir')
        a = 1;
        b = fir1(48, [lowcut highcut]/256);
    end
    
    if online
        if nargin==7
            zi = varargin{1};
            [filteredEEG, zf] = filter(b, a, rawEEG, zi);
        else
            [filteredEEG, zf] = filter(b, a, rawEEG);
        end
        varargout{1} = zf;
    else
        filteredEEG = filter(b, a, rawEEG);
    end
    
end