%% Data loading
[raw_data, raw_calibration_data] = read_data('data/b0_20191203');
%[raw_data, raw_calibration_data] = read_data('data/a7_20191103');
%[raw_data, raw_calibration_data] = read_data('data/a8_20191103');
%[raw_data, raw_calibration_data] = read_data('data/b0_20191203');
%% Get grand average of correct and error trials 
do_CCA = false;
do_t_filt = true;
do_s_filt = false;
s_filt = 'Laplacian euclidean';
[ Err_grand_average,Corr_grand_average ] = get_plottable_sig( do_CCA,do_t_filt, do_s_filt,s_filt,raw_data, raw_calibration_data);
%% Pretty plotted filtering results
figure(2)
% do an unfiltered version to compare 
[ unfilt_Err_grand_average,unfilt_Corr_grand_average ] = get_plottable_sig( false,false, false,s_filt,raw_data, raw_calibration_data);
shadedErrorBar([1:769],mean(Err_grand_average,2),std(Err_grand_average,0,2))
hold on 
shadedErrorBar([1:769],mean(unfilt_Err_grand_average,2),std(unfilt_Err_grand_average,0,2),'-b')

%% Topoplot at points around the peak 
load('matlabFunctions/chanlocs16.mat');
[~, peak_time] = max(Err_grand_average(:,4));
% get the average for a window around the peak time
window = 5;
% Do the topoplot on a mean for 3 time point : 200 before the peak, at peak, 200 after  
figure('Name','no filtering for 2');
subplot(2,3,1)
[Errhandle, ErrZi, Errgrid, ErrXi, ErrYi] = topoplot(mean(Err_grand_average(peak_time-window-100:peak_time+window-100, :),1), chanlocs16);
title('Error trials before EEG peak')
subplot(2,3,2)
[Errhandle, ErrZi, Errgrid, ErrXi, ErrYi] = topoplot(mean(Err_grand_average(peak_time-window:peak_time+window, :),1), chanlocs16);
title('at EEG peak')
subplot(2,3,3)
[Errhandle, ErrZi, Errgrid, ErrXi, ErrYi] = topoplot(mean(Err_grand_average(peak_time-window + 100:peak_time+window + 100, :),1), chanlocs16);
title('after EEG peak')


subplot(2,3,4)
[Errhandle, ErrZi, Errgrid, ErrXi, ErrYi] = topoplot(mean(Corr_grand_average(peak_time-window-100:peak_time+window-100, :),1), chanlocs16);
title('Correct trials before EEG peak')

subplot(2,3,5)
[Errhandle, ErrZi, Errgrid, ErrXi, ErrYi] = topoplot(mean(Corr_grand_average(peak_time-window:peak_time+window, :),1), chanlocs16);
title('at EEG peak')

subplot(2,3,6)
[Errhandle, ErrZi, Errgrid, ErrXi, ErrYi] = topoplot(mean(Corr_grand_average(peak_time-window + 100:peak_time+window + 100, :),1), chanlocs16);
title('after EEG peak')

%% Check that their is no contaminated electrods 
[raw_data1, raw_calibration_data1] = read_data('data/a7_20191103');
[raw_data2, raw_calibration_data2] = read_data('data/a8_20191103');
[raw_data3, raw_calibration_data3] = read_data('data/b0_20191203');
[raw_data4, raw_calibration_data4] = read_data('data/b3_20191503');
rawdata = [raw_data1,raw_data2,raw_data3,raw_data4];
rawcalibrationdata = [raw_calibration_data1,raw_calibration_data2,raw_calibration_data3,raw_calibration_data4];
load('matlabFunctions/chanlocs16.mat');
before_rot_onset = -0.5;
after_rot_onset = 1;
do_CCA = false;
PreprocessParams.do_eog_correction = true;
if PreprocessParams.do_eog_correction
    PreprocessParams.calibration_data = raw_calibration_data;
end
PreprocessParams.do_temporal_filter = true;
PreprocessParams.temporal_filter_type = 'butter';
PreprocessParams.temporal_filter_order = 2;
PreprocessParams.do_spatial_filter = false;
PreprocessParams.spatial_filter_type = 'Laplacian euclidean';
figure('Name','average topoplot over 30 seconds per subject for correct trials ' );
for i = 1:4
        raw_data = rawdata(i);
        raw_calibration_data = rawcalibrationdata(i);
        [preprocessed_data, b_eog] = preprocess_eeg(raw_data, PreprocessParams, false);
        PreprocessParams.b_eog = b_eog;
        Data = offline_epoching(preprocessed_data);
        Err_trials=Data.eeg_epoched(:,:,Data.labels == 1);
        Corr_trials=Data.eeg_epoched(:,:,Data.labels == 0);
        Err_grand_average = mean_per_channel(Err_trials);
        Corr_grand_average = mean_per_channel(Corr_trials);
        [~, peak_time] = max(sum(Err_grand_average,2));
        subplot(2,2,i)
        [Errhandle, ErrZi, Errgrid, ErrXi, ErrYi] = topoplot(mean(Corr_grand_average(1:31, :),1), chanlocs16);
end 