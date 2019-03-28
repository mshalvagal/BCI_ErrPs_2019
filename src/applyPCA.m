function [trainProjected, testProjected] = applyPCA(trainData, testData, expVar)

[Z,mu,sigma] = zscore(trainData);
[coeff, score, ~, ~, explained] = pca(Z);
index=find(cumsum(explained)>expVar);
trainProjected = score(:,1:index(1));
testProjected = (testData-mu)./sigma*coeff(:,1:index(1));

end