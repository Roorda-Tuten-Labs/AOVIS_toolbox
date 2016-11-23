function write_to_buf_file(frame_mat, frame_idx, directory, prefix)
    % write_to_buf_file(frame_mat, frame_idx)
    %
    % frame_mat: frame to write to file in matrix format.
    %
    % frame_idx: frame index. This is appended to the end of prefix. E.g.
    % to name the file 'frame3' set frame_idx to 3.
    %
    % directory: directory to save file into. Default is working directory.
    %
    % prefix: prefix for saving file. Default is 'frame'. Files will be
    % saved in current directory unless directory is specified.
    %
    %

    if nargin < 3
        directory = pwd;
    end
    
    if nargin < 4
        prefix = 'frame';
    end
    
    fid = fopen([directory filesep() prefix num2str(frame_idx) '.buf'], 'w');
    fwrite(fid, size(frame_mat, 2), 'uint16');
    fwrite(fid, size(frame_mat, 1), 'uint16');
    fwrite(fid, frame_mat, 'double');
    fclose(fid);

end