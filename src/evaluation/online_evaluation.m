function [mean_metrics] = online_evaluation(Data, ModelParams, PreprocessParams, raw_data, cp, HyperParams)
%ONLINE_EVALUATION Summary of this function goes here
%   Detailed explanation goes here
    
    Trials = Data.eeg_epoched;
    Labels = Data.labels;

    for i=1:cp.NumTestSets
        train_set = Trials(:, : ,cp.training(i));
        train_labels = Labels(cp.training(i));
        
        test_set = Trials(:, :, cp.test(i));
        test_labels = Labels(cp.test(i));

        [~, classifier] = model_assessment(train_set, train_labels, test_set, test_labels, ModelParams);
        ModelParams.trained_classifier = classifier;
        
        % Online decoding of the test data
        % go over the test data one by one
        test_set_starts = Data.fullIdxStart(cp.test(i));
        test_set_ends = Data.fullIdxEnd(cp.test(i));
        test_set_trigs = Data.triggerOnset(cp.test(i));
        
        predicted_labels = zeros(size(test_labels));
        
        TN=0; TP=0; FN=0; FP=0;        
        for j=1:cp.TestSize(i)
            signal = raw_data.signal(test_set_starts(j):test_set_ends(j), :);

            % sliding window
            window_size = floor(600 * 10^-3 * ModelParams.SR) + 1;    % samples
            step_size = 16;     % samples

            start_ind = 1;
            k = 1;
            sigmoid_dists = [];
            scores = [];
            Signal_windowed.SampleRate = ModelParams.SR;
            while start_ind + window_size < size(signal, 1)
                end_ind = start_ind + window_size;
                
                if k==1
                    Signal_windowed.already_preprocessed_part = [];
                    Signal_windowed.new_part.signal = signal(start_ind:end_ind, :);
                    [sigmoid_dists(k), scores(k), eeg, zf] = online_decoder(Signal_windowed, PreprocessParams, ModelParams);
                    zi = zf;
                else
                    Signal_windowed.already_preprocessed_part = eeg((step_size+1):end, :);
                    Signal_windowed.new_part.signal = signal((end_ind-step_size+1):end_ind, :);
                    [sigmoid_dists(k), scores(k), eeg, zf] = online_decoder(Signal_windowed, PreprocessParams, ModelParams, zi);
                    zi = zf;
                end
                
                k = k + 1;
                start_ind = start_ind + step_size;
            end
%             % Plot posterior probability trace; uncomment for checking 
%             figure(j)
%             set(gcf,'color','w');
% %             subplot(1,2,1);
%             plot((0:(length(sigmoid_dists)-1))/32, sigmoid_dists, 'k');hold on;     
%             title(test_labels(j));
%             plot((0:(length(sigmoid_dists)-1))/32, movmean(sigmoid_dists, HyperParams.window), 'LineWidth', 1.5, 'Color', 'r');
%             hold on;
%             plot((0:(length(scores)-1))/32, scores + 0.1, 'b', 'LineStyle', ':');hold on;
%             trig_onset = test_set_trigs(j) - test_set_starts(j);
%             plot([trig_onset/512, trig_onset/512], [0, 1], 'LineWidth', 2, 'LineStyle', ':')
%             axis tight;
%             xlabel('time(s)', 'FontSize', 14);
%             ylabel('Posterior Probability', 'FontSize', 14);
%             ax = gca;
%             ax.FontSize = 14;
            
            % consider that the minimum time of trigger onset is 800 ms
            % basically assume that trigger onset does not happen sooner
            % than 800 ms and set all the posterior probablities to zero
            sigmoid_dists(1:26) = 0;
            sigmoid_dists = movmean(sigmoid_dists, HyperParams.window);
            
            
            % decide on the trial type
            predicted_labels(j) = any(sigmoid_dists>HyperParams.threshold);
            
            % TODO: Evaluate the online labels
            % If we consider the timing of the error detection
            trig_onset = test_set_trigs(j) - test_set_starts(j);
            if test_labels(j)
                errorIdx = find(sigmoid_dists>HyperParams.threshold, 1);
                if predicted_labels(j)
                    if (errorIdx/32)>(trig_onset/512)
                        TP = TP + 1;
                    else
                        FP = FP + 1;
                    end
                else
                    FN = FN + 1;
                end
            else
                if predicted_labels(j)
                    FP = FP + 1;
                else
                    TN = TN + 1;
                end
            end
            
        end
        confusion_matrix = [TN, FP; FN, TP];

        metrics = p_metrics(confusion_matrix, test_labels, zeros(size(test_labels)));
        metrics.accuracy = (TP+TN)/(TP+TN+FP+FN);
        metrics.confusion_matrix = confusion_matrix;
        
        confusion_matrices(:,:,i) = metrics.confusion_matrix;
        vect_metrics(i) = metrics;
    end

    % get mean value of all metrics :
    mean_metrics.accuracy = nanmean([vect_metrics.accuracy]);
    mean_metrics.conf_matrix = sum(confusion_matrices,3);
    mean_metrics.mcc = nanmean([vect_metrics.mcc]);
    mean_metrics.tpr = nanmean([vect_metrics.tpr]);
    mean_metrics.fpr = nanmean([vect_metrics.fpr]);
    mean_metrics.auc = nanmean([vect_metrics.auc]);
    mean_metrics.precision = nanmean([vect_metrics.precision]);
    mean_metrics.recall = nanmean([vect_metrics.recall]);
    mean_metrics.fmeasure = nanmean([vect_metrics.fmeasure]);
    
end

