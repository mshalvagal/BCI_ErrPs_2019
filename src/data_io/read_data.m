function [out_data, calibration] = read_data(dataset_path)
    %% Read data
    dirinfo = dir(dataset_path);

    signal = double.empty();
    behavior = double.empty();

    num_channels = 16;

    for i = 1:size(dirinfo)

        if contains(dirinfo(i).name, 'Online') || contains(dirinfo(i).name, '.')
            continue
        end
        
        path = [dirinfo(i).folder '/' dirinfo(i).name];
        [batch_signal, header] = sload([path '/' dirinfo(i).name '.gdf']);

        if contains(dirinfo(i).name, 'calibration')
            calibration.eeg = batch_signal(:, 1:num_channels);
            calibration.eog = batch_signal(:, 17:19);
        else
            batch_behavior = single(dlmread([path '/' dirinfo(i).name '.txt']));

            signal = [signal; batch_signal];
            behavior = [behavior; batch_behavior];
        end
    end
    
    out_data.signal = signal;
    out_data.behavior = behavior;
    out_data.header = header;
    
end

