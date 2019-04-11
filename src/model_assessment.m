function [confusion_matrices, percent_corrects] = model_assessment(Trials, Labels, SR, k, model_type, do_CCA, downSR, expVarDesired)
    % This functions gets the correct and error trials and performs 'k'-fold cross-validation 
    % on the 'model'
    
    N = size(Trials, 3);
    
    cp = cvpartition(Labels, 'KFold', k, 'Stratify', true);
    
    for i=1:k
        train_set = Trials(:, : ,cp.training(i));
        test_set = Trials(:, :, cp.test(i));
        train_labels = Labels(cp.training(i));
        test_labels = Labels(cp.test(i));
        
        if do_CCA
            [train_set, test_set] = CCA(train_set, train_labels, test_set);
        end
        
%         downSR = 64;
%         expVarDesired = 95;
        [train_X, test_X] = feature_extraction(train_set, test_set, SR, downSR, expVarDesired);
        
        if strcmp(model_type, 'LDA')
            Model = fitcdiscr(train_X, train_labels);
            predictions = Model.predict(test_X);
        end
        
        percent_corrects(i) = mean(predictions == test_labels);
        confusion_matrices(:, :, i) = confusionmat(train_labels, predictions);
        
    end
        
        
end