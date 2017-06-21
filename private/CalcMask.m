function mask = CalcMask(varargin)
% CalcMask computes the 3D mask to compute the dose rate using structures
% and/or a dose threshold, depending on the configuration settings. This
% function can be called with two or four inputs, as described below, and
% will return a 3D logical array of the same size as the provided dose.
%
% The following inputs can be provided. If the structure flag is true, the
% structure cell array must also be provided:
%
%   varargin{1}:    3D dose array
%   varargin{2}:    double specifying the fractional dose (relative to the 
%                   max dose) above which the mask is true
%   varargin{3}:    optional flag indicating whether to also mask by
%                   structure (true)
%   varargin{4}:    cell array of structures. The 'mask' field is required 
%                   for each cell. See LoadStructures for more information 
%                   on the format of this cell array.
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

% If structure based thresholds are enabled
if nargin > 2 && varargin{3}
    
    % Log action
    Event('Applying structure masks');
    
    % Initialize empty mask
    mask = zeros(size(varargin{1}));
    
    % Loop through structures
    for i = 1:length(varargin{4})
       
        % Add structure mask
        mask = mask + varargin{4}{i}.mask;
    end
    
    % Log action
    Event('Applying dose threshold mask');
    
    % Add to dose threshold
    mask = (mask > 0) .* (varargin{1} / max(max(max(...
        varargin{1}))) > varargin{2});
else
    
    % Log action
    Event('Applying dose threshold mask');
    
    % Otherwise, only use dose threshold
    mask = varargin{1} / max(max(max(varargin{1}))) > varargin{2};
end