function varargout = applyPCA(trainData, expVar, testData)
% varargout = applyPCA(trainData, expVar, testData)
% Two versions of applyPCA: - 2 input (trainData, expVar), 1 output [trainFeatures]
%                           - 3 input (trainData, expVar,testData), 2 output [trainFeatures,testFeatures]
% expVar -> the explained variance percentage that you want to have
% For trainData, testData -> rows are observations, columns are features.

nOutputs = nargout;
varargout = cell(1,nOutputs);
if nargin==2
    %[Z,mu,sigma] = zscore(trainData);
    Z=trainData-mean(trainData);
    [coeff, score, ~, ~, explained] = pca(Z);
    index=find(cumsum(explained)>=expVar);
    varargout{1} = score(:,1:index(1));
    
else nargin==3
    %[Z,mu,sigma] = zscore(trainData);
    Z=trainData-mean(trainData);
    [coeff, score, ~, ~, explained] = pca(Z);
    index=find(cumsum(explained)>=expVar);
    
    varargout{1} = score(:,1:index(1));
    varargout{2} = (testData-mean(trainData))*coeff(:,1:index(1));
end
end