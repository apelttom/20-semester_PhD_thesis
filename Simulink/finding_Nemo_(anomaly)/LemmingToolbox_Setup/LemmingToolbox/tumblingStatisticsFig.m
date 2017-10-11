function varargout = tumblingStatisticsFig(varargin)
% TUMBLINGSTATISTICSFIG M-file for tumblingStatisticsFig.fig
%      TUMBLINGSTATISTICSFIG, by itself, creates a new TUMBLINGSTATISTICSFIG or raises the existing
%      singleton*.
%
%      H = TUMBLINGSTATISTICSFIG returns the handle to a new TUMBLINGSTATISTICSFIG or the handle to
%      the existing singleton*.
%
%      TUMBLINGSTATISTICSFIG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TUMBLINGSTATISTICSFIG.M with the given input arguments.
%
%      TUMBLINGSTATISTICSFIG('Property','Value',...) creates a new TUMBLINGSTATISTICSFIG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tumblingStatisticsFig_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tumblingStatisticsFig_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tumblingStatisticsFig

% Last Modified by GUIDE v2.5 05-Oct-2010 17:27:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tumblingStatisticsFig_OpeningFcn, ...
                   'gui_OutputFcn',  @tumblingStatisticsFig_OutputFcn, ...
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


% --- Executes just before tumblingStatisticsFig is made visible.
function tumblingStatisticsFig_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tumblingStatisticsFig (see VARARGIN)

% Choose default command line output for tumblingStatisticsFig
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes tumblingStatisticsFig wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = tumblingStatisticsFig_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
