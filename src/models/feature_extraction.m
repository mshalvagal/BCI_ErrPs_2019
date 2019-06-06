function [PCA, train_featuresProcessed, varargout] = feature_extraction(trainData, trainLabels, SR, downSampleRate, expVarDesired, varargin)
% [featuresProcessed] = extract_features(CorrTrials,header,downSampleRate,expVarDesired)
%
% This function takes epoch data as input
% and takes t = [200,800] ms of each trial and downsamples them in 64Hz, then
% concatenated to form a vector of features. The feature vectors of all
% trials were normalized, and then decorrelated using PCA, retaining 95% of the explained variance.

%% Feature extraction
% featuresExtracted=zeros(312,length(eegIdx));
% eight fronto-central channels (Fz, FC1, FCz, FC2, C1, Cz, C2, and CPz)
% selected_channels = [1 3 4 5 8 9 10 14];
selected_channels = 1:16;

train_featuresExtracted = [];
PCA =[]; 

if expVarDesired ~= -1
    for idx=1:size(trainData, 3)
        temp = trainData(floor(0.7*SR:1.3*SR+1), selected_channels, idx); % selected 8 channels
        hz64 = downsample(temp, SR / downSampleRate); %512/64
        featureVector = [];
        for j=1:length(selected_channels)
            featureVector = [featureVector; hz64(:,j)];
        end
        train_featuresExtracted(:,idx) = featureVector;
    end
    if nargin==6
        testData = varargin{1};
        test_featuresExtracted = [];
        for idx=1:size(testData, 3)
            temp = testData(floor(0.7*SR:1.3*SR+1), selected_channels, idx); % selected 8 channels
            hz64 = downsample(temp, SR / downSampleRate); %512/64
            featureVector = [];
            for j=1:length(selected_channels)
                featureVector = [featureVector; hz64(:,j)];
            end
            test_featuresExtracted(:,idx) = featureVector;
        end
        
        [PCA, train_featuresProcessed, test_featuresProcessed] = applyPCA(train_featuresExtracted', expVarDesired, test_featuresExtracted');
        varargout{1} = test_featuresProcessed;
    else
        [PCA, train_featuresProcessed] = applyPCA(train_featuresExtracted', expVarDesired);
    end
else
    for idx=1:size(trainData, 3)
        temp = trainData(floor(0.7*SR:1.3*SR+1), selected_channels, idx); % selected 8 channels
        hz64 = downsample(temp, SR / downSampleRate); %512/64
        featureVector = [];
        for j=1:length(selected_channels)
            featureVector = [featureVector; hz64(:,j)];
        end
        train_featuresExtracted(:,idx) = featureVector;
    end
    if nargin==6
        testData = varargin{1};
        test_featuresExtracted = [];
        for idx=1:size(testData, 3)
            temp = testData(floor(0.7*SR:1.3*SR+1), selected_channels, idx); % selected 8 channels
            hz64 = downsample(temp, SR / downSampleRate); %512/64
            featureVector = [];
            for j=1:length(selected_channels)
                featureVector = [featureVector; hz64(:,j)];
            end
            test_featuresExtracted(:,idx) = featureVector;
        end
        
        [orderedInd, orderedPower] = rankfeat(train_featuresExtracted', trainLabels, 'fisher');
        idx = find(orderedPower<0.01, 1, 'first');
        
        varargout{1} = test_featuresExtracted(orderedInd(1:idx),:)';
        varargout{2} = orderedInd(1:idx);
        train_featuresProcessed = train_featuresExtracted(orderedInd(1:idx),:)';
    else
        [orderedInd, orderedPower] = rankfeat(train_featuresExtracted', trainLabels, 'fisher');
        idx = find(orderedPower<0.01, 1, 'first');
        train_featuresProcessed = train_featuresExtracted(orderedInd(1:idx),:)';
        varargout{1} = [];
        varargout{2} = orderedInd(1:idx);
    end
end
end
