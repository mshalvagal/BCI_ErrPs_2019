function filtered_signal = laplacian_euclidean(signal, x, y, z)
    load('src/preprocessing/laplacian_16_10-20_mi.mat');
    
    for i=1:size(signal, 2)
        filtered_signal(:, i) = signal(:, i) - signal * lap(:, i);
    end
   
    
    
end