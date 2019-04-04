function [featuresProcessed] = feature_extraction(CorrTrials,ErrTrials,header,downSampleRate, expVarDesired)
% [featuresProcessed] = extract_features(CorrTrials,header,downSampleRate,expVarDesired)
%
% This function takes epoch data as input
% and takes t = [200,800] ms of each trial and downsamples them in 64Hz, then
% concatenated to form a vector of features. The feature vectors of all
% trials were normalized, and then decorrelated using PCA, retaining 95% of the explained variance.

%% Feature extraction
featureVector=[];%featuresExtracted=zeros(312,length(eegIdx));
signal=cat(3,CorrTrials,ErrTrials);
% eight fronto-central channels (Fz, FC1, FCz, FC2, C1, Cz, C2, and CPz)
selected_channels=[1 3 4 5 8 9 10 14];
for idx=1:size(signal,3)
    temp=signal(floor(0.7*header.SampleRate:1.3*header.SampleRate+1),selected_channels,idx); % selected 8 channels
    hz64=downsample(temp,header.SampleRate/downSampleRate); %512/64
    featureVector=[];
    for j=1:length(selected_channels)
        featureVector = [featureVector; hz64(:,j)];
    end
    featuresExtracted(:,idx)=featureVector;
end

[featuresProcessed] = applyPCA(featuresExtracted', expVarDesired); 

end
