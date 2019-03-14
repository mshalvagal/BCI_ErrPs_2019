%% Loading the data
clear all; clc;
% Please change this loading part according to your operating system:D

[signal, header] = sload('data/ad4_20192502/ad4_Asynchronous_20192502152935/ad4_Asynchronous_20192502152935.gdf');

behavior = single(dlmread('data/ad4_20192502/ad4_Asynchronous_20192502152935/ad4_Asynchronous_20192502152935.txt'));

load('matlabFunctions/chanlocs16.mat');

num_channels = 16;
eeg = signal(:, 1:num_channels);
eog = signal(:, 17:19);


%% EOG correction??

b = filterEOG(eeg,eog);
% if we want to use EOG corrected version, change eeg_EOGcorrected to eeg
eeg_EOGcorrected = eeg - eog*b; 


%% Temporal and spatial filtering

% write the function for temporal filtering
% I don't know the right order of filtering!temporal --> spatial or vice versa
temporal_filt_eeg = spectral_filtering(eeg, 2, 1, 10);

spatial_filt_eeg = spatial_filtering(eeg, 'CAR');
% spatial_filt_eeg = spatial_filtering(eeg, 'Laplacian', chanlocs16);

temporal_spatial_filt_eeg = spatial_filtering(temporal_filt_eeg, 'CAR');

clean_eeg = temporal_spatial_filt_eeg;

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
    CorrTrials(:, :, idx) = clean_eeg(sampleTrial + eegIdx(corrTrialsIdx(idx)), :); 
end

for idx = 1:length(errTrialsIdx)
    ErrTrials(:, :, idx) = clean_eeg(sampleTrial + eegIdx(errTrialsIdx(idx)), :); 
end


%% CCA spatial filtering 



