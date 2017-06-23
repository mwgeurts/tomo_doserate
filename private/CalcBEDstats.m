function stats = CalcBEDstats(structures, bed)
% CalcBEDstats computes the mean BED and effective dose rate for each
% structure in the provided structures cell array. The values are returned
% as a formatted cell array of strings

% Initialize retrn cell array
stats = cell(length(structures), 4);

% Loop through each structure
for i = 1:length(structures)
   
    % If variable BED data exists
    if ~isempty(bed) && isfield(bed, 'variable')
        
        % Compute variable mean BED
        varmean = mean(bed.variable(structures{i}.mask == 1));
        
        % Store variable mean BED
        stats{i,1} = sprintf('%0.1f Gy', varmean);
    end
    
    % If instant BED data exists
    if ~isempty(bed) && isfield(bed, 'instant')
        
        % Compute instant mean BED
        instmean = mean(bed.instant(structures{i}.mask == 1));
        
        % Store variable mean BED
        stats{i,2} = sprintf('%0.1f Gy', instmean);
    end
    
    % If continuous BED data exists
    if ~isempty(bed) && isfield(bed, 'continuous')
        
        % Store continuous mean
        contmean = mean(bed.continuous(structures{i}.mask == 1));
        
        % Store variable mean BED
        stats{i,3} = sprintf('%0.1f Gy', contmean);
    end
    
    % If variable and continuous BED data exists
    if ~isempty(bed) && isfield(bed, 'variable') && ...
            isfield(bed, 'continuous')
        
        % Store variable mean BED
        stats{i,4} = '';
    end
    
end