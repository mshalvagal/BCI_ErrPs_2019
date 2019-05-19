function [preprocessed_data, b_eog] = preprocess_eeg(raw_data, params, online)
    %% Setting up
    load('matlabFunctions/chanlocs16.mat');

    num_channels = 16;
    eeg = raw_data.signal(:, 1:num_channels);
    eog = raw_data.signal(:, 17:19);

    %% EOG correction??
    if params.do_eog_correction
        if online
            b_eog = params.b_eog;
            eeg = eeg - eog*params.b_eog;
        else
            b_eog = filterEOG(params.calibration_data.eeg,params.calibration_data.eog);
            eeg = eeg - eog*b_eog;
        end
    else
        b_eog = nan;
    end
    
    %% Temporal and spatial filtering (only the ones that can be done in the beginning on all data)
    if params.do_temporal_filter
        eeg = spectral_filtering(eeg, params.temporal_filter_order, 1, 10, params.temporal_filter_type);
    end

    if params.do_spatial_filter
        eeg = spatial_filtering(eeg, params.spatial_filter_type);
    end
    
    preprocessed_data = raw_data;
    preprocessed_data.signal(:, 1:num_channels) = eeg;
    
end