function [PCA, train_featuresProcessed, varargout] = feature_extraction(trainData, SR, downSampleRate, expVarDesired, varargin)
    % [featuresProcessed] = extract_features(CorrTrials,header,downSampleRate,expVarDesired)
    %
    % This function takes epoch data as input
    % and takes t = [200,800] ms of each trial and downsamples them in 64Hz, then
    % concatenated to form a vector of features. The feature vectors of all
    % trials were normalized, and then decorrelated using PCA, retaining 95% of the explained variance.

    %% Feature extraction
    % featuresExtracted=zeros(312,length(eegIdx));
    selected_channels = chanselect()
    train_featuresExtracted = [];
    for idx=1:size(trainData, 3)
        temp = trainData(floor(0.7*SR:1.3*SR+1), selected_channels, idx); % selected 8 channels
        hz64 = downsample(temp, SR / downSampleRate); %512/64
        featureVector = [];
        for j=1:length(selected_channels)
            featureVector = [featureVector; hz64(:,j)];
        end
        train_featuresExtracted(:,idx) = featureVector;
    end
    
    if nargin==5
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
    

end
