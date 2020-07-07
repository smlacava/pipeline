%% epmean_and_manage
% This function computes the epochs mean of the data matrices and saves
% a single data matrix for the Firstients (First) and another one for the 
% healthy controls (Second)
% 
% [locations_file, sub_types] = epmean_and_manage(inDir, type, subFile, ...
%       locations_file)
%
% input:
%   inDir is the data directory 
%   type is the measure type (offset, plv, aec, etc.)
%   subFile is the file which contains the subjects list with their class
%   locations_file is the name (with its Firsth) of the file which contains
%       the name of each locations (optional)
%
% output:
%   locations_file is the file of the locations
%   sub_types is the list of subjects' types


function [locations_file, sub_types] = epmean_and_manage(inDir, type, ...
    subFile, locations_file)
    
    if nargin == 3
        locations_file = [];
    end
    f = waitbar(0,'Initial setup process', ...
        'Color', '[1 1 1]');
    fchild = allchild(f);
    fchild(1).JavaPeer.setForeground(fchild(1).JavaPeer.getBackground.BLUE)
    fchild(1).JavaPeer.setStringPainted(true)
    

    type = char_check(string(type));
    inDir = path_check(inDir);
    if sum(contains(inDir, {'AECo', 'AEC', 'PLI', 'PLV', 'coherence', ...
            'PSDr', 'offset', 'exponent'})) == 0
        inDir = path_check(strcat(inDir, type));
    end
    epDir = subdir(inDir, 'Epmean');
    epDir = path_check(epDir);
    areasDir = path_check(subdir(epDir, 'Areas'));
    totDir = path_check(subdir(epDir, 'Total'));
    asyDir = path_check(subdir(epDir, 'Asymmetry'));
    globDir = path_check(subdir(epDir, 'Global'));

    cases = define_cases(inDir);
    [Subjects, sub_types, nSUB, nFirst, nSecond] = ...
        define_sub_types(subFile);
    av_functions = {@asymmetry_av, @total_av, @global_av, @areas_av};
    av_paths = {asyDir, totDir, globDir, areasDir};
    ntypes = length(av_paths);
    locFLAG = 0;
    
    
    % setup
    [measure, ~, locations] = load_data(strcat(inDir, cases(1).name));
    aux_loc_file = strcat(path_check(inDir), 'Locations.mat');
    if isempty(locations) 
        if not(isempty(locations_file)) && check_loc_file(locations_file)
            locations = load_data(locations_file);
            locations = locations(:, 1);
        elseif exist(aux_loc_file, 'file')
            load(aux_loc_file);
        end
    end
    if isempty(locations)
        aux_locs = ask_locations();
        if not(isempty(aux_locs))
            [r, c] = size(aux_locs);
            if r < c
                aux_locs = aux_locs';
            end
            locations = {};
            aux_locs = aux_locs(:, 1);
            for n_loc = 1:length(aux_locs)
                locations = [locations; aux_locs{n_loc}];
            end
            locations_file = strcat(inDir, 'Locations.mat');
            if exist(char_check(strcat(inDir, 'auxiliary.txt')), 'file')
                auxID = fopen(char_check(strcat(inDir, ...
                    'auxiliary.txt')), 'r');
                fseek(auxID, 0, 'bof');
                while ~feof(auxID)
                    proper = fgetl(auxID);
                    if contains(proper, 'Locations=')
                        locFLAG = 1;
                        break;
                    end
                end
                fclose(auxID); 
            end    
            if locFLAG == 1
                auxID = fopen('auxiliary.txt', 'a');
                fprintf(char_check(strcat('Locations=', locations_file)));
            end
            save(locations_file, 'locations')
        end
    end
    
    if sum(strcmpi(type, ["offset"; "off"; "exponent"; "exp"]))
        nLoc = size(measure, 2);
        nBands = 1;
        ind_ep = 1;
    elseif sum(strcmpi(type,["psd"; "psdr"]))
        nLoc = size(measure, 3);
        nBands = size(measure, 1);
        ind_ep = 2;
    elseif sum(strcmpi(type, ["pli"; "plv"; "aec"; "aecc"; "aeco"; ...
            "msc"; "coherence"; "conn"]))
        nLoc = size(measure, 3);
        nBands = size(measure, 1);
        ind_ep = 2;
        av_functions = {@asymmetry_conn_av, @total_conn_av, ...
            @global_conn_av, @areas_conn_av};
    end 
    setup_size = zeros(ntypes, 1);
    loc_av = [];
    data.measure = squeeze(mean(measure, ind_ep));
    data.locations = locations;
    setup_data = {};
    directories = {epDir, asyDir, globDir, areasDir, totDir};
    for d = 1:length(directories)
        if not(exist(directories{d}, 'dir'))
            mkdir(directories{d})
        end
    end
    for j = 1:ntypes
        f_av = av_functions{j};
        setup_data{j} = f_av(data);
        setup_size(j) = length(setup_data{j}.locations);  
        loc_av(j).First = zeros(nFirst, nBands, setup_size(j));
        loc_av(j).Second = zeros(nSecond, nBands, setup_size(j));
    end
    
    
    countFirst = 1;
    countSecond = 1;
    waitbar(0, f, 'Computing averages of signals')
    n_cases = length(cases);
    for i = 1:n_cases
        [measure, ~, locs] = load_data(strcat(inDir, cases(i).name));
        if isempty(locs)
            if isempty(locations)
                locs = {};
                for n_loc = 1:size(measure, 3)
                    locs = [locs; char(string(n_loc))];
                end
            else
                locs = locations;
            end
        end
        data.measure = measure;
        data.locations = locs;
        data.measure = squeeze(mean(data.measure, ind_ep));
        for j = 1:ntypes
            check_type = not(isempty(loc_av(j).First)) || ...
                not(isempty(loc_av(j).Second));
            if check_type
                aux_data = data;
                f_av = av_functions{j};
                aux_data = f_av(aux_data);
                save(strcat(epDir, cases(i).name), 'data') 
                save(strcat(av_paths{j}, cases(i).name), 'aux_data') 
                [ind, del_ind] = match_locations(...
                    setup_data{j}.locations, aux_data.locations);
                if length(size(loc_av(j).First)) == 3
                    loc_av(j).First(:, :, del_ind) = [];
                    loc_av(j).Second(:, :, del_ind) = [];
                else
                    loc_av(j).First(:, del_ind) = [];
                    loc_av(j).Second(:, del_ind) = [];
                end
                setup_data{j}.locations(del_ind) = [];
                if length(size(aux_data.measure)) == 2 ...
                        && min(size(aux_data.measure)) ~= 1
                    aux_data.measure = aux_data.measure(:, ind);
                elseif nBands == 1
                    aux_data.measure = aux_data.measure(ind);
                end
            end
            for k = 1:nSUB
                aux_case = split(cases(i).name, '.');
                if contains(string(Subjects(k,1)), aux_case{1}) || ...
                    contains(cases(i).name, string(Subjects(k,1)))
                    if check_type
                        if length(size(aux_data.measure)) == 1 || ...
                                    min(size(aux_data.measure)) == 1
                            if patient_check(Subjects(k, end), ...
                                sub_types{1})
                                loc_av(j).First(countFirst, :) = ...
                                    aux_data.measure';
                                countFirst = countFirst+floor(j/ntypes);
                            else
                                loc_av(j).Second(countSecond, :) = ...
                                    aux_data.measure';
                                countSecond = countSecond+floor(j/ntypes);
                            end
                        else
                            if patient_check(Subjects(k, end), ...
                                sub_types{1})
                                loc_av(j).First(countFirst, :, :) = ...
                                aux_data.measure;
                                countFirst = countFirst+floor(j/ntypes);
                            else
                                loc_av(j).Second(countSecond, :, :) = ...
                                    aux_data.measure;
                                countSecond = countSecond+floor(j/ntypes);
                            end
                        end
                    else
                        if patient_check(Subjects(k, end), sub_types{1})
                            countFirst = countFirst+floor(j/ntypes);
                        else
                            countSecond = countSecond+floor(j/ntypes);
                        end
                    end
                    break;
                end
            end
        end
        save(strcat(epDir, cases(i).name), 'data')
        waitbar(i/n_cases, f)
    end
     
    waitbar(1, f ,'Saving data')    
    for j = 1:ntypes
        First = struct();
        Second = struct();
    	First.data = loc_av(j).First;
        Second.data = loc_av(j).Second;
        First.locations = setup_data{j}.locations;
        Second.locations = setup_data{j}.locations;
        if j == 2
            locations = First.locations;
            save(strcat(path_check(inDir), 'Locations.mat'), 'locations')
        end
        save(strcat(av_paths{j}, 'First.mat'), 'First')
        save(strcat(av_paths{j}, 'Second.mat'), 'Second')
    end
    locations_file = strcat(path_check(limit_path(inDir, type)), ...
        'Locations.mat');
    if isempty(locations)
        locations = [];
    end
    save(locations_file, 'locations')
    close(f)
