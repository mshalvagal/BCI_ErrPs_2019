7%% Feature extraction
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

[projected] = applyPCA(featuresExtracted', 95); 
