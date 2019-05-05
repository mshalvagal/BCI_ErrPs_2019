function [confusion_matrix, percent_correct, metrics ] = model_assessment(train_set, train_labels, test_set, test_labels, SR, model_type, do_CCA, do_PCA, downSR, expVarDesired)
    % This functions gets the correct and error trials and performs 'k'-fold cross-validation 
    % on the 'model'
    
    if do_CCA
        [train_set, test_set] = CCA(train_set, train_labels, test_set);
    end

%    downSR = 64;
%    expVarDesired = 95;
    if do_PCA
        [PCA, train_X, test_X] = feature_extraction(train_set, SR, downSR, expVarDesired, test_set);
    else
        temp = permute(train_set, [3,2,1]);
        train_X = reshape(temp, size(temp, 1), size(temp, 2) * size(temp, 3));
        temp = permute(test_set, [3,2,1]);
        test_X = reshape(temp, size(temp, 1), size(temp, 2) * size(temp, 3));
    end

    if strcmp(model_type, 'LDA')
        Model = fitcdiscr(train_X, train_labels);
        predictions = Model.predict(test_X);
        [~, scores] = resubPredict(Model);
    end
    percent_correct = mean(predictions == test_labels);
    confusion_matrix = confusionmat(test_labels, predictions);
    metrics = p_metrics(confusion_matrix,train_labels,scores(:,1))
end