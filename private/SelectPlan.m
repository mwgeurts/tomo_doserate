function handles = SelectPlan(handles, value)
% SelectPlan is called by TomoDoseRate and BrowsePatientArchive and loads
% the plan parameters using the tomo_extract submodule functions. This 
% function checks the database version of the archive to determine which 
% functions to call when loading plan data, and will throw an error if an 
% unsupported version is found.
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

% Clear dose rate data
handles = ClearDoseRateData(handles);

% Start waitbar
progress = waitbar(0, 'Loading CT Image');

% If the database version is after 6 (when Tomo moved to characters)
if isletter(handles.db(1))

    % Retrieve CT 
    handles.image = LoadImage(handles.path, handles.name, ...
        handles.planUIDs{value});
    
    % Update progress bar
    waitbar(0.2, progress, 'Loading Delivery Plan');

    % Retrieve Plan 
    handles.plan = LoadPlan(handles.path, handles.name, ...
        handles.planUIDs{value});
    
    % Update progress bar
    waitbar(0.4, progress, 'Loading Structure Sets');
    
    % Retrieve Structures
    handles.image.structures = LoadStructures(handles.path, handles.name, ...
        handles.image);
    
    % Update progress bar
    waitbar(0.6, progress, 'Loading Dose Image');
    
    % Retrieve Dose
    handles.dose = LoadPlanDose(handles.path, handles.name, ...
        handles.planUIDs{value});

% Otherwise, if the database version is 2 or later
elseif str2double(handles.db(1)) >= 2

    % Retrieve CT 
    handles.image = LoadLegacyImage(handles.path, handles.name, ...
        handles.planUIDs{value});
    
    % Update progress bar
    waitbar(0.2, progress, 'Loading Delivery Plan');

    % Retrieve Plan 
    handles.plan = LoadLegacyPlan(handles.path, handles.name, ...
        handles.planUIDs{value});
    
    % Update progress bar
    waitbar(0.4, progress, 'Loading Structure Sets');
    
    % Retrieve Structures
    handles.image.structures = LoadLegacyStructures(handles.path, ...
        handles.name, handles.image);
    
    % Update progress bar
    waitbar(0.6, progress, 'Loading Dose Image');
    
    % Retrieve Dose
    handles.dose = LoadPlanDose(handles.path, handles.name, ...
        handles.planUIDs{value});
end

% Update progress bar
waitbar(0.8, progress, 'Updating Display');

% Update parameters table
handles = UpdatePlanTable(handles);

% Delete any existing DVH viewer
if isfield(handles, 'dvh')
    delete(handles.dvh);
end

% Set histogram menu to planned DVH
set(handles.hist_menu, 'Value', 2);
set(handles.hist_menu, 'Enable', 'on');
set(handles.struct_table, 'Enable', 'on');

% Update DVH plot
handles.dvh = DVHViewer('axis', handles.hist_axes, ...
    'structures', handles.image.structures, ...
    'doseA', handles.dose, 'table', handles.struct_table, ...
    'atlas', handles.atlas, 'columns', 2);

% Get structure table contents
data = get(handles.struct_table, 'Data');

% Append remaining columns
data = horzcat(data, cell(size(data,1), 6));

% Loop through structures
for i = 1:size(data,1)
    
    % If target regexp config data exists
    if isfield(handles.config, 'TARGET_REGEXP') && ...
            size(regexpi(handles.image.structures{i}.name, ...
            handles.config.TARGET_REGEXP), 1) > 0
       
        data{i,3} = 'Tumor';
        
    % Otherwise, if early regexp config data exists
    elseif isfield(handles.config, 'EARLY_REGEXP') && ...
            size(regexpi(handles.image.structures{i}.name, ...
            handles.config.EARLY_REGEXP), 1) > 0
       
        data{i,3} = 'Early';
    else
        data{i,3} = 'Late';
    end
    
    % Store the structure volume
    data{i,4} = sprintf('%0.1f cc', handles.image.structures{i}.volume);
end

% Update table
set(handles.struct_table, 'Data', data);

% Delete any existing TCS viewer
if isfield(handles, 'tcsplot')
    delete(handles.tcsplot);
end
   
% Set TCS menu to planned dose
set(handles.tcs_menu, 'Value', 2);
set(handles.tcs_menu, 'Enable', 'on');

% Initialize Dose Viewer
handles.tcsplot = ImageViewer('axis', handles.tcs_axes, ...
    'tcsview', handles.tcsview, 'background', handles.image, ...
    'overlay', handles.dose, 'alpha', ...
    sscanf(get(handles.alpha, 'String'), '%f%%')/100, ...
    'structures', handles.image.structures, ...
    'structuresonoff', data, ...
    'slider', handles.tcs_slider, 'cbar', 'on', 'pixelval', 'off');

% Enable TCS/alpha inputs
set(handles.tcs_button, 'visible', 'on');
set(handles.alpha, 'visible', 'on');

% Clear temporary variables
clear data;

% Update waitbar
waitbar(1.0, progress, 'Plan load completed');

% Update plan data
handles = UpdatePlanTable(handles);

% Close waitbar
close(progress);

% Clear dose rate
handles.rate = [];

% Clear temporary variables
clear progress i prescription width;

% Check if dose calc is enabled, and if so enable button
if isfield(handles, 'calcDose') && handles.calcDose == 1 
    
    % Log action
    Event('Plan load completed, enabling dose calculation');

    % Enable calculation
    set(handles.calc_menu, 'Enable', 'on');
    set(handles.calcdose_button, 'Enable', 'on');
end