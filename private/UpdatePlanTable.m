function handles = UpdatePlanTable(handles)


% If plan data does not exist, just return
if ~isfield(handles, 'plan') || isempty(handles.plan)
    return;
end

% Fill in missing data
if ~isfield(handles.plan, 'machine')
    handles.plan.machine = '';
end
if isfield(handles.plan, 'frontField') && isfield(handles.plan, 'backField')
    width = sprintf('%0.3f cm', ...
        sum(abs([handles.plan.frontField, handles.plan.backField])));
else
    width = 'N/A';
end

% If fraction dose data and delay exists
if isfield(handles.plan, 'rxDose') && isfield(handles.plan, 'fractions') ...
        && isfield(handles, 'repeat') && handles.repeat > 0
    dose = sprintf('%0.1f Gy', handles.plan.rxDose / ...
        handles.plan.fractions * handles.repeat);
else 
    dose = 'N/A';
end

% If projection data exists
if isfield(handles.plan, 'numberOfProjections')
    n = sprintf('%i', length(handles.plan.numberOfProjections));
else
    n = 'N/A';
end

% If dose rate data
if isfield(handles, 'rate') && ~isempty(handles.rate) && ...
        isfield(handles.plan, 'numberOfProjections')
    
    time = sprintf('%0.1f min', handles.rate.time(end)/60 * handles.repeat + ...
        handles.delay * (handles.repeat * ...
        length(handles.plan.numberOfProjections) - 1));
else
    time = 'N/A';
end

% Update plan information table
data = {    
    'Patient Name'          handles.plan.patientName
    'Machine'               handles.plan.machine
    'Plan Name'             handles.plan.planLabel
    'Plan Date/Time'        datestr(handles.plan.timestamp)
    'Plan Type'             handles.plan.planType
    'Number of Beams'       n
    'Field Size'            width           
    'Total Dose/Fx'         dose
    'Total Fraction Time'   time
};
set(handles.plan_table, 'Data', data);
set(handles.plan_table, 'Enable', 'on');