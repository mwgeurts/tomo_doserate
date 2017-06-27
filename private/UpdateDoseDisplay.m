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
    'Average Dose Rate (Gy/min)'
    'Maximum Dose Rate (Gy/min)'
    'Biologically Effective Dose (Gy)'
    'Instantaneous BED (Gy)'
    'Continuous Dose BED (Gy)'
    'Equivalent Dose Rate (Gy/min)'
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
        
    % Average dose rate display
    case 3
        
        % Log plot selection
        Event('Average dose rate plot selected');
        
        % Check if the planned dose and image are loaded
        if isfield(handles, 'image') && ...
                isfield(handles.image, 'data') ...
                && isfield(handles, 'rate') && ...
                isfield(handles.rate, 'average')
            
            % Calculate scaling factor for average to account for delays
            % between beams
            s = handles.rate.time(end) / (handles.rate.time(end) + ...
                handles.delay * 60 * (handles.repeat * ...
                length(handles.plan.numberOfProjections) - 1));
            
            % Re-initialize plot with new overlay data
            handles.tcsplot.Initialize('overlay', struct('data', ...
                handles.rate.average * 60 * s, 'start', handles.image.start, ...
                'width', handles.image.width, 'dimensions', ...
                handles.image.dimensions));
            
            % Enable transparency and TCS inputs
            set(handles.alpha, 'visible', 'on');
            set(handles.tcs_button, 'visible', 'on');
        else
            % Log why plot was not displayed
            Event('Dose not displayed as no data exists');
        end
        
    % Maximum dose rate display
    case 4
        
        % Log plot selection
        Event('Maximum dose rate plot selected');
        
        % Check if the planned dose and image are loaded
        if isfield(handles, 'image') && ...
                isfield(handles.image, 'data') ...
                && isfield(handles, 'rate') && ...
                isfield(handles.rate, 'max')
                
            % Re-initialize plot with new overlay data
            handles.tcsplot.Initialize('overlay', struct('data', ...
                handles.rate.max * 60, 'start', handles.image.start, ...
                'width', handles.image.width, 'dimensions', ...
                handles.image.dimensions));
            
            % Enable transparency and TCS inputs
            set(handles.alpha, 'visible', 'on');
            set(handles.tcs_button, 'visible', 'on');
        else
            % Log why plot was not displayed
            Event('Dose not displayed as no data exists');
        end
        
    % BED display
    case 5
        
        % Log plot selection
        Event('BED plot selected');
        
        % Check if the BED and image are loaded
        if isfield(handles, 'image') && ...
                isfield(handles.image, 'data') ...
                && isfield(handles, 'bed') && ...
                isfield(handles.bed, 'variable')
                
            % Re-initialize plot with new overlay data
            handles.tcsplot.Initialize('overlay', struct('data', ...
                handles.bed.variable, 'start', handles.image.start, ...
                'width', handles.image.width, 'dimensions', ...
                handles.image.dimensions));
            
            % Enable transparency and TCS inputs
            set(handles.alpha, 'visible', 'on');
            set(handles.tcs_button, 'visible', 'on');
        else
            % Log why plot was not displayed
            Event('BED not displayed as no data exists');
        end
    
    % Instantaneous BED display
    case 6
        
        % Log plot selection
        Event('Instantaneous BED plot selected');
        
        % Check if the BED and image are loaded
        if isfield(handles, 'image') && ...
                isfield(handles.image, 'data') ...
                && isfield(handles, 'bed') && ...
                isfield(handles.bed, 'instant')
                
            % Re-initialize plot with new overlay data
            handles.tcsplot.Initialize('overlay', struct('data', ...
                handles.bed.instant, 'start', handles.image.start, ...
                'width', handles.image.width, 'dimensions', ...
                handles.image.dimensions));
            
            % Enable transparency and TCS inputs
            set(handles.alpha, 'visible', 'on');
            set(handles.tcs_button, 'visible', 'on');
        else
            % Log why plot was not displayed
            Event('BED not displayed as no data exists');
        end
        
    % Continuous BED display
    case 7
        
        % Log plot selection
        Event('Continuous BED plot selected');
        
        % Check if the BED and image are loaded
        if isfield(handles, 'image') && ...
                isfield(handles.image, 'data') ...
                && isfield(handles, 'bed') && ...
                isfield(handles.bed, 'continuous')
                
            % Re-initialize plot with new overlay data
            handles.tcsplot.Initialize('overlay', struct('data', ...
                handles.bed.continuous, 'start', handles.image.start, ...
                'width', handles.image.width, 'dimensions', ...
                handles.image.dimensions));
            
            % Enable transparency and TCS inputs
            set(handles.alpha, 'visible', 'on');
            set(handles.tcs_button, 'visible', 'on');
        else
            % Log why plot was not displayed
            Event('BED not displayed as no data exists');
        end
        
    % Equivalent dose rate display
    case 8
        
        % Log plot selection
        Event('Equivalent dose rate plot selected');
        
        % Check if the BED and image are loaded
        if isfield(handles, 'image') && ...
                isfield(handles.image, 'data') ...
                && isfield(handles, 'bed') && ...
                isfield(handles.bed, 'equivdr')
                
            % Re-initialize plot with new overlay data
            handles.tcsplot.Initialize('overlay', struct('data', ...
                handles.bed.equivdr * 60, 'start', handles.image.start, ...
                'width', handles.image.width, 'dimensions', ...
                handles.image.dimensions));
            
            % Enable transparency and TCS inputs
            set(handles.alpha, 'visible', 'on');
            set(handles.tcs_button, 'visible', 'on');
        else
            % Log why plot was not displayed
            Event('Equivalent dose rate not displayed as no data exists');
        end
end

% Log completion
Event(sprintf('Plot updated successfully in %0.3f seconds', toc(t)));

% Clear temporary variables
clear t;

% Return the modified handles
varargout{1} = handles; 