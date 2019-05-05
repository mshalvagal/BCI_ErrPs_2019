function output = online_feature_extraction(signal, SR, downSampleRate, selected_channels, PCA)
    
    temp = signal(:, selected_channels);   % selected 8 channels, the windowed signal is already 600 ms 
    hz64 = downsample(temp, SR / downSampleRate);   %512/64
    featuresExtracted = [];
    for j=1:length(selected_channels)
        featuresExtracted = [featuresExtracted; hz64(:,j)];
    end
  
    output = (featuresExtracted - PCA.mu) * PCA.PCs;
    
end