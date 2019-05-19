function [metrics, classifier] = model_assessment(train_set, train_labels, test_set, test_labels, model_params)
    % This functions gets the correct and error trials and performs 'k'-fold cross-validation 
    % on the 'model'
    
    if model_params.do_CCA
        [train_set, test_set, W] = CCA(train_set, train_labels, test_set);
        classifier.CCA_W = W;
    end

    if model_params.do_PCA
        [PCA, train_X, test_X] = feature_extraction(train_set, model_params.SR, model_params.downSR, model_params.expVarDesired, test_set);
        classifier.PCA = PCA;
    else
        temp = permute(train_set, [3,2,1]);
        train_X = reshape(temp, size(temp, 1), size(temp, 2) * size(temp, 3));
        temp = permute(test_set, [3,2,1]);
        test_X = reshape(temp, size(temp, 1), size(temp, 2) * size(temp, 3));
    end

    if strcmp(model_params.model_type, 'LDA')
        Model = fitcdiscr(train_X, train_labels);
        predictions = Model.predict(test_X);
        [~, scores] = resubPredict(Model);
    end
    if strcmp(model_params.model_type, 'diag LDA')
        Model = fitcdiscr(train_X, train_labels,'DiscrimType','diaglinear');
        predictions = Model.predict(test_X);
        [~, scores] = resubPredict(Model);
    end
    if strcmp(model_params.model_type, 'diag QDA')
        Model = fitcdiscr(train_X, train_labels,'DiscrimType','diagquadratic');
        predictions = Model.predict(test_X);
        [~, scores] = resubPredict(Model);
    end
    if strcmp(model_params.model_type, 'SVM')
        c=[0 1;2.17 0];
        Model = fitcsvm(train_X, train_labels,'Cost',c);
        predictions = Model.predict(test_X);
        [~, scores] = resubPredict(Model);
    end
    if strcmp(model_params.model_type, 'RBF SVM')
        c=[0 1;2.17 0];
        Model = fitcsvm(train_X, train_labels,'KernelFunction','RBF','Cost',c);
        predictions = Model.predict(test_X);
        [~, scores] = resubPredict(Model);
    end
    if strcmp(model_params.model_type, 'RF')
    Model = TreeBagger(100,train_X,train_labels,'OOBPred','On','Method','classification');
    predictions = str2num(cell2mat(Model.predict(test_X)));
    scores = zeros(length(train_labels),2);
    end 
    percent_correct = mean(predictions == test_labels);
    confusion_matrix = confusionmat(test_labels, predictions);
    
    metrics = p_metrics(confusion_matrix,train_labels,scores(:,1));
    metrics.accuracy = percent_correct;
    metrics.confusion_matrix = confusion_matrix;
    
    classifier.model = Model;
end