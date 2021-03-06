%% Athena_meascorr
% This interface allows to execute the correlation analysis between two
% different measures.


function varargout = Athena_meascorr(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_meascorr_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_meascorr_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end


%% Athena_meascorr_OpeningFcn
% This function is called during the interface opening, and it sets all the
% initial parameters with respect to the arguments passed when it is
% called.
function Athena_meascorr_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    [x, ~] = imread('logo.png');
    Im = imresize(x, [250 250]);
    set(handles.help_button, 'CData', Im)
    if nargin >= 4
        path = varargin{1};
        set(handles.aux_dataPath, 'String', path)
        if not(strcmp(path, 'Static Text'))
            set(handles.dataPath_text, 'String', path)
        end
        set_measures(path, handles);
    end
    if nargin >= 5
        set(handles.aux_measure, 'String', varargin{2})
    end
    if nargin >= 6
        set(handles.aux_sub, 'String', varargin{3})
    end
    if nargin >= 7
        set(handles.aux_loc, 'String', varargin{4})
    end
    if nargin >= 8
        sub_types = varargin{5};
        set(handles.sub_types, 'Data', sub_types)
        if length(sub_types) > 1
            set(handles.PAT, 'String', sub_types{2})
        else
            set(handles.PAT, 'Visible', 'off')
        end
        set(handles.HC, 'String', sub_types{1})
    end
    
    
function varargout = Athena_meascorr_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;


%% dataPath_text_Callback
% This function is called when the dataPath is modified, in order to
% refresh the interface, and to set the available measures.
function dataPath_text_Callback(hObject, eventdata, handles)
    dataPath = get(handles.dataPath_text, 'String');
    set_measures(dataPath, handles);
    subjectsFile = strcat(path_check(dataPath), 'Subjects.mat');
    if exist(subjectsFile, 'file')
        set(handles.aux_sub, 'String', subjectsFile)
        try
            sub_info = load(fullfile_check(subjectsFile));
            aux_sub_info = fields(sub_info);
            eval(strcat("sub_info = sub_info.", aux_sub_info{1}, ";"));
            sub_types = categories(categorical(sub_info(:, end)));
            if length(sub_types) == 2
                set(handles.sub_types, 'Data', sub_types)
            end
        catch
        end
    end


function dataPath_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


%% Run_Callback
% This function is used when the Run button is pushed, and it executes the
% correlation analysis between the two chosen measures.
function Run_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Correlations'
    addpath 'Auxiliary'
    addpath 'Graphics'
    
    save_check = 0;
    if strcmpi(user_decision(...
            'Do you want to save the resulting tables?', 'U Test'), 'yes')
        save_check = 1;
    end
    [save_check_fig, format] = Athena_save_figures();
    
    [~, sub_list, alpha, bg_color, locs, bands_names, P, RHO, nLoc, ...
        nBands, analysis, sub_group] = correlation_setting(handles);
    
    measures = [{options_list(handles.meas1)} ...
        {options_list(handles.meas2)}];
    
    dataPath = path_check(get(handles.aux_dataPath, 'String'));
    measure_path = measurePath(dataPath, measures{1}, analysis); 
    data_name = strcat(measure_path, char_check(sub_group));
    try
        xData = load_data(data_name);
    catch
        problem(strcat(measures{1}, " epochs averaging of not computed"));
        return;
    end
    measure_path = measurePath(dataPath, measures{2}, analysis); 
    data_name = strcat(measure_path, char_check(sub_group));
    try
        yData = load_data(data_name);
    catch
        problem(strcat(measures{2}, " epochs averaging of not computed"));
        return;
    end
    if size(xData, 1) ~= size(yData, 1)
        problem(strcat("There is a different number of subjects for ", ...
            "the measures (perhaps, a different subjects' file has ", ...
            "been used)"));
        return;
    end
    
    if get(handles.no, 'Value') == 1
        sub_list = [];
    end
    corrPath = create_directory(dataPath, 'StatAn');
    corrPath = create_directory(corrPath, 'Data');
    measures_correlation(xData, yData, sub_list, bands_names, ...
        measures, alpha, bg_color, locs, P, RHO, nLoc, nBands, ...
        save_check, corrPath, save_check_fig, format)
    
    an_selected = [get(handles.asy_button, 'Value'), ...
        get(handles.tot_button, 'Value'), ...
        get(handles.glob_button, 'Value'), ...
        get(handles.areas_button, 'Value'), ...
        get(handles.hemi_button, 'Value'), ...
        get(handles.hemiareas_button, 'Value')];
    an_paths = {'Asymmetry', 'Total', 'Global', 'Areas', 'Hemispheres', ...
        'Hemispheres_Areas'};
    analysis = an_paths(an_selected == 1);
    sub_types = get(handles.sub_types, 'Data');
    Athena_history_update(strcat("[data, sub_list, alpha, bg_color, ", ...
        "locs, bands_names, P, RHO, nLoc, nBands, analysis, ", ...
        "sub_group] = correlation_setting(", ...
        strcat("'", get(handles.aux_dataPath, 'String'), "'"), ',', ...
        strcat("'", get(handles.aux_measure, 'String'), "'"), ',', ...
        string(get(handles.maxCons, 'Value')), ',', ...
        strcat("'", analysis, "'"), ',', ...
        strcat("{'", sub_types{1}, "','", sub_types{2}, "'}"), ',', ...
        string(get(handles.HC, 'Value')), ',', ...
        string(get(handles.PAT, 'Value')), ',', ...
        strcat("'", get(handles.aux_sub, 'String'), "'"), ')'))
    xData_file = strcat(dataPath, path_check(measures{1}), ...
        path_check('Epmean'), path_check(char_check(analysis)), ...
        char_check(sub_group));
    yData_file = strcat(dataPath, path_check(measures{2}), ...
        path_check('Epmean'), path_check(char_check(analysis)), ...
        char_check(sub_group));
    meas_list = strcat("{'", measures{1}, "','", measures{2}, "'}");
    Athena_history_update(strcat("measures_correlation(", ...
        strcat("'", xData_file, "'"), ',', ...
        strcat("'", yData_file, "'"), ', sub_list, bands_names,', ...
        meas_list, ', alpha, bg_color, locs, P, RHO, nLoc, nBands,', ...
        string(save_check), ',', strcat("'", corrPath, "'"), ',', ...
        string(save_check_fig), ',', strcat("'", format, "'"), ')'));
       

%% data_search_Callback
% This function allows to search the data directory through the file
% explorer.
function data_search_Callback(hObject, eventdata, handles)
	d = uigetdir;
    if d ~= 0
        set(handles.dataPath_text, 'String', d)
        auxPath = pwd;
        dataPath = get(handles.dataPath_text, 'String');
        dataPath = path_check(dataPath);
        set_measures(path)
        cd(dataPath)
        if exist('auxiliary.txt', 'file')
            auxID = fopen('auxiliary.txt', 'r');
            fseek(auxID, 0, 'bof');
            while ~feof(auxID)
                proper = fgetl(auxID);
                if contains(proper, 'Locations=')
                    locations = split(proper, '=');
                    locations = locations{2};
                    set(handles.loc_text, 'String', locations)
                end
            end
            fclose(auxID);     
        end
        cd(auxPath)
    end


%% back_Callback
% This function switches to the Statistical Analysis list interface.
function back_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, sub, loc, sub_types] = GUI_transition(handles);
    if strcmp(dataPath, 'es. C:\User\Data')
        dataPath = "Static Text";
    end
    close(Athena_meascorr)
    Athena_statistics(dataPath, measure, sub, loc, sub_types)


function axes3_CreateFcn(hObject, eventdata, handles)


function meas1_Callback(hObject, eventdata, handles)


function meas1_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end

    
function meas2_Callback(hObject, eventdata, handles)


function meas2_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end
   
    
%% set_measures
% This function set the list of available measures.
function set_measures(path, handles)
    measures = available_measures(path, 1);
    set(handles.meas1, 'String', measures);
    set(handles.meas2, 'String', measures);
