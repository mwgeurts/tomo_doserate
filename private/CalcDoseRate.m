function rate = CalcDoseRate(varargin)
% CalcDoseRate is called by TomoDoseRate to compute the dose from each 
% projection in a TomoTherapy plan. The resulting differential dose is
% stored in a sparse matrix and returned as the structure rate. The indices
% of each voxel computed, as well as projections is also included in the
% structure.
%
% The following name/value pairs can be provided as input arguments to this
% function. Values marked with an asterisk are optional.
%
%   image:          a structure containing the CT image to be computed on.
%                   See the LoadImage function in tomo_extract for more
%                   information on the structure contents
%   plan:           a structure containing the TomoTherapy delivery plan.
%                   See the LoadPlan function in tomo_extract for more
%                   information on the structure contents
%   *downsample:    optional integer indicating the downsample factor. See
%                   CalcDose for more information on its effect.
%   *mask:          a 3D logical array, of the same size and image.data,
%                   informing this function what voxels to compute dose
%                   rate on. Only these voxels will be returned in the
%                   sparse matrix
%   *threshold:     a double indicating what incremental dose (in Gy/sec),
%                   below which a cumulative dose increase is recorded.
%   *modelfolder:   a string indicating the folder containing the beam
%                   model files. If not provided, './GPU' is assumed.
%   *maxmov:        a double indicating the time, in seconds across which
%                   to calculate the running average
%  
% The following structure fields are returned upon successful completion:
%
%   sparse:     a 2D sparse matrix of size m x n, where m is the number of
%               plan projections and n is the number of voxels that a dose
%               rate was calculated for. The values are the differential 
%               dose rate in Gy/sec (above a given threshold, if provided) 
%               of the dose to a given voxel at a given projection.
%   indices:    a 2D matrix of size 3 x n containing the voxel indices (x, 
%               y, and z) of each voxel in the sparse matrix.
%   scale:      a double indicating the projection time, in seconds.
%   mask:       if provided, the mask used for dose rate calculation.
%               Otherwise, a 3D array of ones the same size as image.data.
%   threshold:  if provided, the threshold used for dose rate calculation
%   error:      RMS difference between the sum of the integral dose over
%               the sparse array and the dose from the entire treatment.
%   max:        3D double array of maximum single-projection dose rates for 
%               each voxel within the mask (or entire image matrix if not 
%               provided).
%   maxmov:     3D double array of maximum running average dose rates for 
%               each voxel within the mask (or entire image matrix if not 
%               provided). Only included if 'maxmov' is provided as an
%               input argument name/value pair.
%   average:    3D double array of average non-zero dose rates for each
%               voxel within the mask (or entire image matrix if not 
%               provided).
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

% Loop through variable input arguments
for i = 1:2:length(varargin)
    
    % Store provided arguments
    if strcmpi(varargin{i}, 'plan')
        plan = varargin{i+1};
    elseif strcmpi(varargin{i}, 'image')
        image = varargin{i+1};
    elseif strcmpi(varargin{i}, 'mask')
        rate.mask = varargin{i+1};
    elseif strcmpi(varargin{i}, 'threshold')
        rate.threshold = varargin{i+1};
    elseif strcmpi(varargin{i}, 'modelfolder')
        modelfolder = varargin{i+1};
    elseif strcmpi(varargin{i}, 'maxmov')
        maxmov = varargin{i+1};
    elseif strcmpi(varargin{i}, 'downsample')
        downsample = varargin{i+1};
    end
end

% Check if MATLAB can find CalcDose
if exist('CalcDose', 'file') ~= 2
    
    % If not, throw an error
    if exist('Event', 'file') == 2
        Event('The function CalcDose is required for execution', 'ERROR');
    else
        error('The function CalcDose is required for execution');
    end
end

% Check if CalcDose is connected to an engine
if CalcDose() == 0
    
    % If not, throw an error
    if exist('Event', 'file') == 2
        Event('CalcDose is not connected to a calculation engine', 'ERROR');
    else
        error('CalcDose is not connected to a calculation engine');
    end
end

% If a model path was not provided, assume './GPU'
if ~exist('modelfolder', 'var')
    modelfolder = './GPU';
end

% If a mask was not provided, create one
if ~isfield(rate, 'mask')
    rate.mask = ones(size(image.data));
end

% If a threshold was not provided, use 0.1 mGy/sec
if ~isfield(rate, 'threshold')
    rate.threshold = 0.0001;
end

% Store the threshold as an absolute dose, using the plan scale
thresh = rate.threshold * plan.scale / plan.fractions;

% Verify mask size equals the image size
if ~isequal(size(image.data), size(rate.mask))

    % If not, throw an error
    if exist('Event', 'file') == 2
        Event('The dose mask must be the same size as the image', 'ERROR');
    else
        error('The dose mask must be the same size as the image');
    end
end

