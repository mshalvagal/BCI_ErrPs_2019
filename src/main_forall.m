%% Data loading

[raw_data1, raw_calibration_data1] = read_data('data/a7_20191103');
[raw_data2, raw_calibration_data2] = read_data('data/a8_20191103');
[raw_data3, raw_calibration_data3] = read_data('data/b0_20191203');
[raw_data4, raw_calibration_data4] = read_data('data/b3_20191503');
[raw_data5, raw_calibration_data5] = read_data('data/b4_20192603');
rawdata = [raw_data1,raw_data2,raw_data3,raw_data4,raw_data5];
rawcalibrationdata = [raw_calibration_data1,raw_calibration_data2,raw_calibration_data3,raw_calibration_data4,raw_calibration_data5];

%% Setting up preprocessing and training parameters
models_type = [string('LDA'),'diag LDA','diag QDA','SVM','RBF SVM'];
for j = 1:5
    model_type = models_type(j);
    for i = 1:5
        raw_data = rawdata(i);
        raw_calibration_data = rawcalibrationdata(i);
        PreprocessParams.do_eog_correction = true;
        if PreprocessParams.do_eog_correction
            PreprocessParams.calibration_data = raw_calibration_data;
        end
        PreprocessParams.do_temporal_filter = true;
        PreprocessParams.temporal_filter_type = 'butter';
        PreprocessParams.temporal_filter_order = 2;
        PreprocessParams.do_spatial_filter = false;
        PreprocessParams.spatial_filter_type = 'CAR';

        ModelParams.model_type = model_type;
        ModelParams.do_CCA = true;
        ModelParams.do_PCA = false;
        ModelParams.SR = raw_data.header.SampleRate;
        ModelParams.downSR = 64;
        ModelParams.expVarDesired = 99;

        %% Preprocessing
        [preprocessed_data, b_eog] = preprocess_eeg(raw_data, PreprocessParams, false);
        PreprocessParams.b_eog = b_eog;

        Data = offline_epoching(preprocessed_data);

        %% Model evaluation (offline)
        num_folds = 10;
        cp = cvpartition(Data.labels, 'KFold', num_folds);
        mean_metrics = offline_evaluation(Data, ModelParams, cp);
        all_metrics(i) = mean_metrics;
    end
    %overall_mean_metrics.conf_matrix = zeros(2);
    %for x = 1:4
     %   overall_mean_metrics.conf_matrix = overall_mean_metrics.conf_matrix + all_metrics(x).conf_matrix;
    %end 
    overall_mean_metrics.conf_matrix = [all_metrics.conf_matrix];
    overall_mean_metrics.accuracy = [all_metrics.accuracy];
    overall_mean_metrics.mcc = [all_metrics.mcc];
    overall_mean_metrics.tpr = [all_metrics.tpr];
    overall_mean_metrics.fpr = [all_metrics.fpr];
    overall_mean_metrics.auc = [all_metrics.auc];
    overall_mean_metrics.precision = [all_metrics.precision];
    overall_mean_metrics.recall = [all_metrics.recall];
    overall_mean_metrics.fmeasure = [all_metrics.fmeasure];
    models_metrics(j) =  overall_mean_metrics;
end 