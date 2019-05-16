%% Data loading

[raw_data1, raw_calibration_data1] = read_data('data/a7_20191103');
[raw_data2, raw_calibration_data2] = read_data('data/a8_20191103');
[raw_data3, raw_calibration_data3] = read_data('data/b0_20191203');
[raw_data4, raw_calibration_data4] = read_data('data/b3_20191503');

%% Setting up preprocessing and training parameters
PreprocessParams.do_eog_correction = true;
if PreprocessParams.do_eog_correction
    PreprocessParams.calibration_data = raw_calibration_data;
end
PreprocessParams.do_temporal_filter = true;
PreprocessParams.temporal_filter_type = 'butter';
PreprocessParams.temporal_filter_order = 2;
PreprocessParams.do_spatial_filter = false;
PreprocessParams.spatial_filter_type = 'CCA';

ModelParams.model_type = 'RBF SVM';
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
%online_metrics = online_evaluation(Data, ModelParams, PreprocessParams, raw_data, cp);