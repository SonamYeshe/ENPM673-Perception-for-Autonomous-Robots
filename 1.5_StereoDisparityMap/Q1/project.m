function x = project(X, R, T, K)
    % Build extrinsic matrix.
    Ex(:, 1 : 3) = R;
    Ex(:, 4) = T;
    % Build the matrix with multiplication of intrinsic and extrinsic matrices.
    InEx = K * Ex;
    % Predefine the position in the image plane and the homogeneous 3d
    % vertex positions.
    pos = ones(4, 1);
    x = zeros(2, 8);
    for i = 1 : size(X, 1)
        % Calculate the 2d vertex positions.
        pos(1 : 3) = X(i, :);
        xx = InEx * pos;
        x(: , i) = xx(1 : 2);
    end
end