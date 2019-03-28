function varargout = applyPCA(trainData, expVar, testData)
nOutputs = nargout;
varargout = cell(1,nOutputs);
if nargin==2
    [Z,mu,sigma] = zscore(trainData);
    [coeff, score, ~, ~, explained] = pca(Z);
    index=find(cumsum(explained)>expVar);
    varargout{1} = score(:,1:index(1));
    
else nargin==3
    [Z,mu,sigma] = zscore(trainData);
    [coeff, score, ~, ~, explained] = pca(Z);
    index=find(cumsum(explained)>expVar);
    
    varargout{1} = score(:,1:index(1));
    varargout{2} = (testData-mu)./sigma*coeff(:,1:index(1));
end
end