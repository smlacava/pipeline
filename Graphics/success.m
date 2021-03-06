%% success
% This function is used to declare the end of a process
%
% success(msg)
%
% Input:
%   msg is the message which has to be showed ('Operation Completed' by
%       default)


function success(msg)
    if nargin == 0
        msg = 'Operation Completed';
    end
    bgc = [1 1 1];
    fgc = [0.067 0.118 0.424];
    btn = [0.427 0.804 0.722];
    f = figure;
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    im = imread('logo.png');
    set(f, 'Position', [200 350 300 150], 'Color', bgc, ...
        'MenuBar', 'none', 'Name', 'Success', 'Visible', 'off', ...
        'NumberTitle', 'off');
    axes('pos', [0 0.4 0.25 0.46])
    imshow('logo.png')
    if strcmpi(msg, 'Operation Completed')
        ht = uicontrol('Style', 'text', 'Units', 'normalized', ...
            'Position', [.25 0.4 0.6 0.3], 'String', msg, ...
            'FontUnits', 'normalized', 'FontSize', 0.35, ...
            'BackgroundColor', bgc, 'ForegroundColor', 'k', ...
            'horizontalAlignment', 'left');
    else
        ht = uicontrol('Style', 'text', 'Units', 'normalized', ...
        'Position', [.25 0.4 0.7 0.5], 'String', msg, ...
        'FontUnits', 'normalized', 'FontSize', 16/length(char(msg)), ...
        'BackgroundColor', bgc, 'ForegroundColor', 'k', ...
        'horizontalAlignment', 'left');
    end
    hok = uicontrol('Style', 'pushbutton', 'String', 'OK', ...
        'FontWeight', 'bold', 'Units', 'normalized', ...
        'Position', [0.35 0.05 0.3 0.25], 'Callback', 'close', ...
        'ForegroundColor', fgc, 'BackgroundColor', btn); 
    hbar = uicontrol('Style', 'text', 'Units', 'normalized', ...
        'Position', [0 0.98 0.3 0.02], 'String', '', ...
        'FontUnits', 'normalized', ...
        'BackgroundColor', fgc, 'ForegroundColor', 'k');
    set(f, 'KeyPressFcn', {@enter_key_pressed});
    set(hok, 'KeyPressFcn', {@enter_key_pressed});
    movegui(f, 'center')
    set(f, 'Visible', 'on')
    waitfor(hok);
end


%% enter_key_pressed
% This function closes the interface if the return key is used.

function enter_key_pressed(varargin)
    if strcmpi(varargin{2}.Key, 'return')
        close(varargin{1})
    end
end