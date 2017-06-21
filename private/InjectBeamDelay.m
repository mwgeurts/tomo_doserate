function time = InjectBeamDelay(time, plan, delay)
% InjectBeamDelay adds a given delay between each beam in a time vector. 
% Upon completion, a modified time vector is returned.
%
% The following inputs are required:
%
%   time:   vector containing 
%   plan:   structure containing plan information. The 'startTrim' and
%           'stopTrim' fields are used. See LoadPlan() for more 
%           information.
%   delay:  The delay, in seconds, to add between each beam.
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

% If delay is zero, return without doing anything
if delay == 0
    return;
end

% If trimmed lengths aren't computed
if ~isfield(plan, 'trimmedLengths')
    
    % Initialize array
    l = zeros(1, length(plan.startTrim));
    
    % Compute them
    for i = 1:length(plan.startTrim)
        l(i) = plan.startTrim(i) - plan.stopTrim(i) + 1;
    end
else
    l = plan.trimmedLengths;
end

% Store cumulative sum of trimmed lengths
l = cumsum(l+1);

% Loop through each beam
for i = 1:length(l)
    
    % Add delay
    time(l(i):end) = time(l(i):end) + delay;
end

% Clear temporary variables
clear l i;