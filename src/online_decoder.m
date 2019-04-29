function label = online_decoder(Signal, Model, Preprocess)
    % eeg is a T*C matrix
    
    eeg = Signal.eeg;
    eog = Signal.eog;
    SR = Signal.SampleRate;
    
    eog_b = Preprocess.eog_b;
    do_eog_correction = Preprocess.do_eog_correction;
    do_temporal_filter = Preprocess.do_temporal_filter;
    temporal_filter_type = Preprocess.temporal_filter_type;
    temporal_filter_order = Preprocess.temporal_filter_order;
    do_spatial_filter = Preprocess.do_spatial_filter;
    spatial_filter_type = Preprocess.spatial_filter_type;
    do_CCA = Preprocess.do_CCA;
    if do_CCA
        CCA_W = Preprocess.CCA_W;
    end
    do_PCA = Preprocess.do_PCA;
    
    model = Model.model;
    if do_PCA
        downSampleRate = Model.downSampleRate;
        channels = Model.channels;
        PCA = Model.PCA;
    end
    

%% EOG correction    
    if do_eog_correction
        eeg = eeg - eog * eog_b;
    end
    
%% Temporal and spatial filtering

    if do_temporal_filter
        eeg = spectral_filtering(eeg, temporal_filter_order, 1, 10, temporal_filter_type);
    end

    if do_spatial_filter
        eeg = spatial_filtering(eeg, spatial_filter_type);
        % eeg = spatial_filtering(eeg, 'Laplacian', chanlocs16);
    end    

%% CCA
    if do_CCA
        eeg = eeg * CCA_W;
    end
    
%% Feature vector formation

    if do_PCA
        feature_vector = online_feature_extraction(eeg, SR, downSampleRate, channels, PCA);
    else
        feature_vector = eeg(:);
    end
 
%% Decoding

    label = model.predict(feature_vector);

end