function [mean_metrics] = tryDifferent(do_eog_correction, do_temporal_filter,do_spatial_filter,model_type,do_CCA,do_PCA)
%% Data loading
[raw_data, raw_calibration_data] = read_data('data/ad4_20192502');

%% Setting up preprocessing and training parameters
PreprocessParams.do_eog_correction = do_eog_correction;
if PreprocessParams.do_eog_correction
    PreprocessParams.calibration_data = raw_calibration_data;
end
PreprocessParams.do_temporal_filter = do_temporal_filter;
PreprocessParams.do_spatial_filter = do_spatial_filter;
ModelParams.model_type = model_type;
ModelParams.do_CCA = do_CCA;
ModelParams.do_PCA = do_PCA;

PreprocessParams.spatial_filter_type = 'CAR';
PreprocessParams.temporal_filter_type = 'butter';
PreprocessParams.temporal_filter_order = 2;
ModelParams.SR = raw_data.header.SampleRate;
ModelParams.downSR = 64;
ModelParams.expVarDesired = 99;

%% Preprocessing
[preprocessed_data, b_eog] = preprocess_eeg(raw_data, PreprocessParams, false);
PreprocessParams.b_eog = b_eog;

Data = offline_epoching(preprocessed_data);

%% Model evaluation (offline)
num_folds = 5;
cp = cvpartition(Data.labels, 'KFold', num_folds);
mean_metrics = offline_evaluation(Data, ModelParams, cp);

disp(mean_metrics.conf_matrix)

% %% Model evaluation (online)
% online_metrics = online_evaluation(Data, ModelParams, PreprocessParams, raw_data, cp);
end