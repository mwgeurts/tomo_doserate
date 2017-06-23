function varargout = TomoDoseRate(varargin)
%
%
% ADD DESCRIPTION HERE
%
%
% Author: Mark Geurts, mark.w.geurts@gmail.com
% Copyright (C) 2017 University of Wisconsin Board of Regents
%
% This program is free software: you can redistribute it and/or modify it 
% under the terms of the GNU General Public License as published by the  
% Free Software Foundation, either version_text 3 of the License, or (at your 
% option) any later version_text.
%
% This program is distributed in the hope that it will be useful, but 
% WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General 
% Public License for more details.
% 
% You should have received a copy of the GNU General Public License along 
% with this program. If not, see http://www.gnu.org/licenses/.

% Edit the above text to modify the response to help TomoDoseRate

% Last Modified by GUIDE v2.5 20-Jun-2017 13:13:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TomoDoseRate_OpeningFcn, ...
                   'gui_OutputFcn',  @TomoDoseRate_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TomoDoseRate_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TomoDoseRate (see VARARGIN)

% Turn off MATLAB warnings
warning('off','all');

% Choose default command line output for ExitDetector
handles.output = hObject;

% Set version_text handle
handles.version = '0.1';

% Determine path of current application
[path, ~, ~] = fileparts(mfilename('fullpath'));

% Set current directory to location of this application
cd(path);

% Clear temporary variable
clear path;

% Set version_text information.  See LoadVersionInfo for more details.
handles.versionInfo = LoadVersionInfo;

% Store program and MATLAB/etc version_text information as a string cell array
string = {'TomoTherapy Dose Rate/BED Calculator'
    sprintf('Version: %s (%s)', handles.version, handles.versionInfo{6});
    sprintf('Author: Mark Geurts <mark.w.geurts@gmail.com>');
    sprintf('MATLAB Version: %s', handles.versionInfo{2});
    sprintf('MATLAB License Number: %s', handles.versionInfo{3});
    sprintf('Operating System: %s', handles.versionInfo{1});
    sprintf('CUDA: %s', handles.versionInfo{4});
    sprintf('Java Version: %s', handles.versionInfo{5})
};

% Add dashed line separators      
separator = repmat('-', 1,  size(char(string), 2));
string = sprintf('%s\n', separator, string{:}, separator);

% Log information
Event(string, 'INIT');

% Initialize data handles
Event('Initializing data variables');
handles = ClearAllData(handles);

% Log action
Event('Loading submodules');

% Execute AddSubModulePaths to load all submodules
AddSubModulePaths();

% Log action
Event('Loading configuration options');

% Execute ParseConfigOptions to load the global variables
handles = ParseConfigOptions(handles, 'config.txt');

% Set version_text UI text
set(handles.version_text, 'String', sprintf('Version %s', handles.version));

% Set structure type options
handles.struct_table.ColumnFormat{3} = handles.ratios(1, :);

% Set BED plot options
options = UpdateBEDmodel();
set(handles.model_menu, 'String', options);

% Set TCS plot options
options = UpdateDoseDisplay();
set(handles.tcs_menu, 'String', options);

% Set results plot options
options = UpdateHistogram();
set(handles.hist_menu, 'String', options);

% Set dose calculator options
options = {'Standalone GPU Calculator'};
set(handles.calc_menu, 'String', options);

% Set BED model default
set(handles.model_menu, 'Value', 1);
handles = UpdateBEDmodel(handles);

% Set dose calculator default
if isfield(handles.config, 'DEFAULT_CALC_METHOD')
    set(handles.calc_menu, 'Value', ...
        str2double(handles.config.DEFAULT_CALC_METHOD));
else
    set(handles.calc_menu, 'Value', 1);
end

% Clear temporary variables
clear options;

% Configure Dose Calculation
handles = SetDoseCalculation(hObject, handles);

% If an atlas file is specified in the config file
if isfield(handles.config, 'ATLAS_FILE')
    
    % Attempt to load the atlas
    handles.atlas = LoadAtlas(handles.config.ATLAS_FILE);
    
