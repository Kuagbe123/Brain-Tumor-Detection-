function varargout = BrainMain(varargin)
% BRAINMAIN MATLAB code for BrainMain.fig
%      BRAINMAIN, by itself, creates a new BRAINMAIN or raises the existing
%      singleton*.
%
%      H = BRAINMAIN returns the handle to a new BRAINMAIN or the handle to
%      the existing singleton*.
%
%      BRAINMAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BRAINMAIN.M with the given input arguments.
%
%      BRAINMAIN('Property','Value',...) creates a new BRAINMAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BrainMain_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BrainMain_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BrainMain

% Last Modified by GUIDE v2.5 23-Jun-2019 14:54:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BrainMain_OpeningFcn, ...
                   'gui_OutputFcn',  @BrainMain_OutputFcn, ...
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


% --- Executes just before BrainMain is made visible.
function BrainMain_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BrainMain (see VARARGIN)

% Choose default command line output for BrainMain
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BrainMain wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BrainMain_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(~, ~, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global brainImg
[filename, pathname] = uigetfile({'*.jpg'; '*.bmp'; '*.tif'; '*.gif'; '*.png'; '*.jpeg'}, 'Load Image File');
if isequal(filename,0)||isequal(pathname,0)
    warndlg('Press OK to continue', 'Warning');
else
brainImg = imread([pathname filename]);
brainImg = imresize(brainImg, [256,256]);
axes(handles.axes2);
imshow(brainImg);
axis off
%helpdlg(' Image loaded successfully ', 'Alert'); 
end
[~, ~, c] = size(brainImg);
if c == 3
    brainImg  = rgb2gray(brainImg);
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(~, ~, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global brainImg brainImgFilt 
%[ brainImgFilt ] = Preprocess( brainImg );
%
%convert 2 gray scale
% I = brainImg ;
% level = graythresh(I) 
% BW = im2bw(I, level) ;
% %opening operation
% se = strel('disk', 3) ;
% BW = imopen(BW, se) ;
% BW = bwareafilt(BW, 1) ;
% BW = imclose(BW, se) ;
% BW= uint8(BW);
% skullImg = I .*BW ;
% brainImg1 = medfilt2(skullImg);
brainImg1 = medfilt2(brainImg);
[brainImgFilt] = imadjust(brainImg1,[.4 .8],[0 1]);

axes(handles.axes3);
imshow(brainImgFilt);
axis off



% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(~, ~, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global brainImg brainImgFilt imagNew 

BW = im2bw(brainImgFilt, 0.5);
figure;imshow(BW);
label = bwlabel(BW);

stats = regionprops(label, 'Solidity', 'Area');

denisty = [stats.Solidity];
area = [stats.Area];

high_dence_area = denisty > 0.5;
max_area = max(area(high_dence_area));
tumor_label = find(area == max_area);
tumor = ismember(label, tumor_label);
[B,~] = bwboundaries(tumor, 'noholes');
axes(handles.axes4);
imshow(brainImg,[])
hold on
for i=1:length(B)
    plot(B{i}(:,2), B{i}(:,1), 'y', 'linewidth', 1.45)
    x=[B{i}(:,2), B{i}(:,1)];
end
%title('detected tumor')
hold off

se = strel('line',11,90);
%se= strel('square', 5);
BW2 = imdilate(tumor,se);
BW3 = imfill(BW2,'holes');

se = strel('line',11,90);
BW_Created = imerode(BW3,se);
BW_Created=uint8(BW_Created);

imagNew=brainImg.*BW_Created ;

axes(handles.axes4);
imshow(imagNew);
axis off
%-------------------------------------------------------------------%
%enter url mask image for calculate "SIMILARITY COEFFICIENT" for each image
%-------------------------------------------------------------------%
BW_groundTruth= imread('D\BrainCAD_GUI\SampleImage\mask\2Perfectm.jpg');
% gt=BW_groundTruth(:);
% segm=BW_Created(:);
BW_groundTruth = logical(BW_groundTruth);
BW_Created = logical(BW_Created);
similarityDICE = dice(BW_Created, BW_groundTruth);
similarityJAC = jaccard(BW_Created, BW_groundTruth)
similarityFSCORE = bfscore(BW_Created, BW_groundTruth);
%err = immse(segm, gt)
%SSD=sum(sum(segm, gt).^2) 
%sd = (segm - gt).^2 ; ssd = sum(sd(:))
% similarityhd = HausdorffDist(imagNew, BW_groundTruth)
% result_MSE = mse(imagNew)
% result_PSNR=10*log10(255^2/result_MSE)
% source=sum(sum(result_MSE.^2))
% result_SNR=10*log10(source/result_MSE)



% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(~, ~, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global   TestImgFea imagNew
GLCM_mat = graycomatrix(imagNew,'Offset',[2 0;0 2]);
     
     GLCMstruct = Computefea(GLCM_mat,0);
     
     v1=GLCMstruct.contr(1);

     v2=GLCMstruct.corrm(1);

     v3=GLCMstruct.cprom(1);

     v4=GLCMstruct.cshad(1);

     v5=GLCMstruct.dissi(1);

     v6=GLCMstruct.energ(1);

     v7=GLCMstruct.entro(1);

     v8=GLCMstruct.homom1(1);

     v9=GLCMstruct.homop(1);

     v10=GLCMstruct.maxpr(1);

     v11=GLCMstruct.sosvh(1);

     v12=GLCMstruct.autoc(1);
     
     TestImgFea = [v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12];
     whos TestImgFea
set(handles.uitable1,'Data',TestImgFea);
set(handles.uitable1, 'ColumnName', {'Contrast', 'Correlation','Cluster Prominence','Cluster Shade',....
        'Dissimilarity','Energy','Entropy','Homogeneity[1]','Homogeneity[2]','Maximum Probability',.....
        'Sum of Squares : Variance','Autocorrelation'});
    set(handles.uitable1, 'RowName', {'Value'});


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(~, ~, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global TestImgFea   
load TrainFeatures
load Truetype

xdata = TrainImgsFeature;
group = Braincate';
 svmStruct1 = fitcsvm(xdata,group,'kernel_function', 'rbf');
 species = ClassificationSVM(svmStruct1,TestImgFea,'showplot',true);

  if isequal(species{1},Truetype{1})
         Imgcate=species{1};
         helpdlg(' Benign Tumor ');
         disp(' Benign Tumor ');
     elseif isequal(species{1},Truetype{2})

         Imgcate = species{1};
         helpdlg(' Malignant Tumor ');
         disp(' Malignant Tumor ');
  end
     
 
 set(handles.edit1,'string',Imgcate);




% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(~, ~, ~)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Path
folder_name = uigetdir;
if isequal(folder_name,0)
    warndlg('User Press Cancel');
else
    Path = folder_name;
end


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(~, ~, ~)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Path

[TrainImgsFeature, Braincate] = CollectFeatures(Path);

save TrainFeatures 'TrainImgsFeature' 'Braincate'

helpdlg(' training dataset successfully ', 'Alert'); 







function edit1_Callback(~, ~, ~)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, ~, ~)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
