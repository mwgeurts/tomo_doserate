function handles = ParseConfigOptions(handles, filename)
% ParseConfigOptions is executed by TomoDoseRate to open the config file
% and update the application settings. The GUI handles structure and
% configuration filename is passed to this function, and and updated
% handles structure containing the loaded configuration options is
% returned.
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

% Log event and start timer
t = tic;
Event(['Opening file handle to ', filename]);

% Open file handle to config.txt file
fid = fopen(filename, 'r');

% Verify that file handle is valid
if fid < 3
    
    % If not, throw an error
    Event(['The ', filename, ' file could not be opened. Verify that this ', ...
        'file exists in the working directory. See documentation for ', ...
        'more information.'], 'ERROR');
end

% Scan config file contents
c = textscan(fid, '%s', 'Delimiter', '=');

% Close file handle
fclose(fid);

% Loop through textscan array, separating key/value pairs into array
for i = 1:2:length(c{1})
    config.(strtrim(c{1}{i})) = strtrim(c{1}{i+1});
end

% Clear temporary variables
clear c i fid;

% Log completion
Event(['Read ', filename, ' to end of file']);

% Default folder path when selecting input files
if strcmpi(config.DEFAULT_PATH, 'userpath')
    handles.path = userpath;
else
    handles.path = config.DEFAULT_PATH;
end
Event(['Default file path set to ', handles.path]);

% Set the initial image view orientation to Transverse (T)
handles.tcsview = config.DEFAULT_IMAGE_VIEW;
Event(['Default dose view set to ', config.DEFAULT_IMAGE_VIEW]);

% Set the default transparency
set(handles.alpha, 'String', config.DEFAULT_TRANSPARENCY);
Event(['Default dose view transparency set to ', ...
    config.DEFAULT_TRANSPARENCY]);

% Store all config options to handles.config
handles.config = config;

% Log event and completion
Event(sprintf('Configuration options loaded successfully in %0.3f seconds', ...
    toc(t)));

