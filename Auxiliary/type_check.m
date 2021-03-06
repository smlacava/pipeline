%% type_check
% This function define if the input measure is or not connectivity measure.
%
% type = type_check(measure)
% 
% input:
%   measure is the name of the measure to evaluate
% 
% output:
%   type is the type of the measure, it is returned as it is if the measure
%       is not a connectivity measure, otherwise it is returned as 'CONN'
%   connCheck is a flag which is returned as 1 if the measure is a
%       connectivity measure, as 0 otherwise

function [type, connCheck] = type_check(measure)
    type = string(measure);
    connCheck = 0;
    if sum(strcmpi(measure, Athena_measures_list(0, 0, 1, 0)))
        type = "CONN";
        connCheck = 1;
    elseif strcmpi(measure, "exponent")
        type = "EXP";
    elseif strcmpi(measure, "offset")
        type = "OFF";
    end
end