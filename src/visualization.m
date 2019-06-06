%% Error vs Correct trials
load('matlabFunctions/chanlocs16.mat');
before_rot_onset = -0.5;
after_rot_onset = 1;

% We need to add baseline correction either here or after grand average
baseline_corrected_ErrTrials = baseline_correction(ErrTrials, 50);
baseline_corrected_CorrTrials = baseline_correction(CorrTrials, 50);

[baseline_corrected_Err_grand_average, baseline_corrected_Err_grand_std] = mean_per_channel(baseline_corrected_ErrTrials);
[baseline_corrected_Corr_grand_average, baseline_corrected_Corr_grand_std] = mean_per_channel(baseline_corrected_CorrTrials);
Err_grand_average = mean_per_channel(ErrTrials);
Corr_grand_average = mean_per_channel(CorrTrials);

selected_channels = [1 3 4 5 8 9 10 14];

% figure(1);
% T = before_rot_onset:1/header.SampleRate:after_rot_onset;
% for i = 1:numel(selected_channels)
%     subplot(4, 2, i);
%     % we should put the function with error bars here instead of plot!
%     plot(T, baseline_corrected_Err_grand_average(:, selected_channels(i)));hold on;
%     plot(T, baseline_corrected_Corr_grand_average(:, selected_channels(i)));
%     
%     fill([T fliplr(T)], [baseline_corrected_Err_grand_average(:, selected_channels(i))' + 0.1*baseline_corrected_Err_grand_std(:, selected_channels(i))' fliplr(baseline_corrected_Err_grand_average(:, i)' - 0.1*baseline_corrected_Err_grand_std(:, selected_channels(i))')], [.0 .0 .9], 'linestyle', 'none')
%     alpha(.25);
%     fill([T fliplr(T)], [baseline_corrected_Corr_grand_average(:, selected_channels(i))' + 0.1*baseline_corrected_Corr_grand_std(:, selected_channels(i))' fliplr(baseline_corrected_Corr_grand_average(:, selected_channels(i))' - 0.1*baseline_corrected_Corr_grand_std(:, i)')], [.9 .0 .0], 'linestyle', 'none')
%     alpha(.25);
%     
%     xlabel('Time[s]');ylabel('Amplitude[\mu V]');title(chanlocs16(selected_channels(i)).labels);
% end

% I don't know what do we mean by peak because we have 16 channels!which
% one?
% peak_time = 0.5 * header.SampleRate;
[~, peak_time] = max(Err_grand_average(:,4));
figure(2);
% Do the topoplot on a mean 
[Errhandle, ErrZi, Errgrid, ErrXi, ErrYi] = topoplot(Err_grand_average(peak_time, :), chanlocs16);
figure(3);
[Corrhandle, CorrZi, Corrgrid, CorrXi, CorrYi] = topoplot(Corr_grand_average(peak_time, :), chanlocs16);

%% EOG correction
figure(4);
plot(eeg_EOGcorrected(:,8));hold on;
plot(eeg(:,8));
legend('corrected','non-corrected');

%% CCA 
figure(5);
err_mean = mean(CCA_err,3);
plot(err_mean(:,1));
hold on;
unfilt_mean = mean(ErrTrials,3);
plot(unfilt_mean(:,1));
legend('CCA filtered','unfiltered')
