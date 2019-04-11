[Trials, Labels, header] = preprocess_eeg('data/b3_20191503', true, false);
% [X_test, y_test] = preprocess_eeg('data/b3_20191503', false);

[confusion_matrices, percent_corrects] = model_assessment(Trials, Labels, header.SampleRate, 5, 'LDA', true, 64, 99);

