function [preprocessed_eeg, labels, header] = preprocess_eeg(dataset_path, varargin)
% function [CorrTrials, ErrTrials, header] = preprocess_eeg(dataset_path, varargin)
    %% Parse input arguments
    p = inputParser;

    p.addRequired('datapath',@isstr);
    p.addOptional('training_set', true, @islogical);
    p.addOptional('do_eog_correction', true, @islogical);
    p.addOptional('do_temporal_filter', true, @islogical);
    p.addOptional('temporal_filter_type', 'butter', @isstr);
    p.addOptional('temporal_filter_order', 2, @isstr);
    p.addOptional('do_spatial_filter', false, @islogical);
    p.addOptional('spatial_filter_type', 'CAR', @isstr);
    p.addOptional('do_CCA', false, @islogical);
    parse(p,dataset_path,varargin{:});
    
    training_set = p.Results.training_set;
    do_eog_correction = p.Results.do_eog_correction;
    do_temporal_filter = p.Results.do_temporal_filter;
    temporal_filter_type = p.Results.temporal_filter_type;
    temporal_filter_order = p.Results.temporal_filter_order;
    do_spatial_filter = p.Results.do_spatial_filter;
    spatial_filter_type = p.Results.spatial_filter_type;
    do_CCA = p.Results.do_CCA;

    %% Read data
    dirinfo = dir(dataset_path);

    signal = double.empty();
    behavior = double.empty();

    for i = 1:size(dirinfo)

        % Read training set or the test set according to the input
        % arguments (training set by default)
        if training_set
            if contains(dirinfo(i).name, 'Online') | contains(dirinfo(i).name, 'calibration') | contains(dirinfo(i).name, '.')
                continue
            end
        else
            if ~contains(dirinfo(i).name, 'Online')
                continue
            end
        end

        path = [dirinfo(i).folder '/' dirinfo(i).name];

        [batch_signal, header] = sload([path '/' dirinfo(i).name '.gdf']);

        batch_behavior = single(dlmread([path '/' dirinfo(i).name '.txt']));

        signal = [signal; batch_signal];
        behavior = [behavior; batch_behavior];

    end

    load('matlabFunctions/chanlocs16.mat');

    num_channels = 16;
    eeg = signal(:, 1:num_channels);
    eog = signal(:, 17:19);

    %% EOG correction??
    if do_eog_correction
        b = filterEOG(eeg,eog);
        % if we want to use EOG corrected version, change eeg_EOGcorrected to eeg
        eeg = eeg - eog*b;
    end
    
    %% Temporal and spatial filtering

    if do_temporal_filter
        eeg = spectral_filtering(eeg, temporal_filter_order, 1, 10, temporal_filter_type);
        % eeg = spectral_filtering(eeg, temporal_filter_order, 1, 10, temporal_filter_type);
    end

    if do_spatial_filter
        eeg = spatial_filtering(eeg, spatial_filter_type);
        % eeg = spatial_filtering(eeg, 'Laplacian', chanlocs16);
    end

    %% Separate the trials

    eggTrigger = signal(:, 33);
    behavioralTrigger = behavior(:, 2);

    eegIdx = find(diff(eggTrigger)) + 1;
    eegIdx = eegIdx(eggTrigger(eegIdx) == 3);
    behavIdx = find(diff(behavioralTrigger)) + 1;
    behavIdx = behavIdx(behavioralTrigger(behavIdx) == 3);
    magnitude = behavior(behavIdx, 3);

    corrTrialsIdx = find(magnitude==0);
    errTrialsIdx = find(magnitude>0);

    before_rot_onset = -0.5;
    after_rot_onset = 1;
    sampleTrial = before_rot_onset*header.SampleRate:after_rot_onset*header.SampleRate;

    CorrTrials = zeros(length(sampleTrial), num_channels, length(corrTrialsIdx));
    ErrTrials = zeros(length(sampleTrial), num_channels, length(errTrialsIdx));

    for idx = 1:length(corrTrialsIdx)
        CorrTrials(:, :, idx) = eeg(sampleTrial + eegIdx(corrTrialsIdx(idx)), :); 
    end

    for idx = 1:length(errTrialsIdx)
        ErrTrials(:, :, idx) = eeg(sampleTrial + eegIdx(errTrialsIdx(idx)), :); 
    end
    
    %% Combine both classes to give training data
    preprocessed_eeg = cat(3, ErrTrials, CorrTrials); 
    labels = zeros(size(preprocessed_eeg, 3), 1);
    labels(1:size(errTrialsIdx, 1)) = 1;
    
end