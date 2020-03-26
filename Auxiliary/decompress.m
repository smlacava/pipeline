%% decompress
% This function decopress a data archive or a file(only .zip, .tar and .gz 
% extensions are supproted)
%
% decompress(file, directory_check, outDir)
%
% input:
%   file is the file or the archive which has to be decopressed
%   directory_check is the flag which has to be 1 if the file which has to
%       be decompressed is a an archive, while it has to be 0 if it is a
%       single file (0 by default)
%   outDir is the output directory name (optional)


function decompress(file, directory_check, outDir)
    if nargin == 1
        directory_check = 0;
    end
    
    names = {'.tar', '.zip', '.gz'};
    functions = {@untar, @unzip, @gunzip};
    
    for i = 1:length(names)
        if contains(file, names{i})
            f = functions{i};
            if directory_check == 1
                if nargin < 3
                    outDir = strtok(file, names{i});
                end
                f(file, outDir)
            else
                if nargin < 3
                    f(file);
                else
                    f(file, strcat(path_check(outDir), names{i}));
                end
            end
        end
    end
end