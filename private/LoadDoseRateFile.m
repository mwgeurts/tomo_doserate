function handles = LoadDoseRateFile(handles)
% LoadDoseRateFile is called by TomoDoseRate when the user clicks the "Load
% Stored Dose Rate" button, and prompts the user to select a file. If a
% valid file is selected, the function will attempt to load the data into
% the handles.rate field.
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

% If not executing in unit test
if ~isfield(handles.config, 'UNIT_FLAG') || ...
        str2double(handles.config.UNIT_FLAG) == 0

    % Request the user to select the Daily QA DICOM or XML
    Event('UI window opened to select file');
    [name, path] = uigetfile({'*.mat'}, ...
        'Select a stored dose rate file', handles.path);
    
else
    
    % Log unit test
    Event('Retrieving stored name and path variables', 'UNIT');
    name = handles.config.UNIT_NAME;
    path = handles.config.UNIT_PATH;
end
    
% If the user selected a file
if ~isequal(name, 0)
    
    % Load file contents
    r = load(fullfile(path, name),'-mat', 'rate');
    handles.rate = r.rate;
     
    % Log action
    Event(['File contents in ', name, ' stored to rate variable']);
      
    % Change load button to save
    set(handles.loadmat_button, 'String', 'Save Stored Dose Rate');
    
    % Enable calculate BED button
    set(handles.calcbed_button, 'Enable', 'on');
end