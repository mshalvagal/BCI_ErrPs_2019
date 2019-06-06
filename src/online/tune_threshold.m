function [online_metrics, OnlineHyperParams] = tune_threshold(Data_Tune, ModelParams, PreprocessParams, raw_data)
    % run a cross validation to determine the hyperparameters(threshold & window)
    num_folds = 5;
    cp = cvpartition(Data_Tune.labels, 'KFold', num_folds);

    thresholds = [0.1, 0.3, 0.5, 0.7];
    OnlineHyperParams.window = 5;   

    for i=1:length(thresholds)
        disp(i);
        OnlineHyperParams.threshold = thresholds(i);
        online_metrics(i) = online_evaluation(Data_Tune, ModelParams, PreprocessParams, raw_data, cp, OnlineHyperParams);
    end
    
    [~, best_thresh_ind] = max(extractfield(online_metrics, 'mcc'));
    OnlineHyperParams.threshold = thresholds(best_thresh_ind);
end
