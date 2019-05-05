function output = online_feature_extraction(signal, SR, downSampleRate, PCA)

    % eight fronto-central channels (Fz, FC1, FCz, FC2, C1, Cz, C2, and CPz)
    selected_channels = [1 3 4 5 8 9 10 14];

    temp = signal(:, selected_channels);   % selected 8 channels, the windowed signal is already 600 ms 
    hz64 = downsample(temp, SR / downSampleRate);   %512/64
    featuresExtracted = [];
    for j=1:length(selected_channels)
        featuresExtracted = [featuresExtracted; hz64(:,j)];
    end
  
    output = (featuresExtracted' - PCA.mu) * PCA.PCs;
    
end