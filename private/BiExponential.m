function bed = BiExponential(drate, time, params)
% BiExponential computes the Biologically Effective Dose for a time
% dependent dose rate given by the input vectors drate and time, using a
% bi-exponential survival model and the general Lea-Catcheside dose 
% protraction factor.
%
% The following inputs are required:
%
%   drate:  vector of length n containing the dose rate, in Gy/sec
%   time:   vector of length n+1 containing the start/stop time of each bin
%   params: vector of model parameters: alpha/beta ratio, first repair half
%           life, second repair half life, and fraction of first and second 
%           repair half lives. Half lives should be in hours.
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

% Define alpha/beta ratio in Gy
ab = params(1);

% Define half lives, in seconds
h = params(2:3) * 3600;

% Define proportions
p = params(4:5);

% Compute integral dose, in Gy
d = sum(drate .* diff(time));

% Compute dose protraction factors
g(1) = 2 * sum(drate .* diff(time) .* cumsum(exp(-log(2)/h(1) * ...
    time(1:end-1)) .* diff(time) .* drate)) / (d ^ 2);
g(2) = 2 * sum(drate .* diff(time) .* cumsum(exp(-log(2)/h(2) * ...
    time(1:end-1)) .* diff(time) .* drate)) / (d ^ 2);

% Compute BED as weighted sum of both components
bed = sum(p .* (1 + g * d / ab) * d) / sum(p);



