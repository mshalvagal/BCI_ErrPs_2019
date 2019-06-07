function [out_data] = offline_epoching(in_data)

%OFFLINE_EPOCHING Summary of this function goes here
%   Detailed explanation goes here

    num_channels = 16;
    eeg = in_data.signal(:, 1:num_channels);
    behavior = in_data.behavior;
    header = in_data.header;
    
    %% Separate the trials

    eggTrigger = in_data.signal(:, 33);
    behavioralTrigger = in_data.behavior(:, 2);

    eegIdx = find(diff(eggTrigger)) + 1;
    eegIdx = eegIdx(eggTrigger(eegIdx) == 3);
    behavIdx = find(diff(behavioralTrigger)) + 1;
    behavIdx = behavIdx(behavioralTrigger(behavIdx) == 3);
    magnitude = behavior(behavIdx, 3);

    corrTrialsIdx = find(magnitude==0);
    errTrialsIdx = find(abs(magnitude)>0);

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
    out_data.eeg_epoched = cat(3, ErrTrials, CorrTrials);
    out_data.labels = zeros(size(out_data.eeg_epoched, 3), 1);
    out_data.labels(1:size(errTrialsIdx, 1)) = 1;
    
    %% Also keep the eeg time series and trial indices for the online decoding
    fullIdx = find(diff(eggTrigger)) + 1;
    fullIdxStart = fullIdx(eggTrigger(fullIdx) == 1);
    out_data.fullIdxStart = fullIdxStart([errTrialsIdx;corrTrialsIdx]);
    fullIdxEnd = fullIdx(eggTrigger(fullIdx) == 0)-1;
    out_data.fullIdxEnd = fullIdxEnd([errTrialsIdx;corrTrialsIdx]);
    out_data.triggerOnset = eegIdx;
end

