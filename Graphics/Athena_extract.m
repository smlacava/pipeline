%% Athena_extract
% This interface allows to extract the time series from the available
% extensions files inside a directory, and to save them in .mat format,
% inside a data structure having the fields which are used by the toolbox,
% eventually also resampling them with a chosen sampling frequency.


function varargout = Athena_extract(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @Athena_extract_OpeningFcn, ...
        'gui_OutputFcn',  @Athena_extract_OutputFcn, ...
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


%% Athena_extract_OpeningFcn
% This function is called during the interface opening, and it sets all the
% initial parameters with respect to the arguments passed when it is
% called.
function Athena_extract_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    [x, ~] = imread('logo.png');
    Im = imresize(x, [250 250]);
    set(handles.help_button, 'CData', Im)
    funDir = which('Athena.m');
    funDir = split(funDir, 'Athena.m');
    cd(funDir{1});
    addpath 'Auxiliary'
    addpath 'Graphics'
    
    if nargin >= 4
        aux_dataPath = varargin{1};
        if not(strcmp(aux_dataPath, 'Static Text'))
            set(handles.dataPath_text, 'String', varargin{1})
        end
    end
    if nargin >= 5
        measure = varargin{2};
        set(handles.aux_measure, 'String', measure)
    end
    if nargin >= 6
        set(handles.aux_sub, 'String', varargin{3})
    end
    if nargin >= 7
        set(handles.aux_loc, 'String', varargin{4})
    end
    if nargin >= 8
        set(handles.sub_types, 'Data', varargin{5})
    end

    
function varargout = Athena_extract_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;


function dataPath_text_Callback(hObject, eventdata, handles)


function dataPath_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


%% data_search_Callback
% This function is called when the directory-searcher button is pushed, in
% order to open the file searcher.
function data_search_Callback(hObject, eventdata, handles)
    d = uigetdir;
    if d ~= 0
        set(handles.dataPath_text, 'String', d)
    end


%% back_Callback
% This function switches to the Utilities list interface.
function back_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [~, measure, sub, loc, sub_types] = GUI_transition(handles, ...
        'dataPath', 'measure');
    dataPath = string(get(handles.dataPath_text, 'String'));
    close(Athena_extract)
    if strcmp('es. C:\User\Data', dataPath)
        dataPath = "Static Text";
    end
    Athena_utility(dataPath, measure, sub, loc, sub_types)

    
function axes3_CreateFcn(hObject, eventdata, handles)


%% RUN_Callback
% This function is used when the Run button is pushed, in order to extract
% the signals from the files.
function RUN_Callback(~, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    fs = [];
    answer = user_decision(strcat("Do you want to reasample all the ", ...
        "signals to a chosen a sample frequency"), 'Sample frequency');
    if strcmp(answer, 'yes')
        fs = value_asking(0, 'Sample frequency', ...
            'Choose the sample frequency');
    end
    signals_extractor(get(handles.dataPath_text, 'String'), fs);
    success()
