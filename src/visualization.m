%% Error vs Correct trials

% We need to add baseline correction either here or after grand average
baseline_corrected_ErrTrials = baseline_correction(ErrTrials, 50);
baseline_corrected_CorrTrials = baseline_correction(CorrTrials, 50);

baseline_corrected_Err_grand_average = mean_per_channel(baseline_corrected_ErrTrials);
baseline_corrected_Corr_grand_average = mean_per_channel(baseline_corrected_CorrTrials);
Err_grand_average = mean_per_channel(ErrTrials);
Corr_grand_average = mean_per_channel(CorrTrials);

figure(1);
T = before_rot_onset:1/header.SampleRate:after_rot_onset;
for i = 1:num_channels
    subplot(4, 4, i);
    % we should put the function with error bars here instead of plot!
    plot(T, baseline_corrected_Err_grand_average(:, i));hold on;
    plot(T, baseline_corrected_Corr_grand_average(:, i));
    xlabel('Time[s]');ylabel('Amplitude[\mu V]');title(chanlocs16(i).labels);
end

% I don't know what do we mean by peak because we have 16 channels!which
% one?
peak_time = 0.5 * header.SampleRate;
figure(2);
[Errhandle, ErrZi, Errgrid, ErrXi, ErrYi] = topoplot(Err_grand_average(peak_time, :), chanlocs16);
figure(3);
[Corrhandle, CorrZi, Corrgrid, CorrXi, CorrYi] = topoplot(Corr_grand_average(peak_time, :), chanlocs16);