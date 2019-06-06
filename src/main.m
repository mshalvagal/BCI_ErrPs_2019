%% Data loading
clear;clc;
[raw_data, raw_calibration_data] = read_data('data/b4_20192603');

%% Setting up preprocessing and training parameters
PreprocessParams.do_eog_correction = true;
if PreprocessParams.do_eog_correction
%     eog_corr_data.eeg = raw_data.signal(:,1:16);
%     eog_corr_data.eog = raw_data.signal(:,17:19);
    PreprocessParams.calibration_data = raw_calibration_data;
end
PreprocessParams.do_temporal_filter = true;
PreprocessParams.temporal_filter_type = 'butter';
PreprocessParams.temporal_filter_order = 2;
PreprocessParams.do_spatial_filter = true;
PreprocessParams.spatial_filter_type = 'Laplacian euclidean';

ModelParams.model_type = 'diag LDA';
ModelParams.do_CCA = true;
ModelParams.do_PCA = false;
ModelParams.SR = raw_data.header.SampleRate;
ModelParams.downSR = 64;
ModelParams.expVarDesired = 90;

%% Preprocessing
[preprocessed_data, b_eog] = preprocess_eeg(raw_data, PreprocessParams, false);
PreprocessParams.b_eog = b_eog;
Data = offline_epoching(preprocessed_data);
%% Model evaluation (offline)
num_folds = 10;
cp = cvpartition(Data.labels, 'KFold', num_folds);
mean_metrics = offline_evaluation(Data, ModelParams, cp);

disp(mean_metrics.conf_matrix)
%% Tuning threshold for online decoding (WARNING: Takes very long) 
[Data_Tune, Data_Test] = split_data(Data);
[online_metrics, OnlineHyperParams] = tune_threshold(Data_Tune, ModelParams, PreprocessParams, raw_data);

%% Model evaluation (online)
% train the model on the whole training dataset
[~, online_classifier] = model_assessment(Data_Tune.eeg_epoched, Data_Tune.labels, Data_Tune.eeg_epoched, Data_Tune.labels, ModelParams);
ModelParams.trained_classifier = online_classifier;

% test the model on untouched test data
[online_final_metrics, Scores, Decoding_Times] = test_online_decoder(Data_Test, raw_data, ModelParams, PreprocessParams, OnlineHyperParams);
save('diag_LDA.mat', 'online_final_metrics', 'online_metrics', 'OnlineHyperParams', 'Scores', 'test_inds', 'tuning_inds', 'Decoding_Times');
