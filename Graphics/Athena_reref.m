%% Athena_reref
% This function is used to select the location (or the average of all the
% locations related recordings) which has to be used to rereference all the
% time series related to each location.


function varargout = Athena_reref(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_reref_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_reref_OutputFcn, ...
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


%% Athena_reref_OpeningFcn
% This function is called during the interface opening, and it sets all the
% initial parameters with respect to the arguments passed when it is
% called.
function Athena_reref_OpeningFcn(hObject, ~, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    [x, ~] = imread('logo.png');
    Im = imresize(x, [250 250]);
    set(handles.help_button, 'CData', Im)
    if nargin >= 4
        set(handles.locs, 'String', [varargin{1} 'Average']);
        set(handles.locs, 'Max', length(varargin{1})+1, 'Min', 0);
    end
    

function varargout = Athena_reref_OutputFcn(~, ~, handles) 
    varargout{1} = handles.output;


%% back_Callback
% This function closes the interface, returning a 0 to the calling
% function.
function back_Callback(~, ~, handles)
    assignin('base','Athena_locsSelecting', 0);
        close(Athena_locsSelecting)

    
function axes3_CreateFcn(~, ~, ~)


function locs_Callback(~, ~, ~)


function locs_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
        get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


%% save_Callback
% This function closes the interface, returning the selected locations to
% the calling function.
function save_Callback(~, ~, handles)
        selectedLocs = get(handles.locs, 'Value');
        %set(handles.output, 'UserData', selectedList);
        assignin('base','Athena_reref', selectedLocs);
        close(Athena_reref)
