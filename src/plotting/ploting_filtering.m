%% Plotting discriminability using Fisher Score
clear all
load('matlabFunctions/chanlocs16.mat');
[raw_data1, raw_calibration_data1] = read_data('data/a7_20191103');
[raw_data2, raw_calibration_data2] = read_data('data/a8_20191103');
[raw_data3, raw_calibration_data3] = read_data('data/b0_20191203');
[raw_data4, raw_calibration_data4] = read_data('data/b3_20191503');
rawdatas = [raw_data1,raw_data2,raw_data3,raw_data4];
rawcalibrationdatas = [raw_calibration_data1,raw_calibration_data2,raw_calibration_data3,raw_calibration_data4];
figure('Name','Spatial Filter Discriminability Comparison');
names = [string('Spectral filter only'),'CCA','Laplacian euclidean','CAR'];
n =1;
 for s= 1:4
    raw_data = rawdatas(s);
    raw_calibration_data = rawcalibrationdatas(s);
    SR = raw_data.header.SampleRate;
    [ E,~, Data1 ] = get_plottable_sig( false,true, false,'',raw_data, raw_calibration_data,true);
    [~,~,Data2]  = get_plottable_sig( true,true, false,'',raw_data, raw_calibration_data,true);
    [~,~,Data3] = get_plottable_sig( false,true, true,'Laplacian euclidean',raw_data, raw_calibration_data,true);
    [~,~,Data4] =get_plottable_sig( false,true, true,'CAR',raw_data, raw_calibration_data,true);
    Datas = [Data1,Data2,Data3,Data4];
    linespec = {'-b', '-k', '-c', '-g'};
    subplot(2,2,s);
    for j = 1:size(Datas,2)
        Data = Datas(1,j);
        temp = Data.eeg_epoched(floor(0.7*SR:1.3*SR+1), :, :);
        hz64 = downsample(temp, SR / 64);
        data_size = size(hz64);
        X = reshape(hz64,data_size(1)*data_size(2),data_size(3));
        y = Data.labels;
        [orderedInd, orderedPower] = rankfeat(X.', y, 'fisher');
        plot(orderedPower(1:30),linespec{j},'LineWidth',2.0);
        hold on;
    end 
    title('Spatial Filter Discriminability Comparison of Subject '+ string(s))
    legend('Spectral filter only','CCA','Laplacian euclidean','CAR');
    xlabel('Ranked features')
    ylabel('Fisher Score')
 end

%% Pretty plotted spectral filtering results
 clear all
%[raw_data, raw_calibration_data] = read_data('data/b0_20191203');
[raw_data, raw_calibration_data] = read_data('data/a7_20191103');
%[raw_data, raw_calibration_data] = read_data('data/a8_20191103');
%[raw_data, raw_calibration_data] = read_data('data/b3_20191503');
load('matlabFunctions/chanlocs16.mat');
figure('Name','Temporal Filtering ');
subplot(2,1,1);
% do an unfiltered version to compare 
[ Err1,Corr1,Data1 ] = get_plottable_sig( false,false, false,'',raw_data, raw_calibration_data,false);
stderr = std(Err1,0,2)./sqrt(size(Data1.labels(Data1.labels == 1),1));
stdcorr = std(Corr1,0,2)./sqrt(size(Data1.labels(Data1.labels == 0),1));
a1=shadedErrorBar([1:769],mean(Err1,2),stderr);
hold on;
a2=shadedErrorBar([1:769],mean(Corr1,2),stdcorr,'-b',0.8);
title('Without Filtering')
legend([a1.mainLine,a2.mainLine],'Error Trial','Correct Trial')
xlabel('Time[ms]')
ylabel('Amplitude[µV]')

subplot(2,1,2);
[ Err2,Corr2, Data2 ] = get_plottable_sig( false,true, false,'',raw_data, raw_calibration_data,true);
stderr = std(Err2,0,2)./sqrt(size(Data2.labels(Data2.labels == 1),1));
stdcorr = std(Corr2,0,2)./sqrt(size(Data2.labels(Data2.labels == 0),1));
b1 = shadedErrorBar([1:769],mean(Err2,2),stderr);
hold on;
b2 = shadedErrorBar([1:769],mean(Corr2,2),stdcorr,'-b',0.8);
title('Butterworth and EOG correction')
legend([b1.mainLine,b2.mainLine],'Error Trial','Correct Trial')
xlabel('Time[ms]')
ylabel('Amplitude[µV]')

%% Pretty plotted spectral + temporal filtering results
clear all
%[raw_data, raw_calibration_data] = read_data('data/b0_20191203');
[raw_data, raw_calibration_data] = read_data('data/a7_20191103');
%[raw_data, raw_calibration_data] = read_data('data/a8_20191103');
%[raw_data, raw_calibration_data] = read_data('data/b3_20191503');
load('matlabFunctions/chanlocs16.mat');
figure('Name','Result of Preprocessing');
do_CCA = true;
do_t_filt = true;
do_s_filt = false; 
[ Err_grand_average,Corr_grand_average, Data ] = get_plottable_sig( do_CCA,do_t_filt, do_s_filt,'',raw_data, raw_calibration_data,true);
stderr = std(Err_grand_average,0,2)./sqrt(size(Data.labels(Data.labels == 1),1));
stdcorr = std(Corr_grand_average,0,2)./sqrt(size(Data.labels(Data.labels == 0),1));
err = shadedErrorBar([1:769],mean(Err_grand_average,2),stderr);
hold on;
corr = shadedErrorBar([1:769],mean(Corr_grand_average,2),stdcorr,'-b',0.8);
title('Result of filtering ')
xlabel('Time[ms]')
ylabel('Amplitude[µV]')
x = patch([200 800 800 200],[-0.2 -0.2 0.25 0.25],[0.67	0.75 0.8],'FaceAlpha',0.3,'EdgeColor','none');
legend([err.mainLine,corr.mainLine,x],'Erroneous trial','Correct trial','Time Window for Feature Extraction')

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