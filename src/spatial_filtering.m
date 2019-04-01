
function filtered_signal = spatial_filtering(signal, type, varargin)
    % signal is T * C
    % We need to be careful about laplacian, because I read somewhere that
    % it will change the units of the data! I will check this later!
    if strcmp(type, 'CAR')
        filtered_signal = CAR_filter(signal);
    elseif strcmp(type, 'Laplacian perrin')
        % varargin should contain the chanlocs
        X = extractfield(varargin{1}, 'X');
        Y = extractfield(varargin{1}, 'Y');
        Z = extractfield(varargin{1}, 'Z');
        [surf_lap, ~, ~] = laplacian_perrinX(signal', X, Y, Z); 
        filtered_signal = surf_lap';
    elseif strcmp(type, 'Laplacian euclidean')
        % varargin should contain the chanlocs
        X = extractfield(varargin{1}, 'X');
        Y = extractfield(varargin{1}, 'Y');
        Z = extractfield(varargin{1}, 'Z');
        filtered_signal = laplacian_euclidean(signal, X, Y, Z);
    elseif strcmp(type, 'DAWN')

    elseif strcmp(type, 'CCN')

    end
   
end