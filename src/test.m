[Trials, Labels, header] = preprocess_eeg('data/a7_20191103', true, false);
k = 10;
SR = header.SampleRate;

N = size(Trials, 3);
    
%     cp = cvpartition(Labels, 'KFold', k, 'Stratify', true);
    cp = cvpartition(N, 'KFold', k);
    
    for i=1:k
        train_set = Trials(:, : ,cp.training(i));
        test_set = Trials(:, :, cp.test(i));
        train_labels = Labels(cp.training(i));
        test_labels = Labels(cp.test(i));
       
        
         downSR = 64;
         expVarDesired = 95;
         [train_set_CCA, test_set_CCA] = CCA(train_set, train_labels, test_set);
        [train_XCCA, test_XCCA] = feature_extraction(train_set_CCA, test_set_CCA, SR, downSR, expVarDesired);
        [train_X, test_X] = feature_extraction(train_set, test_set, SR, downSR, expVarDesired);
        if (i == 1) 
            plot(train_XCCA(:,1));
            hold on;
            plot(test_XCCA(:,1))
        end 
        
%         temp = permute(train_set, [3,2,1]);
%         train_X = reshape(temp, size(temp, 1), size(temp, 2) * size(temp, 3));
%         test_X = reshape(temp, size(temp, 1), size(temp, 2) * size(temp, 3));
        Model = fitcsvm(train_X,train_labels,'KernelFunction','rbf');
        predictions = Model.predict(test_X);
        
        
        percent_corrects(i) = mean(predictions == test_labels);
        confusion_matrices(:, :, i) = confusionmat(test_labels, predictions);
        
        
    end
        