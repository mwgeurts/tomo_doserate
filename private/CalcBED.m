function bed = CalcBED(varargin)
% CalcBED calculates the Biologically Effecive Dose of a dose volume
% given a dose rate (calculated by CalcDoseRate) and biological model
% function handle. If a structure set is provided, this function will also
% compute the BED for each structure. The return argument is a structure.
%
% The following name/value pairs can be provided as input arguments to this
% function. Values marked with an asterisk are optional.
%
%   rate:           structure containing dose rate sparse array and 
%                   supporting fields, returned from CalcDoseRate. The 
%                   'sparse', 'time', 'scale', and 'indices' fields are 
%                   used.
%   model:          a function handle to the function containing the 
%                   biological model. See BiExponential() for an example.
%   *params:        a variable containing the model parameters to get sent 
%                   to the model function. Can be an array, cell array, or
%                   structure. If not provided, or left empty, the model 
%                   function will be called with only the rate fields as 
%                   inputs.
%   *repeat:        optional integer indicating the number of times to 
%                   repeat the dose rate calculation. Can be used to 
%                   simulate multiple  back to back deliveries of the same 
%                   plan.
%   *structures:    optional cell array containing structures to compute 
%                   statistics for. See LoadStructures in the tomo_extract
%                   submodule for more information on the contents of this
%                   cell array.
%  
% The following structure fields are returned upon successful completion:
%
%   model:          string containing the name of the function handle
%   variable:       3D array of size defined by rate.indices of BED
%                   computed using the dose rates for each voxel in
%                   rate.sparse.
%   continuous:     3D array of size defined by rate.indices of BED
%                   assuming continuous irradiation rather than a variable
%                   dose rate.
%   instant:        3D array of size defined by rate.indices of BED
%                   assuming instantaneous delivery (i.e. no dose
%                   protraction factor).
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

% Define default values
repeat = 1;

% Loop through variable input arguments
for i = 1:2:length(varargin)
    
    % Store provided arguments
    if strcmpi(varargin{i}, 'rate')
        rate = varargin{i+1};
    elseif strcmpi(varargin{i}, 'model')
        model = varargin{i+1};
    elseif strcmpi(varargin{i}, 'params')
        params = varargin{i+1};
    elseif strcmpi(varargin{i}, 'repeat')
        repeat = varargin{i+1};
    elseif strcmpi(varargin{i}, 'structures')
        structures = varargin{i+1};
    end
end

% Store function name in return structure
bed.model = func2str(model);

% Store the number of voxels
n = size(rate.indices, 2);

% Initialize return matrices
bed.variable = zeros(max(rate.indices(1,:)), max(rate.indices(2,:)), ...
    max(rate.indices(3,:)));
bed.continuous = zeros(size(bed.variable));
bed.instant = zeros(size(bed.variable));

% Log beginning of computation and start timer
if exist('Event', 'file') == 2
    Event(sprintf(['Calculating BED using the %s function across ', ...
        '%i voxels'], bed.model, n));
    t = tic;
end

% If a valid screen size is returned (MATLAB was run without -nodisplay)
if usejava('jvm') && feature('ShowFigureWindows')
    
    % Start waitbar
    progress = waitbar(0, 'Calculating BED');
end

% Repeat time vector, adding onto previous values
time = repmat(rate.time, 1, repeat);
for j = 2:repeat
    time((1+(j-1)*length(rate.time)):(j*length(rate.time))) = ...
        time((1+(j-1)*length(rate.time)):(j*length(rate.time))) + ...
        (j-1) * (max(rate.time) + rate.scale);
end

% Loop through each voxel
for i = 1:n
    
    % Update waitbar
    if exist('progress', 'var') && ishandle(progress)
        waitbar(i/n, progress);
    end
    
    % Store dose rate vector
    drate = rate.sparse(i, :);
    
    % If sparse matrix is not empty for this array
    if find(drate,1) > 0
        
        % Convert and repeat dose rate
        drate = repmat(full(drate), 1, repeat);
        
        % Execute model function for variable dose rate
        if exist('params', 'var')
            bed.variable(rate.indices(1,i), rate.indices(2,i), ...
                rate.indices(3,i)) = model(drate, time, params);
        else
            bed.variable(rate.indices(1,i), rate.indices(2,i), ...
                rate.indices(3,i)) = model(drate, time);
        end
        
        % Execute model function assuming continuous delivery
        if exist('params', 'var')
            bed.continuous(rate.indices(1, i), rate.indices(2, i), ...
                rate.indices(3, i)) = model(ones(length(time), 1) * ...
                sum(drate) / length(time), time, params);
        else
            bed.continuous(rate.indices(1,i), rate.indices(2,i), ...
                rate.indices(3,i)) = model(ones(length(time),1) * ...
                sum(drate) / length(time), time);
        end
        
        % Execute model function assuming instantaneous delivery
        if exist('params', 'var')
            bed.instant(rate.indices(1,i), rate.indices(2,i), ...
                rate.indices(3,i)) = model(sum(drate) * plan.scale, 0, params);
        else
            bed.instant(rate.indices(1,i), rate.indices(2,i), ...
                rate.indices(3,i)) = model(sum(drate) * plan.scale, 0);
        end
    end
end


% Loop through each structure
if exist('structures', 'var')
    
    % Store length
    n = length(structures);

    % Log action
    Event(sprintf('Calculating BED values for %i structures', n));
    
    % Initialize return cell array
    bed.structures = cell(1, n);
    
    % Loop through structures
    for i = 1:n
       
        % Update waitbar
        if exist('progress', 'var') && ishandle(progress)
            waitbar(i/n, progress, 'Calculating Structure BEDs');
        end
        
        
        
        
        
    end
end

% Update waitbar
if exist('progress', 'var') && ishandle(progress)
    waitbar(1, progress, 'Completed!');
end

% Log dose calculation completion
if exist('Event', 'file') == 2
    Event(sprintf('BED calculation completed in %0.3f seconds', toc(t)));
end

% Clear temporary variables
clear rate structures model params repeat drate time t n i j;