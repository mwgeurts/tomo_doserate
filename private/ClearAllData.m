function handles = ClearAllData(handles)
% ClearAllData is called by TomoDoseRate during application initialization
% and if the user presses "Clear All" to reset the UI and initialize all
% runtime data storage variables.
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

% Log action
if isfield(handles, 'plan') && ~isempty(handles.plan)
    Event('Clearing patient archive variables from memory');
else
    Event('Initializing patient archive variables');
end

% Clear plan data
handles.name = [];
handles.db = [];
handles.build = [];
handles.planUIDs = [];

% Clear patient file string
set(handles.file_text, 'String', '');

% Clear plan selection
set(handles.plan_menu, 'Value', 1);
set(handles.plan_menu, 'String', {''});
set(handles.plan_menu, 'Enable', 'off');

% Clear options
set(handles.combine_button, 'Enable', 'off');
set(handles.loadmat_button, 'Enable', 'off');

% Also execute ClearDoseRateData
handles = ClearDoseRateData(handles);

