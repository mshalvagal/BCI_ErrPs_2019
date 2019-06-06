function [metrics, Scores, Times] = test_online_decoder(Data, raw_data, ModelParams, PreprocessParams, HyperParams)
        
    TN=0; TP=0; FN=0; FP=0;
    Scores = [];
    for j=1:Data.N_Test
        signal = raw_data.signal(Data.fullIdxStart(j):Data.fullIdxEnd(j), :);

        % sliding window
        window_size = floor(600 * 10^-3 * ModelParams.SR) + 1;    % samples
        step_size = 16;     % samples

        start_ind = 1;
        k = 1;
        sigmoid_dists = [];
        t = [];
        Signal_windowed.SampleRate = ModelParams.SR;
        while start_ind + window_size < size(signal, 1)
            end_ind = start_ind + window_size;            

            if k==1
                tic
                Signal_windowed.already_preprocessed_part = [];
                Signal_windowed.new_part.signal = signal(start_ind:end_ind, :);
                [sigmoid_dists(k), scores(k), eeg, zf] = online_decoder(Signal_windowed, PreprocessParams, ModelParams);
                zi = zf;
                t(k) = toc;
            else
                tic
                Signal_windowed.already_preprocessed_part = eeg((step_size+1):end, :);
                Signal_windowed.new_part.signal = signal((end_ind-step_size+1):end_ind, :);
                [sigmoid_dists(k), scores(k), eeg, zf] = online_decoder(Signal_windowed, PreprocessParams, ModelParams, zi);
                zi = zf;
                t(k) = toc;
            end
            
            k = k + 1;
            start_ind = start_ind + step_size;
        end
        
        sigmoid_dists(1:26) = 0;
        sigmoid_dists = movmean(sigmoid_dists, HyperParams.window);
        Scores{end+1} = sigmoid_dists;
        Times(j) = mean(t);
        
        % decide on the trial type
        predicted_labels(j) = any(sigmoid_dists>HyperParams.threshold);

        % TODO: Evaluate the online labels
        trig_onset = Data.triggerOnset(j) - Data.fullIdxStart(j);
        if Data.labels(j)
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

    metrics = p_metrics(confusion_matrix, Data.labels, zeros(1,Data.N_Test));
    metrics.accuracy = (TP+TN)/(TP+TN+FP+FN);
    metrics.confusion_matrix = confusion_matrix;

end