% Otherwise, declare an empty atlas
else
    handles.atlas = cell(0);
end

% Report initilization status
Event(['Initialization completed successfully. Start by selecting a ', ...
    'patient archive.']);

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = TomoDoseRate_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function exporthist_button_Callback(hObject, eventdata, handles)
% hObject    handle to exporthist_button (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function exporttable_button_Callback(hObject, eventdata, handles)
% hObject    handle to exporttable_button (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hist_menu_Callback(hObject, ~, handles)
% hObject    handle to hist_menu (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Execute UpdateHistogram
handles = UpdateHistogram(handles);
  
% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hist_menu_CreateFcn(hObject, ~, ~)
% hObject    handle to hist_menu (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Popupmenu controls usually have a white background on Windows.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tcs_slider_Callback(hObject, ~, handles)
% hObject    handle to tcs_slider (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update plot
handles.tcsplot.Update('slice', round(get(hObject, 'Value')));

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tcs_slider_CreateFcn(hObject, ~, ~)
% hObject    handle to tcs_slider (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tcs_button_Callback(hObject, ~, handles)
% hObject    handle to tcs_button (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Based on current tcsview handle value
switch handles.tcsview
    
    % If current view is transverse
    case 'T'
        handles.tcsview = 'C';
        Event('Updating viewer to Coronal');
        
    % If current view is coronal
    case 'C'
        handles.tcsview = 'S';
        Event('Updating viewer to Sagittal');
        
    % If current view is sagittal
    case 'S'
        handles.tcsview = 'T';
        Event('Updating viewer to Transverse');
end

% Re-initialize image viewer with new T/C/S value
handles.tcsplot.Initialize('tcsview', handles.tcsview);

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function alpha_Callback(hObject, ~, handles)
% hObject    handle to alpha (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% If the string contains a '%', parse the value
if ~isempty(strfind(get(hObject, 'String'), '%'))
    value = sscanf(get(hObject, 'String'), '%f%%');
    
% Otherwise, attempt to parse the response as a number
else
    value = str2double(get(hObject, 'String'));
end

% Bound value to [0 100]
value = max(0, min(100, value));

% Log event
Event(sprintf('Dose transparency set to %0.0f%%', value));

% Update string with formatted value
set(hObject, 'String', sprintf('%0.0f%%', value));

% Update viewer with current slice and transparency value
handles.tcsplot.Update('alpha', value/100);

% Clear temporary variable
clear value;

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function alpha_CreateFcn(hObject, ~, ~)
% hObject    handle to alpha (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Edit controls usually have a white background on Windows.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tcs_menu_Callback(hObject, ~, handles)
% hObject    handle to tcs_menu (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Execute UpdateDoseDisplay
handles = UpdateDoseDisplay(handles);
  
% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tcs_menu_CreateFcn(hObject, ~, ~)
% hObject    handle to tcs_menu (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Popupmenu controls usually have a white background on Windows.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function model_menu_Callback(hObject, ~, handles)
% hObject    handle to model_menu (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Execute UpdateBEDmodel
handles = UpdateBEDmodel(handles);
  
% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function model_menu_CreateFcn(hObject, ~, ~)
% hObject    handle to model_menu (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Popupmenu controls usually have a white background on Windows.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function calcbed_button_Callback(hObject, ~, handles)
% hObject    handle to calcbed_button (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% If a dose rate has been calculated
if isfield(handles, 'rate') && ~isempty(handles.rate)

    % Log action
    Event('Preparing BED inputs');

    % Inject inter-beam delays into time vector, assuming provided delay 
    % is in minutes
    time = InjectBeamDelay(handles.rate.time, handles.plan, ...
        handles.delay * 60);

    % Get table contents
    t = get(handles.struct_table, 'Data');

    % Calculate alpha/beta ratio for each voxel
    ab = SetAlphaBetaRatio(handles.ratios, ...
        handles.image.structures, t(:,3));
    
    % Execute code block based on display GUI item value
    switch get(handles.model_menu, 'Value')

        % Bi-exponential BED model
        case 1
            
            % Store function handle
            fcn = @BiExponential;
            
            % Store remaining model parameters
            params = horzcat(reshape(ab, [], 1), repmat(handles.half, ...
                numel(handles.image.data), 1), repmat(handles.prop, ...
                numel(handles.image.data), 1));
            
            % Clear temporary variables
            clear t ab;
    end
        
    % Execute CalcBED()
    handles.bed = CalcBED('rate', handles.rate, 'model', fcn, ...
        'params', params, 'repeat', handles.repeat, 'structures', ...
        handles.image.structures, 'time', time);
    
    % Execute UpdateDoseDisplay 
    handles = UpdateDoseDisplay(handles);
    
    % Execute UpdateHistogram
    handles = UpdateHistogram(handles);
    
    % Calculate BED structure statistics
    data = get(handles.struct_table, 'Data');
    data(:,5:8) = CalcBEDstats(handles.image.structures, handles.bed);
    set(handles.struct_table, 'Data', data);
    
    % Clear temporary variables
    clear time ab fcn params data;
end

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function file_text_Callback(hObject, ~, handles)
% hObject    handle to file_text (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Reset with path/name, or clear if empty
if isfield(handles, 'name') && ~isempty(handles.name)
    set(hObject, 'String', fullfile(handles.path, handles.name));
else
    set(hObject, 'String', '');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function file_text_CreateFcn(hObject, ~, ~)
% hObject    handle to file_text (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Edit controls usually have a white background on Windows.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function browse_button_Callback(hObject, ~, handles)
% hObject    handle to browse_button (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Log event
Event('Patient archive browse button selected');

% ExecuteLoadPatientArchive
handles = BrowsePatientArchive(handles);

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plan_menu_Callback(hObject, ~, handles)
% hObject    handle to plan_menu (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Log selected plan UID
Event(sprintf('Plan UID %s selected to load', ...
    handles.planUIDs{get(hObject, 'Value')}));

% Execute SelectPlan
handles = SelectPlan(handles, get(hObject, 'Value'));
  
% Update handles structuref
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plan_menu_CreateFcn(hObject, ~, ~)
% hObject    handle to plan_menu (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Popupmenu controls usually have a white background on Windows.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function calc_menu_Callback(hObject, ~, handles)
% hObject    handle to calc_menu (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Log change
Event('Calculation menu option changed');

% Execute SetDoseCalculation
handles = SetDoseCalculation(hObject, handles);
  
% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function calc_menu_CreateFcn(hObject, ~, ~)
% hObject    handle to calc_menu (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Popupmenu controls usually have a white background on Windows.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function calcdose_button_Callback(hObject, ~, handles)
% hObject    handle to calcdose_button (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% If dose rate data already exists
if isfield(handles, 'rate') && ~isempty(handles.rate)
   
    % Ask the user if they want to clear it
    a = questdlg(['Calculated dose rate data already exists. Would you ', ...
        'like to clear it and re-compute?'], ...
        'Recompute Dose', 'Yes','No','No');
    
    % If they say yes, clear the rate and BED data
    if strcmp(a, 'Yes')
        handles.rate = [];
        handles.bed = [];
    
    % Otherwise, stop here
    else
        return;
    end
    
    % Clear temporary variables
    clear a ;
end

% Log action
Event('Preparing inputs for dose rate calculation');

% Execute CalcDoseRate()
handles.rate = CalcDoseRate('image', handles.image, 'plan', ...
    handles.plan, 'mask', CalcMask(handles.dose.data, ...
    handles.config.DOSE_FX_THRESHOLD, handles.config.STRUCT_THRESHOLD, ...
    handles.image.structures), 'threshold', ...
    handles.config.DOSE_ACCUM_THRESHOLD_GY, 'modelfolder', ...
    handles.config.MODEL_PATH, 'downsample', ...
    handles.config.DOWNSAMPLE_FACTOR);

% Execute UpdatePlanTable
handles = UpdatePlanTable(handles);

% Execute UpdateDoseDisplay
handles = UpdateDoseDisplay(handles);

% Execute UpdateHistogram
handles = UpdateHistogram(handles);

% Enable calculate BED button
set(handles.calcbed_button, 'Enable', 'on');

% Change load button to save
set(handles.loadmat_button, 'String', 'Save Stored Dose Rate');

% Log completion
Event(['Dose rates have now been calculated. You may now proceed to ', ...
    'compute BED histograms for each structure.']);

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function loadmat_button_Callback(hObject, ~, handles)
% hObject    handle to loadmat_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Execute function depending on whether dose rate data exists
if isfield(handles, 'rate') && ~isempty(handles.rate)
    
    % Execute SaveDoseRateFile()
    handles = SaveDoseRateFile(handles);
else
    
    % Execute LoadDoseRateFile()
    handles = LoadDoseRateFile(handles);

    % Execute UpdatePlanTable
    handles = UpdatePlanTable(handles);

    % Execute UpdateDoseDisplay
    handles = UpdateDoseDisplay(handles);

    % Execute UpdateHistogram
    handles = UpdateHistogram(handles);
end

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function combine_button_Callback(hObject, eventdata, handles)
% hObject    handle to combine_button (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function clear_button_Callback(hObject, ~, handles)
% hObject    handle to clear_button (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Execute clear all data to clear all variables
handles = ClearAllData(handles);

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function exportdicom_button_Callback(hObject, eventdata, handles)
% hObject    handle to exportdicom_button (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function params_table_CellEditCallback(hObject, ~, handles)
% hObject    handle to params_table (see GCBO)
% eventdata  structure with the following fields
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty 
%       if Data was not changed
%	Error: error string when failed to convert EditData to appropriate 
%       value for Data
% handles    structure with handles and user data (see GUIDATA)

% Clear BED
handles.bed = [];

% Execute UpdateBEDmodel
handles = UpdateBEDmodel(handles);

% Execute UpdatePlanTable
handles = UpdatePlanTable(handles);

% Execute UpdateDoseDisplay
handles = UpdateDoseDisplay(handles);

% Execute UpdateHistogram
handles = UpdateHistogram(handles);

% Clear BED structure statistics
data = get(handles.struct_table, 'Data');
data(:,5:8) = cell(length(handles.image.structures), 4);
set(handles.struct_table, 'Data', data);

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function struct_table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to params_table (see GCBO)
% eventdata  structure with the following fields
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty 
%       if Data was not changed
%	Error: error string when failed to convert EditData to appropriate 
%       value for Data
% handles    structure with handles and user data (see GUIDATA)

% Get current data
data = get(hObject, 'Data');
    
% If display value was changed
if eventdata.Indices(2) == 2

    % Update dose plot if it is displayed
    if get(handles.tcs_menu, 'Value') > 1 && ...
            strcmp(get(handles.tcs_slider, 'visible'), 'on')

        % Update display
        handles.tcsplot.Update('structuresonoff', data);
    end
    
    % Update edited Dx/Vx statistic
    handles.histogram.UpdatePlot('data', data);

% Otherwise, if alpha/beta was changed and differs
elseif eventdata.Indices(2) == 3 && ~isempty(eventdata.NewData)

    % Clear all BED data
    data(eventdata.Indices(1), 5:end) = cell(1, size(data,2)-4);
    set(hObject, 'Data', data);
end
% Clear temporary variable
clear data;

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function figure1_CloseRequestFcn(hObject, ~, ~) %#ok<*DEFNU>
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Log event
Event('Closing the Tomo Dose Rate Calculator application');

% Retrieve list of current timers
timers = timerfind;

% If any are active
if ~isempty(timers)
    
    % Stop and delete any timers
    stop(timers);
    delete(timers);
end

% Clear temporary variables
clear timers;

% Delete(hObject) closes the figure
delete(hObject);
