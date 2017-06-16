function varargout = UpdateHistogram(varargin)
% UpdateHistogram is called by TomoDoseRate when 
% initializing or updating the results plot.  When called with no input 
% arguments, this function returns a string cell array of available plots 
% that the user can choose from.  When called with a plot handle and GUI 
% handles structure, will update varagin{2} based on the value of 
% varargin{2} using the data structure in handles.
%
% The following variables are required for proper execution: 
%   varargin{1} (optional): plot handle to update
%   varargin{2} (optional): type of plot to display (see below for options)
%   varargin{3} (optional): structure containing the data variables used 
%       for statistics computation. This will typically be the guidata (or 
%       data structure, in the case of PrintReport).
%   varargin{4} (optional): file handle to also write data to
%
% The following variables are returned upon succesful completion:
%   vararout{1}: if nargin == 0, cell array of plot options available.
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

% Run in try-catch to log error via Event.m
try

% Specify plot options and order
plotoptions = {
    ''
    'Planned Dose Volume Histogram'
};

% If no input arguments are provided
if nargin == 0
    
    % Return the plot options
    varargout{1} = plotoptions;
    
    % Stop execution
    return;
    
% Otherwise, if 1, set the input variable and update the plot
elseif nargin >= 3

    % Set input variables
    handles = varargin{3};

    % Log start
    Event('Updating histogram plot display');
    tic;
    
% Otherwise, throw an error
else 
    Event('Incorrect number of inputs to UpdateHistogram', 'ERROR');
end

% Clear and set reference to axis
cla(varargin{1}, 'reset');
axes(varargin{1});
Event('Current plot set to histogram display');

% Turn off the display while building
set(allchild(varargin{1}), 'visible', 'off'); 
set(varargin{1}, 'visible', 'off');

% Disable export button
set(handles.exportplot_button, 'enable', 'off');

% Execute code block based on display GUI item value
switch varargin{2}
    
    % Planned DVH
    case 2
        
        % Log plot selection
        Event('Planned dose volume histogram selected');
        
    
        
        
        
        
end

% Log completion
Event(sprintf('Plot updated successfully in %0.3f seconds', toc));

% Catch errors, log, and rethrow
catch err
    Event(getReport(err, 'extended', 'hyperlinks', 'off'), 'ERROR');
end