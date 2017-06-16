function handles = SetDoseCalculation(hObject, handles)
% SetDoseCalculation is called by TomoDoseRate during initialization
% to set the dose calculation settings and (for remote calculation) start a
% timer that continuously checks the status of the SSH2 connection.
%
% Author: Mark Geurts, mark.w.geurts@gmail.com
% Copyright (C) 2017 University of Wisconsin Board of Regents
%
% This program is free software: you can redistribute it and/or modify it 
% under the terms of the GNU General Public License as published by the  
% Free Software Foundation, either version 3 of the License, or (at your 
% option) any later version.
%
% This program is distributed in the hope that it will be useful, but 
% WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General 
% Public License for more details.
% 
% You should have received a copy of the GNU General Public License along 
% with this program. If not, see http://www.gnu.org/licenses/.

% If GPUSADOSE or SADOSE dose calculation was specified
if get(handles.calc_menu, 'Value') == 1
    
    % Declare path to beam model folder (if not specified in config 
    % file, use default path of ./GPU)
    if isfield(handles.config, 'MODEL_PATH')
        handles.modeldir = handles.config.MODEL_PATH;
    else
        handles.modeldir = './GPU';
    end

    % Check for beam model files
    if exist(fullfile(handles.modeldir, 'dcom.header'), 'file') == 2 && ...
            exist(fullfile(handles.modeldir, 'fat.img'), 'file') == 2 && ...
            exist(fullfile(handles.modeldir, 'kernel.img'), 'file') == 2 && ...
            exist(fullfile(handles.modeldir, 'lft.img'), 'file') == 2 && ...
            exist(fullfile(handles.modeldir, 'penumbra.img'), 'file') == 2

        % Log name
        Event('Beam model files verified, dose calculation enabled');
        
        % Log action
        Event('Scheduling timer to periodically test server connection');

        % Schedule timer to periodically check on calculation status
        start(timer('TimerFcn', {@CheckConnection, hObject}, ...
            'BusyMode', 'drop', 'ExecutionMode', 'fixedSpacing', ...
            'TasksToExecute', Inf, 'Period', 60, 'StartDelay', 1));
    else

        % Disable dose calculation
        handles.calcDose = 0;

        % Update calculation status
        set(handles.status_text, 'String', 'Status: No beam model');

        % Otherwise throw a warning
        Event(sprintf(['Dose calculation disabled, beam model not found. ', ...
            ' Verify that %s exists and contains the necessary model files'], ...
            handles.modeldir), 'WARN');
    end
 
% Otherwise if dose calculation is disabled
else
    
    % Log dose calculation status
    Event('Dose calculation disabled');
    
    % Update calculation status
    set(handles.calc_status, 'String', 'Status: Disabled');
        
    % Set flag to false
    handles.calcDose = 0;
end