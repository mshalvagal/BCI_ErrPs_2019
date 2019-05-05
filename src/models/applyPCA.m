function varargout = applyPCA(trainData, expVar, testData)
    % varargout = applyPCA(trainData, expVar, testData)
    % Two versions of applyPCA: - 2 input (trainData, expVar), 1 output [trainFeatures]
    %                           - 3 input (trainData, expVar,testData), 2 output [trainFeatures,testFeatures]
    % expVar -> the explained variance percentage that you want to have
    % For trainData, testData -> rows are observations, columns are features.

    nOutputs = nargout;
    varargout = cell(1,nOutputs);
    if nargin==2
    %     [Z,mu,sigma] = zscore(trainData);
    %     Z = trainData - mean(trainData);
        [coeff, score, ~, ~, explained, mu] = pca(trainData);
        index = find(cumsum(explained)>=expVar);
        PCA.PCs = coeff(:, 1:index(1));
        PCA.mu = mu;
        varargout{1} = PCA;
        varargout{2} = score(:,1:index(1));

    elseif nargin==3
    %     [Z,mu,sigma] = zscore(trainData);
    %     Z = trainData - mean(trainData);
        [coeff, score, ~, ~, explained, mu] = pca(trainData);
        index = find(cumsum(explained)>=expVar);
        PCA.PCs = coeff(:, 1:index(1));
        PCA.mu = mu;
        varargout{1} = PCA;
        varargout{2} = score(:, 1:index(1));
        varargout{3} = (testData - repmat(mu, [size(testData, 1), 1])) * coeff(:, 1:index(1));
    end
end