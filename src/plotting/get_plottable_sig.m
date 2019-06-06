function [ Err_grand_average,Corr_grand_average,Data ] = get_plottable_sig( do_CCA,do_t_filt, do_s_filt,s_filt,raw_data, raw_calibration_data,do_eog_correction)
%Nice function that gets correct and error trial with different filtering
% parameters for plotting purpose
PreprocessParams.do_eog_correction = do_eog_correction;
if PreprocessParams.do_eog_correction
    PreprocessParams.calibration_data = raw_calibration_data;
end
PreprocessParams.do_temporal_filter = do_t_filt;
PreprocessParams.temporal_filter_type = 'butter';
PreprocessParams.temporal_filter_order = 2;
PreprocessParams.do_spatial_filter = do_s_filt;
PreprocessParams.spatial_filter_type = s_filt;


%% Preprocessing
[preprocessed_data, b_eog] = preprocess_eeg(raw_data, PreprocessParams, false);
PreprocessParams.b_eog = b_eog;
Data = offline_epoching(preprocessed_data);
Err_trials=Data.eeg_epoched(:,:,Data.labels == 1);
Corr_trials=Data.eeg_epoched(:,:,Data.labels == 0);
       
if(do_CCA)
   [cca_filt,~,~] = CCA(Data.eeg_epoched,Data.labels, Data.eeg_epoched ); 
    Err_trials=cca_filt(:,:,Data.labels == 1);
    Corr_trials=cca_filt(:,:,Data.labels == 0);
    Data.eeg_epoched = cat(3, Err_trials, Corr_trials);
    Data.labels = zeros(size(Data.eeg_epoched, 3), 1);
    Data.labels(1:size(Err_trials, 3)) = 1;
end 


Err_grand_average = mean_per_channel(Err_trials);
Corr_grand_average = mean_per_channel(Corr_trials);

end

