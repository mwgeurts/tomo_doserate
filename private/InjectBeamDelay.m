function rate = InjectBeamDelay(rate, plan, delay)
% InjectBeamDelay adds a given delay between each beam in a calculated dose
% rate sparse matrix. Upon completion, a modified sparse array structure is
% returned.
%
% The following inputs are required:
%
%   rate:   structure containing dose rate sparse array. The 'time' field
%           is modified and returned. See CalcDoseRate() for more 
%           information on the format of this structure.
%   plan:   structure containing plan information. The 'NumOfProjections'
%           field is required. See LoadPlan() for more information.
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


