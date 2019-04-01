function [featuresProcessed] = feature_extraction(temporal_spatial_filt_eeg,eegIdx,header,expVarDesired)
% [featuresProcessed] = extract_features(temporal_spatial_filt_eeg,eegIdx,header,expVarDesired)
%
% This function takes temporally and spatially filtered EEG signal as input
% and takes t = [200,800] ms of each trial and downsamples them in 64Hz, then
% concatenated to form a vector of 312 features. The feature vectors of all
% trials were normalized, and then decorrelated using PCA, retaining 95% of the explained variance.

featureVector=[];featuresExtracted=zeros(312,length(eegIdx));
% eight fronto-central channels (Fz, FC1, FCz, FC2, C1, Cz, C2, and CPz)
selected_channels=[1 3 4 5 8 9 10 14];
for idx=1:length(eegIdx)
    temp=temporal_spatial_filt_eeg(floor(0.7*header.SampleRate:1.3*header.SampleRate+1) + eegIdx(idx),selected_channels); % selected 8 channels
    hz64=downsample(temp,header.SampleRate/64); %512/64
    featureVector=[];
    for j=1:length(selected_channels)
        featureVector = [featureVector; hz64(:,j)];
    end
    featuresExtracted(:,idx)=featureVector;
end

[featuresProcessed] = applyPCA(featuresExtracted', expVarDesired); 

end
