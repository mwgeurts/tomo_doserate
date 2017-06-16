function rate = CalculateDoseRate(varargin)
% CalculateDoseRates is called by TomoDoseRate to compute the dose from
% each projection in a TomoTherapy plan. The resulting differential dose is
% stored in a sparse matrix and returned as the structure rate. The indices
% of each voxel computed, as well as projections is also included in the
% structure.
%
% The following name/value pairs can be provided as input arguments to this
% function. Values marked with an asterisk are optional.
%
%   image:      a structure containing the CT image to be computed on. See
%               the LoadImage function in tomo_extract for more information 
%               on the structure contents
%   plan:       a structure containing the TomoTherapy delivery plan. See
%               the LoadPlan function in tomo_extract for more information 
%               on the structure contents
%   *mask:      a 3D logical array, of the same size and image.data,
%               informing this function what voxels to compute dose rate
%               on. Only these voxels will be returned in the sparse matrix
%   *threshold: a double indicating what incremental dose (in Gy), below
%               which a cumulative dose increase is recorded.
%  
% The following structure fields are returned upon successful completion:
%
%   sparse:     a 2D sparse matrix of size m x n, where m is the number of
%               plan projections and n is the number of voxels that a dose
%               rate was calculated for. The values are the differential 
%               dose rate (above a given threshold, if provided) of the
%               dose to a given voxel at a given projection.
%   indices:    a 2D matrix of size 3 x n containing the voxel indices (x, 
%               y, and z) of each voxel in the sparse matrix.
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

% Initialize return arg
rate = struct;

% Apply variable input arguments
for i = 1:2:length(varargin)
    
    % Store provided arguments
    if strcmpi(varargin{i}, 'plan')
        plan = varargin{i+1};
    elseif strcmpi(varargin{i}, 'image')
        image = varargin{i+1};
    elseif strcmpi(varargin{i}, 'mask')
        mask = varargin{i+1};
    elseif strcmpi(varargin{i}, 'threshold')
        threshold = varargin{i+1};
    end
end

% If a mask was not provided, create one
if ~exist('mask', 'var')
    mask = ones(size(image.data));
end

% Log beginning of DVH initialization and start timer
if exist('Event', 'file') == 2
    Event(sprintf(['Calculating the dose rate for %i projections across ', ...
        '%i voxels'], sum(plan.numberOfProjections), sum(sum(sum(mask)))));
    t = tic;
end









