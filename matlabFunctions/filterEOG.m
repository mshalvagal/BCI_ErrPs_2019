function [b] = filterEOG(eeg, eog)
    
    % We perform regression following the paper:
    % "[Sch�gl 2007] A fully automated correction method of EOG artifact in
    % EEG recordings"
    % Y = S + U*b
    % Y: recorded EEG signal
    % S: clean EEG signal   
    % U: EOG channels
    % b: EOG coefficients
    
    Y = eeg;
    U = eog;
    
    covariance = cov([U Y]);
    autoCovariance_EOG = covariance(1:size(U,2), 1:size(U,2));
    crossCovariance_EOG_EEG = covariance(1:size(U,2), size(U,2)+1:end);
    b = autoCovariance_EOG \ crossCovariance_EOG_EEG;    
end

