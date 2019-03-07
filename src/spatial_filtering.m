function grand_average = spatial_filtering(signal)
    % signal is T * C * N 
    N = size(signal, 3);
    for trial = 1:N
        filtered_signal(:,:,trial) = CAR_filter(signal(:,:,trial));
    end
    grand_average = mean(filtered_signal, 3);
end