function filtered_signal = laplacian_euclidean(signal, x, y, z)

    distance_matrix = squareform(pdist([x', y', z'])) + eye(length(x));
    weight_matrix = 1 ./ distance_matrix;
    weight_matrix = (1 - eye(length(x))) .* weight_matrix;
    weight_matrix = weight_matrix ./ repmat(sum(weight_matrix, 1), [size(weight_matrix, 1), 1]);
    
    for i=1:size(signal, 2)
        filtered_signal(:, i) = signal(:, i) - signal * weight_matrix(:, i);
    end
    
end