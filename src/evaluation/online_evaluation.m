function mean_metrics = online_evaluation(Data, ModelParams, PreprocessParams, raw_data, cp)
%ONLINE_EVALUATION Summary of this function goes here
%   Detailed explanation goes here
    num_channels = 16;
    
    Trials = Data.eeg_epoched;
    Labels = Data.labels;

    N = size(Trials, 3);
    %cp = cvpartition(N, 'KFold', num_folds);

    for i=1:cp.NumTestSets
        train_set = Trials(:, : ,cp.training(i));
        train_labels = Labels(cp.training(i));
        
        test_set = Trials(:, :, cp.test(i));
        test_labels = Labels(cp.test(i));

        [~, classifier] = model_assessment(train_set, train_labels, test_set, test_labels, ModelParams);
        ModelParams.trained_classifier = classifier;
        
        % Online decoding of the test data
        % go over the test data one by one
        test_set_starts = Data.fullIdxStart(cp.test(i));
        test_set_ends = Data.fullIdxEnd(cp.test(i));
        
        for j=1:cp.TestSize(i)
            signal = raw_data.signal(test_set_starts(j):test_set_ends(j), :);

            % sliding window
            window_size = floor(600 * 10^-3 * ModelParams.SR) + 1;    % samples
            step_size = 16;     % samples

            start_ind = 1;
            k = 1;
            while start_ind + window_size < size(signal, 1)
                end_ind = start_ind + window_size;
                
                Signal_windowed.signal = signal(start_ind:end_ind, :);
                Signal_windowed.SampleRate = ModelParams.SR;

                label(k) = online_decoder(Signal_windowed, PreprocessParams, ModelParams);
                
                k = k + 1;
                start_ind = end_ind + 1;
            end
        % TODO: Evaluate the online labels
        end
    end

    % get mean value of all metrics :
    mean_metrics.accuracy = mean(accuracies);
    mean_metrics.conf_matrix = sum(confusion_matrices,3);
    mean_metrics.mcc = nanmean([vect_metrics.mcc]);
    mean_metrics.tpr = nanmean([vect_metrics.tpr]);
    mean_metrics.fpr = nanmean([vect_metrics.fpr]);
    mean_metrics.auc = nanmean([vect_metrics.auc]);
    mean_metrics.precision = nanmean([vect_metrics.precision]);
    mean_metrics.recall = nanmean([vect_metrics.recall]);
    mean_metrics.fmeasure = nanmean([vect_metrics.fmeasure]);
end

