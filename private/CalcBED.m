function bed = CalcBED(varargin)
% CalcBED calculates the Biologically Effecive Dose of a dose volume
% given a dose rate (calculated by CalcDoseRate) and biological model
% function handle. In addition to computing the  (provided) variable dose 
% rate BED, the continuous BED (assuming dose is delivered 
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
%   *params:        A vector of model parameters to get passed to the model 
%                   function. Alternatively, params can be a 2D array of 
%                   length n x m, where n is the number of voxels defined 
%                   in the dose rate structure and m is the number of
%                   parameters. This allows spatially variant parameters.
%   *repeat:        optional integer indicating the number of times to 
%                   repeat the dose rate calculation. Can be used to 
%                   simulate multiple  back to back deliveries of the same 
%                   plan.
%   *time:          if provided, this time vector is used instead of the
%                   one provided in the rate input structure. It must be
%                   the same length as size(rate.sparse, 2);
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
    elseif strcmpi(varargin{i}, 'time')
        time = varargin{i+1};
    end
end

% Store function name in return structure
bed.model = func2str(model);

% Store the number of voxels
n = size(rate.indices, 1);

% Initialize return matrices
bed.variable = zeros(max(rate.indices(:,1)), max(rate.indices(:,2)), ...
    max(rate.indices(:,3)));
bed.continuous = zeros(size(bed.variable));
bed.instant = zeros(size(bed.variable));

% If a valid screen size is returned (MATLAB was run without -nodisplay)
if usejava('jvm') && feature('ShowFigureWindows')
    
    % Start waitbar
    progress = waitbar(0, 'Calculating BED');
end

% If time is provided, use it rather than sparse matrix time
if exist('time', 'var')
    time = repmat(time, 1, repeat);
else
    time = repmat(rate.time, 1, repeat);
end

% Repeat time vector, adding onto previous values
for j = 2:repeat
    time((1+(j-1)*length(rate.time)):(j*length(rate.time))) = ...
        time((1+(j-1)*length(rate.time)):(j*length(rate.time))) + ...
        (j-1) * (max(rate.time) + rate.scale);
end
time = [0 time(1:end-1)];

% Repeat parameters, if not already repeated
if exist('params', 'var') && size(params, 1) == 1 
   params = repmat(params, n, 1); 
elseif exist('params', 'var') && size(params, 2) == 1
   params = repmat(params', n, 1); 
end

% Store current waitbar progress
c = 0;

% Find indices of non-zero voxels
[idx, ~, ~] = find(rate.sparse);
idx = unique(idx);
n = length(idx);

% Log beginning of computation and start timer
if exist('Event', 'file') == 2
    Event(sprintf(['Calculating BED using the %s function across ', ...
        '%i non-zero voxels'], bed.model, n));
    t = tic;
end

% Loop through each non-zero voxel
for i = 1:n

    % Update waitbar if 2% progress has been made
    if i/n - c > 0.02 && exist('progress', 'var') && ishandle(progress)
        c = i/n;        
        r = (n-i) * toc(t) / i;
        waitbar(c, progress, sprintf(['Calculating BED ', ...
        '(%02.0f:%02.0f:%02.0f remaining)'], floor(r / 3600), ...
        floor(mod(r, 3600) / 60), mod(r, 60)));
    end
        
    % Convert and repeat dose rate
    drate = repmat(full(rate.sparse(idx(i), :)), 1, repeat);

    % Execute model function for variable dose rate
    if exist('params', 'var')
        bed.variable(idx(i)) = model(drate(1:end-1), time, params(idx(i),:));
    else
        bed.variable(idx(i)) = model(drate(1:end-1), time);
    end

    % Execute model function assuming continuous delivery
    if exist('params', 'var')
        bed.continuous(idx(i)) = model(ones(1,length(drate)-1) * ...
            sum(drate(1:end-1)) / (length(drate)-1), time, params(i,:));
    else
        bed.continuous(idx(i)) = model(ones(1,length(drate)) * ...
            sum(drate(1:end-1)) / (length(drate)-1), time);
    end

    % Execute model function assuming instantaneous delivery
    if exist('params', 'var')
        bed.instant(idx(i)) = model(sum(drate(1:end-1) .* diff(time)) / ...
            1e-10, [0 1e-10], params(idx(i),:));
    else
        bed.instant(idx(i)) = model(sum(drate(1:end-1) .* diff(time)) / ...
            1e-10, [0 1e-10]);
    end
end

% Update waitbar
if exist('progress', 'var') && ishandle(progress)
    waitbar(1, progress, 'Completed!');
    close(progress);
end

% Log dose calculation completion
if exist('Event', 'file') == 2
    Event(sprintf('BED calculation completed in %0.3f seconds', toc(t)));
end

% Clear temporary variables
clear rate structures model params repeat drate time t n i j idx;