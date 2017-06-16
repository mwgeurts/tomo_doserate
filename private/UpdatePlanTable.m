function handles = UpdatePlanTable(handles)


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

if isfield(handles.plan, 'numberOfProjections')
    n = sprintf('%i', length(handles.plan.numberOfProjections));
else
    n = 'N/A';
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
    'Total Fraction Time'   'N/A'
};
set(handles.plan_table, 'Data', data);
set(handles.plan_table, 'Enable', 'on');