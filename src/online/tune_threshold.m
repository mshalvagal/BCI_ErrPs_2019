function [online_metrics, OnlineHyperParams] = tune_threshold(Data_Tune, ModelParams, PreprocessParams, raw_data)
    % run a cross validation to determine the hyperparameters(threshold & window)
    num_folds = 9;
    cp = cvpartition(Data_Tune.labels, 'KFold', num_folds);

    thresholds = [0.05, 0.1, 0.15, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8];
    OnlineHyperParams.window = 5;   

    for i=1:length(thresholds)
        OnlineHyperParams.threshold = thresholds(i);
        online_metrics(i) = online_evaluation(Data_Tune, ModelParams, PreprocessParams, raw_data, cp, OnlineHyperParams);
    end
end
