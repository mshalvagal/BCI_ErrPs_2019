function output = online_feature_extraction(signal, ModelParams)
    SR = ModelParams.SR;
    downSampleRate = ModelParams.downSR;

    % eight fronto-central channels (Fz, FC1, FCz, FC2, C1, Cz, C2, and CPz)
%     selected_channels = [1 3 4 5 8 9 10 14];
    selected_channels = 1:16;

    temp = signal(:, selected_channels);   % selected 8 channels, the windowed signal is already 600 ms 
    hz64 = downsample(temp, SR / downSampleRate);   %512/64
    featuresExtracted = [];
    for j=1:length(selected_channels)
        featuresExtracted = [featuresExtracted; hz64(:,j)];
    end
  
    if ModelParams.do_PCA
        PCA = ModelParams.trained_classifier.PCA;
        output = (featuresExtracted' - PCA.mu) * PCA.PCs;
    else
        indices = ModelParams.trained_classifier.feature_indices;
        output = featuresExtracted(indices)';
    end
    
end