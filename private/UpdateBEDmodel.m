function varargout = UpdateBEDmodel(varargin)
% UpdateBEDmodel is called by TomoDoseRate when initializing or
% updating the BED model menu.  When called with no input arguments, this
% function returns a string cell array of available plots that the user can
% choose from.  When called with a GUI handles structure, will update
% handles.survival_axes based on the value of handles.model_menu and the 
% values in handles.params_table.
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

% Specify model options and order
modeloptions = {
    'Bi-exponential BED'
};

% If no input arguments are provided
if nargin == 0
    
    % Return the plot options
    varargout{1} = modeloptions;
    
    % Stop execution
    return;
    
% Otherwise, if 1, set the input variable and update the plot
elseif nargin == 1
    
    % Set input variables
    handles = varargin{1};

    % Log start
    Event('Updating BED plot display and model params (if changed)');
    timer = tic;
    
% Otherwise, throw an error
else 
    Event('Incorrect number of inputs to UpdateBEDmodel', 'ERROR');
end

% Execute code block based on display GUI item value
switch get(handles.model_menu, 'Value')
    
    % Bi-exponential BED model
    case 1
        
        % If the model was changed
        if ~isfield(handles, 'model') || ...
                get(handles.model_menu, 'Value') ~= handles.model
            
            % Log choice
            models = get(handles.model_menu, 'String');
            Event([models{get(handles.model_menu, 'Value')}, ...
                    ' model selected']);
            
            % Update table parameters 
            params = cell(7,2);
            
            % Add tumor/early alpha/beta
            params{1,1} = [handles.ratios{1,1}, '/', lower(handles.ratios{1,2}), ...
                ' alpha/beta ratio'];
            if isfield(handles.config, 'ALPHA_BETA_1')
                params{1,2} = handles.config.ALPHA_BETA_1;
            end
            
            % Set late alpha/beta ratio
            params{2,1} = [handles.ratios{1,3}, ' alpha/beta ratio'];
            if isfield(handles.config, 'ALPHA_BETA_3')
                params{2,2} = handles.config.ALPHA_BETA_3;
            end
            
            % Set short repair half life
            params{3,1} = 'Short repair half life';
            if isfield(handles.config, 'REPAIR_HALF_SHORT')
                params{3,2} = [handles.config.REPAIR_HALF_SHORT, ' hr'];
            end
            
            % Set long repair half life
            params{4,1} = 'Long repair half life';
            if isfield(handles.config, 'REPAIR_HALF_LONG')
                params{4,2} = [handles.config.REPAIR_HALF_LONG, ' hr'];
            end
            
            % Set proportion
            params{5,1} = 'Short:long repair proportion';
            if isfield(handles.config, 'SHORT_REPAIR_RATIO')
                c = str2double(handles.config.SHORT_REPAIR_RATIO);
                params{5,2} = sprintf('%0.0f:%0.0f', c*100, (1-c)*100);
            end
            
            % Set time between beams
            params{6,1} = 'Delay between beams';
            params{6,2} = '0 min';
            
            % Set repeat parameter
            params{7,1} = 'Number of times beams are delivered';
            params{7,2} = '1';
            
            % Update saved model selection
            handles.model = get(handles.model_menu, 'Value');
            
            % Clear temporary variables
            clear models c;
        else 
        
            % Get table contents
            params = get(handles.params_table, 'Data');
        end
        
        % Parse out parameters
        handles.ratios{2,1} = sscanf(params{1,2}, '%f');
        handles.ratios{2,2} = sscanf(params{1,2}, '%f');
        handles.ratios{2,3} = sscanf(params{2,2}, '%f');
        handles.half(1) = sscanf(params{3,2}, '%f') * 3600;
        handles.half(2) = sscanf(params{4,2}, '%f') * 3600;
        handles.prop = str2double(strsplit(params{5,2}, ':')) / 100;
        handles.delay = sscanf(params{6,2}, '%f');
        handles.repeat = round(sscanf(params{7,2}, '%f'), 0);
        
        % Hide plot
        set(allchild(handles.bed_axes), 'visible', 'off'); 
        set(handles.bed_axes, 'visible', 'off');

        % Disable calculate button
        set(handles.calcbed_button, 'Enable', 'off'); 
        
        % Verify values
        if length(handles.prop) ~= 2

            % Display warning
            warndlg('The proportion must be in the format 50:50');
            Event('The proportion must be in the format 50:50', 'WARN');
        
        elseif ~(handles.prop(1) >= 0 && handles.prop(2) >= 0 && ...
                sum(handles.prop) == 1)
            
            % Display warning
            warndlg('The proportions must sum to 100 and be non-negative');
            Event('The proportions must sum to 100 and be non-negative', ...
                'WARN');
            
        elseif ~(handles.ratios{2,1} >= 0 && handles.ratios{2,3} >= 0 && ...
                handles.half(1) >= 0 && handles.half(2) >= 0)

            % Display warning
            warndlg(['The alpha/beta and half life values must be ', ...
                'greater than or equal to zero']);
            Event(['The alpha/beta and half life values must be ', ...
                'greater than or equal to zero'], 'WARN');
            
        elseif handles.repeat <= 0

            % Display warning
            warndlg(['The number of times all beams are delivered must be ', ...
                'greater than zero']);
            Event(['The number of times all beams are delivered must be ', ...
                'greater than zero'], 'WARN');
        else
            
            % Re-format table
            params{1,2} = sprintf('%0.1f', handles.ratios{2,1});
            params{2,2} = sprintf('%0.1f', handles.ratios{2,3});
            params{3,2} = sprintf('%0.1f hr', handles.half(1)/3600);
            params{4,2} = sprintf('%0.1f hr', handles.half(2)/3600);
            params{5,2} = sprintf('%0.0f:%0.0f', handles.prop(1)*100, ...
                handles.prop(2)*100);
            params{6,2} = sprintf('%0.1f min', handles.delay);
            params{7,2} = sprintf('%i', handles.repeat);
            
            % Update parameters table
            set(handles.params_table, 'Data', params);
            
            % Update plot
            Event('Updating BED plot');

            % Define alpha/beta ratios
            ab(1) = handles.ratios{2,1};
            ab(2) = handles.ratios{2,3};
            
            % Define irradiation time axes (in hours)
            time = 0:0.01:2;

            % Define fraction doses
            d = [2 5 10 20];

            % Compute dose protraction factors
            h = repmat(handles.half', 1, length(time)) / 3600;
            t = repmat(time, length(handles.half), 1);
            g = 2 * h ./ (log(2) * t) .* (1 - h ./ (log(2) * t) .* ...
                (1 - exp(-t .* log(2) ./ h)));
            g(isnan(g)) = 1;

            % Compute BEDs (will result in a 4D matrix)
            bed = repmat(reshape(d,1,1,[]), length(handles.half), length(time), 1, ...
                length(ab)) .* (1 + repmat(g, 1, 1, length(d), length(ab)) .* ...
                repmat(reshape(d,1,1,[]), length(handles.half), length(time), 1, ...
                length(ab)) ./ repmat(reshape(ab,1,1,1,[]), length(handles.half), ...
                length(time), length(d), 1));

            % Compute weighted average of half lives, making BED a 3D matrix
            bed = squeeze(sum(bed .* repmat(handles.prop', 1, length(time), length(d), ...
                length(ab)), 1));

            % Set axes
            axes(handles.bed_axes);

            % Define colormap
            cmap = colormap('lines');

            % Define plot lines
            lines = {'-', '--', ':', '.-'};

            % Plot the first dose level and alpha-beta
            plot(time, bed(:,1,1) / bed(1,1,1), 'LineStyle', lines{1}, ...
                'Color', cmap(1,:));

            % Hold plot
            hold on;

            % Loop through remaining dose levels
            for i = 2:length(d)

                % Plot next dose level for this alpha-beta
                plot(time, bed(:,i,1) / bed(1,i,1), 'LineStyle', lines{1}, ...
                    'Color', cmap(i,:));
            end

            % Loop through remaining alpha-betas
            for j = 2:length(ab)

                % Loop through alpha-betas
                for i = 1:length(d)

                    % Plot remaining plots
                    plot(time, bed(:,i,j) / bed(1,i,j), 'LineStyle', lines{j}, ...
                        'Color', cmap(i,:));
                end
            end

            % Stop holding
            hold off;

            % Add grid
            grid on;

            % Add legend
            l = cell(length(d),1);
            for i = 1:length(d)
                l{i} = sprintf('%i Gy/fx', d(i));
            end
            legend(l, 'Location', 'southwest');

            % Set axis limits and ticks
            xticks(0:0.5:max(time));
            xlim([0 max(time)]);
%             yticks(0:0.1:1);
%             ylim([0.5 1]);

            % Add axis labels, title
            title({'BED for prolonged delivery', ...
                ['solid = ', lower(handles.ratios{1,1}), '/', ...
                lower(handles.ratios{1,2}), ', dashed = ', ...
                lower(handles.ratios{1,3})]});
            xlabel('Duration of single fraction (hours)');
            ylabel('Relative BED');

            % Show plot
            set(handles.bed_axes, 'visible', 'on');

            % If plan data exists
            if isfield(handles, 'plan') && ~isempty(handles.plan)

                % Update plan parameters
                handles = UpdatePlanTable(handles);
                
                % If dose rate data exists
                if isfield(handles, 'rate') && ~isempty(handles.rate) 
                
                    % Enable calculate button
                    set(handles.calcbed_button, 'Enable', 'on'); 
                end
            end

            % Clear temporary variables
            clear params time d h t g bed i j;
        end
end

% Log completion
Event(sprintf('BED plot updated successfully in %0.3f seconds', toc(timer)));

% Clear temporary variables
clear t;

% Return the modified handles
varargout{1} = handles; 