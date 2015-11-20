function [ output_args ] = TestDurations( input_args )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

DurSweepMinutes = [0.5,1,2,4,6,8,10,12,14,16,18]
[~,x,y,nf] = loadframe('D1movie.h5',1000);
NumIts = 1;
for i = 1:length(DurSweepMinutes)
    for j = 1:NumIts
       maxoffset = nf-DurSweepMinutes(i)*60*20-1;
       offset = ceil(rand*maxoffset);
       [EBtime(i,j),EBmem(i,j),MNtime(i,j),MNmem(i,j),NN(i,j),NT(i,j)] = MeasureTenaspis(offset,offset+DurSweepMinutes(i)*20*60)
       save TestDurations.mat;
    end
end



