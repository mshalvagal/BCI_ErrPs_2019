% Please change this loading part according to your operating system:D

[signal, header] = sload('../data/ad4_20192502/ad4_Asynchronous_20192502152935/ad4_Asynchronous_20192502152935.gdf');

behavior = single(dlmread('../data/ad4_20192502/ad4_Asynchronous_20192502152935/ad4_Asynchronous_20192502152935.txt'));

num_channels = 16;
eeg = signal(:, 1:num_channels);
eog = signal(:, 17:19);
eggTrigger = signal(:, 33);
behavioralTrigger = behavior(:, 2);

eegIdx = find(diff(eggTrigger)) + 1;
eegIdx = eegIdx(eggTrigger(eegIdx) == 3);
behavIdx = find(diff(behavioralTrigger)) + 1;
behavIdx = behavIdx(behavioralTrigger(behavIdx) == 3);
magnitude = behavior(behavIdx, 3);

corrTrialsIdx = find(magnitude==0);
errTrialsIdx = find(magnitude>0);

sampleTrial = -0.5*header.SampleRate:1.0*header.SampleRate;

eegCorrTrials = zeros(length(sampleTrial), num_channels, length(corrTrialsIdx));
eegErrTrials = zeros(length(sampleTrial), num_channels, length(errTrialsIdx));

for idx = 1:length(corrTrialsIdx)
    eegCorrTrials(:, :, idx) = signal(sampleTrial + eegIdx(corrTrialsIdx(idx)), 1:16); 
end

for idx = 1:length(errTrialsIdx)
    eegErrTrials(:, :, idx) = signal(sampleTrial + eegIdx(errTrialsIdx(idx)), 1:16); 
end