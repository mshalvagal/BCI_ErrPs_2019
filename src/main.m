%% Data loading

[Trials, Labels, header] = preprocess_eeg('data/a7_20191103');
% [X_test, y_test] = preprocess_eeg('data/b3_20191503', false);

%% Model evaluation
N = size(Trials, 3);
num_folds = 5;

cp = cvpartition(Labels, 'KFold', num_folds);
%cp = cvpartition(N, 'KFold', num_folds);

for i=1:num_folds
    train_set = Trials(:, : ,cp.training(i));
    test_set = Trials(:, :, cp.test(i));
    train_labels = Labels(cp.training(i));
    test_labels = Labels(cp.test(i));
    
    [confusion_matrix, percent_correct,metrics] = model_assessment(train_set, train_labels, test_set, test_labels, header.SampleRate, 'LDA', false, true, 64, 99);
    
    accuracies(i) = percent_correct;
    confusion_matrices(:,:,i) = confusion_matrix;
    vect_metrics(i) = metrics;
end
% get mean value of all metrics :
mean_metrics.accuracy = mean(accuracies);
mean_metrics.conf_matrix = mean(confusion_matrices,3);
mean_metrics.mcc = nanmean([vect_metrics.mcc]);
mean_metrics.tpr = nanmean([vect_metrics.tpr]);
mean_metrics.fpr = nanmean([vect_metrics.fpr]);
mean_metrics.auc = nanmean([vect_metrics.auc]);
mean_metrics.precision = nanmean([vect_metrics.precision]);
mean_metrics.recall = nanmean([vect_metrics.recall]);
mean_metrics.fmeasure = nanmean([vect_metrics.fmeasure]);

