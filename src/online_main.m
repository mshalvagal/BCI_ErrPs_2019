%% Read the data and separate the trials (+ corresponding labels)

% Data is a structure containing the eeg(called eeg), eog(called eog) and label(called Label) for each trial and SampleRate
Data = read_data('data/b3_20191503');

%% Set the preprocess and model parameters
model_type = 'LDA';
Preprocess.do_eog_correction = true;
Preprocess.do_temporal_filter = true;
Preprocess.temporal_filter_type = 'butter';
Preprocess.temporal_filter_order = 2;
Preprocess.do_spatial_filter = false;
Preprocess.spatial_filter_type = 'CAR';
Preprocess.do_CCA = false;

%% Cross validation 
N = length(Data.Labels);    % total number of trials
num_folds = 5;

cp = cvpartition(Data.Labels, 'KFold', num_folds, 'Stratify', true);

for i=1:num_folds
    % Separate train and test data
    train_set.eeg = Data.eeg(:, : ,cp.training(i));
    train_set.eog = Data.eog(:, : ,cp.training(i));
    test_set.eeg = Data.eeg(:, :, cp.test(i));
    test_set.eog = Data.eog(:, :, cp.test(i));
    train_set.Labels = Data.Labels(cp.training(i));
    test_set.Labels = Data.Labels(cp.test(i));
    train_set.SampleRate = Data.SampleRate;
    test_set.SampleRate = Data.SampleRate;
    
    % Preprocess train data
    % in preprocess function, train_set is a structure containing eeg, eog
    % and SampleRate.
    [train_set, Preprocess.eog_b] = preprocess_eeg(train_set, Preprocess);
    
    % Fit the model to train data
    % we can change the code here based on the final model type we decide 
    Preprocess.do_PCA = true;
 
    if Preprocess.do_PCA 
        Model.channels = [1 3 4 5 8 9 10 14];
        [Model.PCA, train_X] = feature_extraction(train_set, SR, downSR, expVarDesired);
    else
        temp = permute(train_set, [3,2,1]);
        train_X = reshape(temp, size(temp, 1), size(temp, 2) * size(temp, 3));
    end
    
    if strcmp(model_type, 'LDA')
        Model.model = fitcdiscr(train_X, train_labels);
    end
    
    % Online decoding of the test data
    % go over the test data one by one
    for j=1:cp.TestSize(i)
        eeg = test_set.eeg(:, :, j);
        eog = test_set.eog(:, :, j);
        
        % sliding window
        window_size = 600 * 10^-3 * Data.SampleRate;    % samples
        step_size = 16;     % samples
        
        start_ind = 1;
        end_ind = window_size;
        k = 1;
        while end_ind < size(eeg, 1)
            Signal.eeg = eeg(start_ind:end_ind, :);
            Signal.eog = eog(start_ind:end_ind, :);
            Signal.SampleRate = Data.SampleRate;
            
            label(k) = online_decoder(Signal, Model, Preprocess);
            k = k + 1;
        end
        
        
    end
    
end







