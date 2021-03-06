function Tenaspis3singlesession()
% Quick & dirty Tenaspis2
% Requires DFF.h5 and SLPDF.h5 be present

%% Extract Blobs
MakeMaskSingleSession;

load singlesessionmask.mat;
disp('Extracting blobs...'); 
ExtractBlobs('SLPDF.h5',neuronmask);

%% Connect blobs into transients
disp('Making transients...');
MakeTransients; 
!del InitClu.mat

%% Group together individual transients under individual neurons
disp('Making neurons...'); 
MakeNeurons('min_trans_length',10);

%% Pull traces out of each neuron using the High-pass movie
disp('Normalizing traces...'); 
NormalTraces('SLPDF.h5');
MakeROIavg;
load ProcOut.mat;
load ROIavg.mat;
MakeROIcorrtraces(NeuronPixels,Xdim,Ydim,NumFrames,ROIavg);
%% Expand transients
disp('Expanding transients...'); 
ExpandTransients(0);

%% Calculate peak of all transients
AddPoTransients;

%% Determine rising events/on-times for all transients
DetectGoodSlopes;

load ('T2output.mat','FT','NeuronPixels');
for i = 1:2
   indat{1} = FT;
   outdat = MakeTrigAvg(indat);
   MergeROIs(FT,NeuronPixels,outdat{1});
   load ('FinalOutput.mat','FT','NeuronPixels');
end
indat{1} = FT;
outdat = MakeTrigAvg(indat);
MeanT = outdat{1};
save('MeanT.mat', 'MeanT', '-v7.3');
FinalTraces('SLPDF.h5');
