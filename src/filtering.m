
[b, a] = butter(2, [1 10]/256);

filteredEEGCorrTrials = filtfilt(b, a, eegCorrTrials);
filteredEEGErrTrials = filtfilt(b, a, eegErrTrials);

% plot(eegCorrTrials(:,1,1))
% hold on
% plot(filteredEEGCorrTrials(:,1,1))

grandEEGCorrSpectral = mean(filteredEEGCorrTrials, 3);
grandEEGErrSpectral = mean(filteredEEGErrTrials, 3);