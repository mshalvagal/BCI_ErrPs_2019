function mean_metrics = offline_evaluation(Data, ModelParams, cp)
%OFFLINE_EVALUATION Summary of this function goes here
%   Detailed explanation goes here
    Trials = Data.eeg_epoched;
    Labels = Data.labels;

    N = size(Trials, 3);
    %cp = cvpartition(N, 'KFold', num_folds);

    for i=1:cp.NumTestSets
        train_set = Trials(:, : ,cp.training(i));
        test_set = Trials(:, :, cp.test(i));
        train_labels = Labels(cp.training(i));
        test_labels = Labels(cp.test(i));

        [metrics, ~] = model_assessment(train_set, train_labels, test_set, test_labels, ModelParams);

        confusion_matrices(:,:,i) = metrics.confusion_matrix;
        vect_metrics(i) = metrics;
    end

    % get mean value of all metrics :
    mean_metrics.accuracy = nanmean([vect_metrics.accuracy]);
    mean_metrics.conf_matrix = sum(confusion_matrices,3);
    mean_metrics.mcc = nanmean([vect_metrics.mcc]);
    mean_metrics.tpr = nanmean([vect_metrics.tpr]);
    mean_metrics.fpr = nanmean([vect_metrics.fpr]);
    mean_metrics.auc = nanmean([vect_metrics.auc]);
    mean_metrics.precision = nanmean([vect_metrics.precision]);
    mean_metrics.recall = nanmean([vect_metrics.recall]);
    mean_metrics.fmeasure = nanmean([vect_metrics.fmeasure]);
end