% Compute linear and x/y/z indices of each masked voxel
[rate.indices(:,1), rate.indices(:,2), rate.indices(:,3)] = ...
    ind2sub(size(image.data), 1:numel(image.data));

% Initialize return structure sparse matrix, estimating each masked voxel 
% to be irradiated across 100 projections
n = size(plan.sinogram, 2);
rate.sparse = spalloc(numel(image.data), n, length(find(rate.mask)) * 100);

% Store the plan scale
rate.scale = plan.scale;

% Log beginning of computation and start timer
if exist('Event', 'file') == 2
    Event(sprintf(['Calculating the dose rate for %i projections across ', ...
        '%i voxels using a threshold of %0.3f Gy/sec'], n, ...
        length(find(rate.mask)), rate.threshold));
    t = tic;
end

% If a valid screen size is returned (MATLAB was run without -nodisplay)
if usejava('jvm') && feature('ShowFigureWindows')
    
    % Start waitbar
    progress = waitbar(1/n, 'Calculating dose rate');
end

% Copy plan structure
modplan = plan;

% Create temporary sinogram with only first projection active
modplan.sinogram = horzcat(plan.sinogram(:, 1), ...
    zeros(size(plan.sinogram, 1), n-1));

% Log first projection
if exist('Event', 'file') == 2
    Event(sprintf('Calculating the dose rate for projection %i of %i', ...
        1, n));
end

% Check for downsample factor
if ~exist('downsample', 'var')
    downsample = 0;
end

% Calculate fraction dose for first projection (copying image data over)
% for each masked voxel
d = CalcDose(image, modplan, 'modelfolder', modelfolder, ...
    'downsample', downsample);
dose = reshape(d.data .* rate.mask / plan.fractions, 1, []);

% Store previous dose as calculated minus values less than the threshold
prevdose = dose;
prevdose(dose <= thresh) = 0;

% Store dose rates greater than the threshold
rate.sparse(dose > thresh, 1) = dose(dose > thresh);

% Loop through remainder of sinogram
for i = 2:n

    % Update waitbar
    if exist('progress', 'var') && ishandle(progress)
        r = (n-i) * toc(t) / i;
        waitbar(i/n, progress, sprintf(['Calculating dose rate ', ...
            '(%02.0f:%02.0f:%02.0f remaining)'], floor(r / 3600), ...
            floor(mod(r, 3600) / 60), mod(r, 60)));
    end
    
    % Log projection
    if exist('Event', 'file') == 2
        Event(sprintf('Calculating the dose rate for projection %i of %i', ...
            i, n));
    end

    % Update modified sinogram to the delivery up to this projection
    modplan.sinogram = horzcat(plan.sinogram(:, 1:i), ...
        zeros(size(plan.sinogram, 1), n-i));

    % Calculate fraction dose again (not copying the image data)
    d = CalcDose(modplan);
    dose = reshape(d.data .* rate.mask / plan.fractions, 1, []);
    
    % Store dose rates (relative to previous dose) greater than threshold
    rate.sparse((dose - prevdose) > thresh, i) = ...
        dose((dose - prevdose) > thresh);
    
    % Update previous dose
    prevdose((dose - prevdose) > thresh) = ...
        prevdose((dose - prevdose) > thresh) + ...
        dose((dose - prevdose) > thresh);
end

% Compute the RMS error
rate.error = sqrt(mean((dose - sum(rate.sparse, 2)) .^ 2));
if exist('Event', 'file') == 2
    Event('Dose rate integral RMS error = %0.3f Gy');
end

% Compute the average dose rate using cumulative dose
rate.average = reshape(dose, size(image.data,1), ...
    size(image.data, 2), size(image.data,3)) ./ (n * plan.scale);

% Divide the dose values by time to compute rate
rate.sparse = rate.sparse ./ rate.scale;

% Compute the maximum dose rates
Event('Computing maximum dose rates');
rate.max = reshape(max(rate.sparse, [], 2), size(image.data,1), ...
    size(image.data, 2), size(image.data,3));

% Compute the running average maximum dose rate (if specified)
if exist('maxmov', 'var')
   
    % Log moving average
    Event('Computing maximum dose rates using a %0.3f sec moving average');

    % Compute running average
    rate.maxmov = ...
        max(maxmov(rate.sparse, floor(maxmov / rate.scale), 2), [], 2);
end

% Update waitbar
if exist('progress', 'var') && ishandle(progress)
    waitbar(1, progress, 'Completed!');
end

% Log dose calculation completion
if exist('Event', 'file') == 2
    Event(sprintf(['Dose rate calculation completed in %0.3f minutes, ', ...
        'storing %i data elements (%0.1f per masked voxel)'], toc(t) / 60, ...
        nnz(rate.sparse), nnz(rate.sparse) / length(find(rate.mask))));
end

% Clear temporary variables
clear plan image modelfolder maxmov thresh dose t n i d r;

