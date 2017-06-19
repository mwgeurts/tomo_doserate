function handles = SaveDoseRateFile(handles)
% LoadDoseRateFile is called by TomoDoseRate when the user clicks the "Save
% Stored Dose Rate" button, and prompts the user to select a file to save 
% to. If a valid file is selected, the function will save the contents of
% handles.rate.
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
    [name, path] = uiputfile({'*.mat'}, ...
        'Select location to save dose rate file', handles.path);
    
else
    
    % Log unit test
    Event('Retrieving stored name and path variables', 'UNIT');
    name = handles.config.UNIT_NAME;
    path = handles.config.UNIT_PATH;
end
    
% If the user selected a file
if ~isequal(name, 0)
    
    % Load file contents
    rate = handles.rate; %#ok<NASGU>
    save(fullfile(path, name), 'rate', '-mat');
     
    % Clear temporary variables
    clear rate;
    
    % Log action
    Event(['Rate variable saved to ', name]);
end