function matrix = SetAlphaBetaRatio(alphabeta, structures, types)
% SetAlphaBetaRatio creates a 3D array of alpha/beta ratios given a cell
% array of structures and a vector of indices. If structures overlap, the
% priority will be given to the structure with the lowest index type.
% Voxels that are not specified by any structure will return with a ratio
% equal to the value of the last index.
%
% The following inputs are required:
%   alphabeta:  cell array of types and alpha/beta ratios, where
%               alphabeta(:,1) is a cell array of types, and alphabeta(:,2)
%               is an array of numeric ratios
%   structures: cell array of structures. The 'mask' fields are used for 
%               each structure. See LoadStructures() for more information 
%               the format of this cell array. At least one structure must
%               exist
%   types:      cell array of types and alpha/beta ratios
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

% Verify the first structure contains a mask
if ~isfield(structures{1}, 'mask')
    if exist('Event', 'file') == 2
        Event(['The first structure does not contain an image mask. ', ...
            'Alpha/beta determination failed.'], 'ERROR');
    else
        error(['The first structure does not contain an image mask. ', ...
            'Alpha/beta determination failed.']);
    end
end

% Log action and start timer
if exist('Event', 'file') == 2
    Event('Setting alpha/beta ratios for each voxel using structure types');
    t = tic;
end

% Flip the alpha/beta cell array
alphabeta = flip(alphabeta,2);

% Initialize indices matrix
indices = ones(size(structures{1}.mask));

% Loop through each structure
for i = 1:length(structures)
    
    % Find index
    idx = find(strcmp(types{i}, alphabeta(1,:)));
    
    % Update matrix indices
    indices = max(indices, structures{i}.mask * idx);
end

% Store values as vector
ab = cell2mat(alphabeta(2,:));

% Convert matrix to alpha/beta ratios
matrix = reshape(ab(indices), size(structures{1}.mask));

% Log completion
if exist('Event', 'file') == 2
    Event(sprintf('Alpha/beta ratios set in %0.3f seconds', toc(t)));
end

% Clear temporary variables
clear alphabeta indices ab i idx;


