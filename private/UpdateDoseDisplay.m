function varargout = UpdateDoseDisplay(varargin)
% UpdateDoseDisplay is called by TomoDoseRate when initializing or
% updating the dose plot.  When called with no input arguments, this
% function returns a string cell array of available plots that the user can
% choose from.  When called with a GUI handles structure, will update
% handles.dose_axes based on the value of handles.tcs_menu.
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

% Specify plot options and order
plotoptions = {
    ''
    'Planned Dose (Gy)'
};

% If no input arguments are provided
if nargin == 0
    
    % Return the plot options
    varargout{1} = plotoptions;
    
    % Stop execution
    return;
    
% Otherwise, if 1, set the input variable and update the plot
elseif nargin == 1
    
    % Set input variables
    handles = varargin{1};

    % Log start
    Event('Updating dose plot display');
    t = tic;
    
% Otherwise, throw an error
else 
    Event('Incorrect number of inputs to UpdateDoseDisplay', 'ERROR');
end

% Hide all axes and transparency
if isfield(handles, 'tcsplot')
    handles.tcsplot.Hide();
    set(handles.alpha, 'visible', 'off');
    set(handles.tcs_button, 'visible', 'off');
end

% Execute code block based on display GUI item value
switch get(handles.tcs_menu, 'Value')
    
    % Planned dose display
    case 2
        
        % Log plot selection
        Event('Planned dose plot selected');
        
        % Check if the planned dose and image are loaded
        if isfield(handles, 'image') && ...
                isfield(handles.image, 'data') ...
                && isfield(handles, 'dose') && ...
                isfield(handles.dose, 'data')
                
            % Re-initialize plot with new overlay data
            handles.tcsplot.Initialize('overlay', handles.dose);
            
            % Enable transparency and TCS inputs
            set(handles.alpha, 'visible', 'on');
            set(handles.tcs_button, 'visible', 'on');
        else
            % Log why plot was not displayed
            Event('Planned dose not displayed as no data exists');
        end
        
end

% Log completion
Event(sprintf('Plot updated successfully in %0.3f seconds', toc(t)));

% Clear temporary variables
clear t;

% Return the modified handles
varargout{1} = handles; 