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

% Last Modified by GUIDE v2.5 16-Jun-2017 09:39:19

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
handles.version_text = '0.1';

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
    sprintf('Version: %s (%s)', handles.version_text, handles.versionInfo{6});
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

% Log action
Event('Loading submodules');

% Execute AddSubModulePaths to load all submodules
AddSubModulePaths();

% Log action
Event('Loading configuration options');

% Execute ParseConfigOptions to load the global variables
handles = ParseConfigOptions(handles, 'config.txt');

% Set version_text UI text
set(handles.version_text, 'String', sprintf('Version %s', handles.version_text));





% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = TomoDoseRate_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in exporthist_button.
function exporthist_button_Callback(hObject, eventdata, handles)
% hObject    handle to exporthist_button (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in exporttable_button.
function exporttable_button_Callback(hObject, eventdata, handles)
% hObject    handle to exporttable_button (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in hist_menu.
function hist_menu_Callback(hObject, eventdata, handles)
% hObject    handle to hist_menu (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hist_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hist_menu


% --- Executes during object creation, after setting all properties.
function hist_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hist_menu (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function tcs_slider_Callback(hObject, eventdata, handles)
% hObject    handle to tcs_slider (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function tcs_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tcs_slider (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in tcs_button.
function tcs_button_Callback(hObject, eventdata, handles)
% hObject    handle to tcs_button (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function alpha_Callback(hObject, eventdata, handles)
% hObject    handle to alpha (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of alpha as text
%        str2double(get(hObject,'String')) returns contents of alpha as a double


% --- Executes during object creation, after setting all properties.
function alpha_CreateFcn(hObject, eventdata, handles)
% hObject    handle to alpha (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in tcs_menu.
function tcs_menu_Callback(hObject, eventdata, handles)
% hObject    handle to tcs_menu (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns tcs_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from tcs_menu


% --- Executes during object creation, after setting all properties.
function tcs_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tcs_menu (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in model_menu.
function model_menu_Callback(hObject, eventdata, handles)
% hObject    handle to model_menu (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns model_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from model_menu


% --- Executes during object creation, after setting all properties.
function model_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to model_menu (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in calcbed_button.
function calcbed_button_Callback(hObject, eventdata, handles)
% hObject    handle to calcbed_button (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function file_text_Callback(hObject, eventdata, handles)
% hObject    handle to file_text (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of file_text as text
%        str2double(get(hObject,'String')) returns contents of file_text as a double


% --- Executes during object creation, after setting all properties.
function file_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to file_text (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browse_button.
function browse_button_Callback(hObject, eventdata, handles)
% hObject    handle to browse_button (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in plan_menu.
function plan_menu_Callback(hObject, eventdata, handles)
% hObject    handle to plan_menu (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns plan_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plan_menu


% --- Executes during object creation, after setting all properties.
function plan_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plan_menu (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in calc_menu.
function calc_menu_Callback(hObject, eventdata, handles)
% hObject    handle to calc_menu (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns calc_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from calc_menu


% --- Executes during object creation, after setting all properties.
function calc_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to calc_menu (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in calcdose_button.
function calcdose_button_Callback(hObject, eventdata, handles)
% hObject    handle to calcdose_button (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in combine_button.
function combine_button_Callback(hObject, eventdata, handles)
% hObject    handle to combine_button (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in clear_button.
function clear_button_Callback(hObject, eventdata, handles)
% hObject    handle to clear_button (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in exportdicom_button.
function exportdicom_button_Callback(hObject, eventdata, handles)
% hObject    handle to exportdicom_button (see GCBO)
% eventdata  reserved - to be defined in a future version_text of MATLAB
% handles    structure with handles and user data (see GUIDATA)
