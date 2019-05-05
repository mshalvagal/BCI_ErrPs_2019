function label = online_decoder(Signal, PreprocessParams, ModelParams)
    
    [preprocessed_data, ~] = preprocess_eeg(Signal, PreprocessParams, true);
    
    num_channels = 16;
    eeg = preprocessed_data.signal(:, 1:num_channels);
    
    model = ModelParams.trained_classifier.model;
    
    %% CCA
    if ModelParams.do_CCA
        eeg = eeg * ModelParams.trained_classifier.CCA_W;
    end
    
%% Feature vector formation
    if ModelParams.do_PCA
        feature_vector = online_feature_extraction(eeg, ModelParams.SR, ModelParams.downSR, ModelParams.trained_classifier.PCA);
    else
        feature_vector = reshape(eeg(:), [1, length(eeg(:))]);
    end
 
%% Decoding
    label = model.predict(feature_vector);

end