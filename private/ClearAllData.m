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
if isfield(handles, 'planUID')
    Event('Clearing patient plan variables from memory');
else
    Event('Initializing patient plan variables');
end