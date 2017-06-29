function handles = ClearPlanData(handles)
% ClearPlanData is called by TomoDoseRate when a new plan is selected
% and if the user presses "Clear All" to clear all dose rate and BED
% related variables.
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
    Event('Clearing plan variables from memory');
else
    Event('Initializing plan variables');
end

% Clear plan info
handles.image = [];
handles.plan = [];
handles.dose = [];
handles.rate = [];
handles.bed = [];

% Disable print and export buttons while patient data is unloaded
set(handles.exporthist_button, 'Enable', 'off');
set(handles.exporttable_button, 'Enable', 'off');
set(handles.exportdicom_button, 'Enable', 'off');

% Disabled dose and BED calculation buttons
set(handles.calc_menu, 'Enable', 'off'); 
set(handles.calcdose_button, 'Enable', 'off'); 
set(handles.calcbed_button, 'Enable', 'off'); 

% Hide plots
if isfield(handles, 'tcsplot')
    delete(handles.tcsplot);
else
    set(allchild(handles.tcs_axes), 'visible', 'off'); 
    set(handles.tcs_axes, 'visible', 'off');
    set(handles.tcs_slider, 'visible', 'off');
    colorbar(handles.tcs_axes,'off');
end
set(handles.tcs_button, 'visible', 'off');
set(handles.alpha, 'visible', 'off');

if isfield(handles, 'histogram')
    delete(handles.histogram);
else
    set(allchild(handles.hist_axes), 'visible', 'off'); 
    set(handles.hist_axes, 'visible', 'off');
end

% Reset plot selection menus
set(handles.tcs_menu, 'Value', 1);
set(handles.tcs_menu, 'Enable', 'off');
set(handles.hist_menu, 'Value', 1);
set(handles.hist_menu, 'Enable', 'off');
set(handles.histview_menu, 'Enable', 'off');

% Reset plan info table
set(handles.plan_table, 'Data', cell(12,2));
set(handles.plan_table, 'Enable', 'off');

% Reset structure table
set(handles.struct_table, 'Data', cell(20,8));
set(handles.struct_table, 'Enable', 'off');

% Change save button to load
set(handles.loadmat_button, 'String', 'Load Stored Dose Rate');