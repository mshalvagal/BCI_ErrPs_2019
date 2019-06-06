function [sigmoid_dist, score, eeg, zf] = online_decoder(Signal, PreprocessParams, ModelParams, varargin)
    
    if nargin==4
        zi = varargin{1};
        [preprocessed_data, ~, zf] = preprocess_eeg(Signal.new_part, PreprocessParams, true, zi);
    else
        [preprocessed_data, ~, zf] = preprocess_eeg(Signal.new_part, PreprocessParams, true);
    end

    
    num_channels = 16;
    new_eeg = preprocessed_data.signal(:, 1:num_channels);
    
    model = ModelParams.trained_classifier.model;
    
    %% CCA
    if ModelParams.do_CCA
        new_eeg = new_eeg * ModelParams.trained_classifier.CCA_W;
    end
    
%% Feature vector formation
    eeg = [Signal.already_preprocessed_part; preprocessed_data.signal(:, 1:num_channels)];
    
    if ModelParams.do_PCA
        feature_vector = online_feature_extraction(eeg, ModelParams.SR, ModelParams.downSR, ModelParams.trained_classifier.PCA);
    else
        feature_vector = reshape(eeg(:), [1, length(eeg(:))]);
    end
 
%% Decoding
    [~, score, ~] = model.predict(feature_vector);
    score = score(2);
    Const = model.Coeffs(1,2).Const;
    Linear = model.Coeffs(1,2).Linear;
    distance = Const + feature_vector * Linear;
    sigmoid_dist = 1/(1+exp(distance));
end
