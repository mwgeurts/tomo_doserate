function equivdr = CalcEquivDoseRate(bed, time, model, params)
% CalcEquivDoseRate computes the equivalent continuous irradiation rate
% on a voxel to voxel basis given an expected BED. This is used by 
% TomoDoseRate to compute the equivalent dose rate for each structure.
% Upon successful completion, a 3D volume of the same dimensions as the
% provided "bed" input argument is returned containing the dose rate, in
% Gy/sec.
%
% The following inputs are required:
%
%   bed:    a 3D volume of expected BED values from which to compute the
%           equivalent dose rate for.
%   time:   double indicating the time, in seconds, during which the
%           continuous dose rate is computed.
%   model:  a string indicating which model to use when computing the
%           equivalent dose rate. See the switch statement below for a list
%           of available dose rates.
%   params: either a vector of parameters corresponding to the provided
%           model, or an m x n array of n parameters for each voxel m. The
%           number of elements in bed must equal m.
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

% Repeat parameters, if not already repeated
if size(params, 1) == 1 
   params = repmat(params, numel(bed), 1); 
elseif size(params, 2) == 1
   params = repmat(params', numel(bed), 1); 
end

% Log beginning of computation and start timer
if exist('Event', 'file') == 2
    Event(sprintf('Computing the equivalent dose rate for %i voxels', ...
        numel(bed)));
end

% Initialize empty return array
equivdr = zeros(size(bed));

% Compute equivalent dose rate based off model function
switch model
    
    % For biexponential datasets
    case 'BiExponential'
        
        % Define alpha/beta ratio in Gy
        ab = params(:, 1);

        % Define half lives, in seconds
        h = params(:, 2:3);

        % Define proportions
        p = params(:, 4:5);
        
        % Compute dose protraction factors for continuous irradiation
        g = 2 * h ./ (log(2) * time) .* (1 - h ./ (log(2) * time) .* ...
            (1 - exp(-time .* log(2) ./ h)));
        
        % Solve quadratic equation (there will be two solutions)
        d1 = -sum(p .* g ./ sum(p,2), 2) ./ (2 * ab) + ...
            sqrt((sum(p .* g ./ sum(p,2), 2) ./ ab) .^ 2 + 4 * ...
            reshape(bed, [], 1));
        d2 = -sum(p .* g ./ sum(p,2), 2) ./ (2 * ab) - ...
            sqrt((sum(p .* g ./ sum(p,2), 2) ./ ab) .^ 2 + 4 * ...
            reshape(bed, [], 1));
        
        % Store the larger of the two
        equivdr = reshape(max(d1, d2), size(bed)) / time;
        
end