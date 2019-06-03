function filtered_signal = laplacian_euclidean(signal, x, y, z)

    distance_matrix = squareform(pdist([x', y', z'])) + eye(length(x));
    %weight_matrix = 1 ./ distance_matrix;
    %weight_matrix = (1 - eye(length(x))) .* weight_matrix;
    %weight_matrix = weight_matrix ./ repmat(sum(weight_matrix, 1), [size(weight_matrix, 1), 1]);
    
    %for i=1:size(signal, 2)
    %    filtered_signal(:, i) = signal(:, i) - signal * weight_matrix(:, i);
    %end
    % Try to add neighbourhood only filtering
    % small meaning neighbourhood is 3cm distance 
    for i=1:size(signal, 2)
        acc = 0;
        div_acc = 0;
        for j = 1:size(signal, 2)
            if(abs(distance_matrix(j, i)) > 0.2 && abs(distance_matrix(j, i)) < 0.4 )
                 weight = 1 ./ distance_matrix(j,i);
                 div_acc = div_acc + weight;
                 acc = acc + signal(:,j) * weight;
            end 
        end 
        filtered_signal(:, i) = signal(:, i) - acc/div_acc;
    end
    
end