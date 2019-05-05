%% Data loading
[raw_data, raw_calibration_data] = read_data('data/b4_20192603');

%% Setting up preprocessing and training parameters
PreprocessParams.do_eog_correction = true;
if PreprocessParams.do_eog_correction
    PreprocessParams.calibration_data = raw_calibration_data;
end
PreprocessParams.do_temporal_filter = true;
PreprocessParams.temporal_filter_type = 'butter';
PreprocessParams.temporal_filter_order = 2;
PreprocessParams.do_spatial_filter = false;
PreprocessParams.spatial_filter_type = 'CAR';

ModelParams.model_type = 'LDA';
ModelParams.do_CCA = false;
ModelParams.do_PCA = true;
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

%% Model evaluation (online)
online_metrics = online_evaluation(Data, ModelParams, PreprocessParams, raw_data, cp);