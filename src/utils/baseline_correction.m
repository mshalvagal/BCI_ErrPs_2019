function [ bl_output ] = baseline_correction( signal, window )
    % Compensates the offset so the EMG signal start at 0 
    %   This functions takes the first x values, x being defined by window, average them and define this value as the new 0
    % signal is T * C * N
    size_matrix = size(signal);
    bl_output = zeros(size_matrix);
    for channel = 1:size_matrix(2)
        for trial = 1:size_matrix(3) 
            offset = mean(signal(1:window, channel, trial));
            for tp = 1:size_matrix(1)
                bl_output(tp,channel,trial) = signal(tp,channel,trial) - offset;
            end

        end
    end
end