end


function check = check_loc_file(locations_file)
    check = 0;
    null_list = {'[]', '0', 'nan', 'NaN', 'Nan', 'NAN', 'null', ...
        'NULL', 'Null', 'None', 'NONE', 'none', 'false', 'False'};
    for i = 1:length(null_list)
        if strcmp(null_list{i}, char_check(locations_file))
            check = 1;
        end
    end
    check = (check == 0);
end


%% define_sub_types
% This function defines the types of subjects through a file containing
% information about them
%
% [Subjects, sub_types, nSUB, nFirst, nSecond] = define_sub_types(subFile)
%
% Input:
%   subFile is the name of the file, with its path, containing the list of
%       the subjects
%
% Output:
%   Subjects is the matrix of the subjects
%   sub_types is the list of subjects' types
%   nSUB is the total number of subjects
%   nFirst is the number of subjects belonging to the first type
%   nSecond is the number of subjects belonging to the second type


function [Subjects, sub_types, nSUB, nFirst, nSecond] = ...
    define_sub_types(subFile)
    Subjects = load_data(subFile);
    try
        S = categorical(Subjects{:, end});
    catch
        S = categorical(Subjects(:, end));
    end
    sub_types = categories(S);
    nSUB = length(S);
    nFirst = sum(S == sub_types(1));
    nSecond = nSUB-nFirst;
end