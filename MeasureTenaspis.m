function [EBtime,EBmem,MNtime,MNmem] = MeasureTenaspis(starttime, endtime)
% start off assuming that the movie has been smoothed

% measure the

load Blobthresh.mat;
load ('mask_reg.mat');
neuronmask = mask_reg;

tic
  EBmem = ExtractBlobsTest('D1Movie.h5',0,thresh,neuronmask,starttime,endtime);
EBtime = toc;

MakeTransientsTest('D1Movie.h5',0,starttime,endtime);

tic
  MNmem = MakeNeuronsTest;
MNtime = toc;

end

