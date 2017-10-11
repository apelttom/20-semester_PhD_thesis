function varargout = test2(varargin)
% TEST2 M-file for test2.fig
%      TEST2, by itself, creates a new TEST2 or raises the existing
%      singleton*.
%
%      H = TEST2 returns the handle to a new TEST2 or the handle to
%      the existing singleton*.
%
%      TEST2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEST2.M with the given input arguments.
%
%      TEST2('Property','Value',...) creates a new TEST2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before test2_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to test2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help test2

% Last Modified by GUIDE v2.5 20-Oct-2005 16:00:18


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @test2_OpeningFcn, ...
                   'gui_OutputFcn',  @test2_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before test2 is made visible.
function test2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to test2 (see VARARGIN)

% Choose default command line output for test2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes test2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = test2_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
myValue = get(hObject, 'Value');
set(handles.edit1, 'String', num2str(myValue));
freePortSend(1, 115200, 1, 1, 0, myValue)  % set 'f' to 'myValue'


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

myValue = str2num(get(hObject,'String'));
if(~isempty(myValue))

    myMax = get(handles.slider1, 'Max');
    myMin = get(handles.slider1, 'Min');
    if(myValue < myMin)
        myValue = myMin;
    elseif(myValue > myMax)
        myValue = myMax;
    end

    set(handles.slider1, 'Value', myValue);
    set(hObject, 'String', num2str(myValue));
    freePortSend(1, 115200, 1, 1, 0, myValue)  % set 'f' to 'myValue'
end



% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.edit1, 'String', '2.84')
set(handles.slider1, 'Value', 2.84)
freePortSend(1, 115200, 1, 1, 0, 2.84)  % set 'f' to '2.84'



% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
myString = get(hObject, 'String');
f = get(handles.slider1, 'Value');
if(strcmp(myString, 'Excitation off'))
    set(hObject, 'String', 'Excitation on')
    set(handles.pushbutton3, 'String', 'Controller off')
    
    freePortSend(1, 115200, 1, 1, 0, f)  % set 'f' to '0'

    disp('Switching to sysID mode')
    freePortSend(1, 115200, 0, 1, 0, 2)  % switch to 'excitation' mode
else
    set(hObject, 'String', 'Excitation off')
    disp('Switching to off mode')

    freePortSend(1, 115200, 1, 1, 0, f)  % set 'f' to '0'
    freePortSend(1, 115200, 0, 1, 0, 1)  % switch to 'off' mode
end



% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
myString = get(hObject, 'String');
if(strcmp(myString, 'Controller off'))
    set(hObject, 'String', 'Controller on')
    set(handles.pushbutton2, 'String', 'Excitation off')
    
    disp('Switching to controller mode')
    freePortSend(1, 115200, 1, 1, 0, 0)  % set 'f' to '0'
    freePortSend(1, 115200, 0, 1, 0, 3)  % switch to 'control' mode
else
    set(hObject, 'String', 'Controller off')

    disp('Switching to off mode')
    freePortSend(1, 115200, 0, 1, 0, 1)  % switch to 'off' mode
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global accel1 accel2 pulse;

set(handles.pushbutton2, 'String', 'Excitation off')
set(handles.pushbutton3, 'String', 'Controller off')

% display data
axes(handles.axes1)     % control pulses
plot(pulse.time, pulse.signals.values, 'r.-');
grid
axis([0 30 -1 6]);

axes(handles.axes2)     % accelerometer 1
plot(accel1.time, accel1.signals.values, 'r.-');
grid
axis([0 30 2 3]);

axes(handles.axes3)     % accelerometer 2
plot(accel1.time, accel1.signals.values, 'r.-');
grid
axis([0 30 2 3]);



% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
myValue = get(hObject, 'Value');
if(myValue == 1)
    set(hObject, 'String', 'Controller on')
else
    set(hObject, 'String', 'Controller off')
end



% --- Executes on figure close...
function myClosereq(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global run;

run = 0;
disp('goodbye...')
closereq




% % -------------------------------------------------------------------------
% % local functions
% % -------------------------------------------------------------------------
% 
% function test3
% % open serial port and receive force data values
% 
% % construct serial port object
% myBuffer = 1000;
% sp_ID = serial('COM1', 'BaudRate', 115200, 'InputBufferSize', myBuffer);
% 
% % open serial port
% fopen(sp_ID);
% 
% % start measurment sequence
% fprintf(sp_ID, 's');
% 
% % read value from serial port with reference 'sp_ID'
% [force_data, nread] = fscanf(sp_ID, '%c', myBuffer-1);
% 
% % To disconnect the serial port object from the serial port.
% fclose(sp_ID); 
% 
% % plot results
% plot(double(force_data), 'g.-')
