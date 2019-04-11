function [confusion_matrices, percent_corrects] = model_assessment(Trials, Labels, SR, k, model_type, do_CCA, downSR, expVarDesired)
    % This functions gets the correct and error trials and performs 'k'-fold cross-validation 
    % on the 'model'
    
    N = size(Trials, 3);
    
%     cp = cvpartition(Labels, 'KFold', k, 'Stratify', true);
    cp = cvpartition(N, 'KFold', k);
    
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
%         [train_X, test_X] = feature_extraction(train_set, test_set, SR, downSR, expVarDesired);
        
        temp = permute(train_set, [3,2,1]);
        train_X = reshape(temp, size(temp, 1), size(temp, 2) * size(temp, 3));
        temp = permute(test_set, [3,2,1]);
        test_X = reshape(temp, size(temp, 1), size(temp, 2) * size(temp, 3));
        
        if strcmp(model_type, 'LDA')
            Model = fitcdiscr(train_X, train_labels);
            predictions = Model.predict(test_X);
        end
        
        percent_corrects(i) = mean(predictions == test_labels);
        confusion_matrices(:, :, i) = confusionmat(test_labels, predictions);
        
    end
        
        
end