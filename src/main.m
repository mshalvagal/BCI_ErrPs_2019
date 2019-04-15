%% Data loading

[Trials, Labels, header] = preprocess_eeg('data/a7_20191103');
% [X_test, y_test] = preprocess_eeg('data/b3_20191503', false);

%% Model evaluation
N = size(Trials, 3);
num_folds = 5;

cp = cvpartition(Labels, 'KFold', num_folds, 'Stratify', true);
% cp = cvpartition(N, 'KFold', k);

for i=1:num_folds
    train_set = Trials(:, : ,cp.training(i));
    test_set = Trials(:, :, cp.test(i));
    train_labels = Labels(cp.training(i));
    test_labels = Labels(cp.test(i));
    
    [confusion_matrix, percent_correct] = model_assessment(train_set, train_labels, test_set, test_labels, header.SampleRate, 'LDA', false, true, 64, 99);
    
    accuracies(i) = percent_correct;
    confusion_matrices(:,:,i) = confusion_matrix;
end
