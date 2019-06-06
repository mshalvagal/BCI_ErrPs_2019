function [Data_Tune, Data_Test] = split_data(Data)
    % Separate 1/10 of data as test
    inds = randperm(size(Data.eeg_epoched, 3));
    test_inds = inds(1:floor(size(Data.eeg_epoched, 3)/10));
    tuning_inds = inds((floor(size(Data.eeg_epoched, 3)/10)+1):end);

    Data_Tune.N_Test = length(tuning_inds);
    Data_Tune.eeg_epoched = Data.eeg_epoched(:,:,tuning_inds);
    Data_Tune.labels = Data.labels(tuning_inds);
%     Data_Tune.Signal = raw_data.signal;
    Data_Tune.fullIdxStart = Data.fullIdxStart(tuning_inds);
    Data_Tune.fullIdxEnd = Data.fullIdxEnd(tuning_inds);
    Data_Tune.triggerOnset = Data.triggerOnset(tuning_inds);

    Data_Test.N_Test = length(test_inds);
%     Data_Test.Signal = raw_data.signal;
    Data_Test.labels = Data.labels(test_inds);
    Data_Test.fullIdxStart = Data.fullIdxStart(test_inds);
    Data_Test.fullIdxEnd = Data.fullIdxEnd(test_inds);
    Data_Test.triggerOnset = Data.triggerOnset(test_inds);
end