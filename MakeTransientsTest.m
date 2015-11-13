function [] = MakeTransients(file,todebug,starttime,endtime)
% [] = MakeTransients(file,todebug,varargin)
%
% Take all of those blobs found in ExtractBlobs.m and figure out, for each
% one, whether there was one on the previous frame that matched it and if
% so which one, thus deducing calcium transients across frames
%
% varargins:
%   'min_trans_length':minimum number of frames a transient must last in
%   order to be included, enter as MakeTransients(...,'min_trans_length,3)
%
% Copyright 2015 by David Sullivan and Nathaniel Kinsky
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of Tenaspis.
% 
%     Tenaspis is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     Tenaspis is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with Tenaspis.  If not, see <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% Calcium transient inclusion criteria
min_trans_length = 5; % (default) minimum number of frames a transient must last in order to be included
max_trans_dist = 5; % (default) maximum number of pixels a transient can travel without being discarded



%%

load CC.mat

if (nargin < 2)
    todebug = 0;
end

info = h5info(file,'/Object');
NumFrames = endtime-starttime+1; %info.Dataspace.Size(3);
Xdim = info.Dataspace.Size(1);
Ydim = info.Dataspace.Size(2);

NumSegments = 0;
SegChain = [];
SegList = zeros(NumFrames,100);

for i = 2:NumFrames
    i
    stats = regionprops(cc{i},'all');
    oldstats = regionprops(cc{i-1},'all');
    for j = 1:cc{i}.NumObjects
        
        
        % find match
        [MatchingSeg,idx] = MatchSeg(stats(j),oldstats,SegList(i-1,:));
        if (MatchingSeg == 0)
            % no match found, make a new segment
            NumSegments = NumSegments+1;
            SegChain{NumSegments} = {[i,j]};
            SegList(i,j) = NumSegments;
        else
            % a match was found, add to segment
            SegChain{MatchingSeg} = [SegChain{MatchingSeg},{[i,j]}];
            SegList(i,j) = MatchingSeg;
            if (todebug)
                subplot(1,2,2);
                hold on;
                temp = zeros(Xdim,Ydim);
                temp(cc{i-1}.PixelIdxList{idx}) = 1;
                b = bwboundaries(temp);
                y = b{1}(:,1);
                x = b{1}(:,2);
                plot(x,y,'-r');
                hold off;pause;
            end
            
        end
    end
end

for i = 1:length(SegChain)
    ns(i) = length(SegChain{i});
end

DistTrav = TransientStats(SegChain);

goodlen = find(ns >= min_trans_length);
gooddist = find(DistTrav < max_trans_dist);

goodseg = intersect(goodlen,gooddist);

SegChain = SegChain(goodlen);
NumSegments = length(SegChain);


if min_trans_length == 5
    save Segments.mat NumSegments SegChain cc NumFrames Xdim Ydim min_trans_length max_trans_dist
else
    save_name = ['Segments_minlength_' num2str(min_trans_length) '.mat'];
    save(save_name, 'NumSegments', 'SegChain', 'cc', 'NumFrames', 'Xdim', 'Ydim', 'min_trans_length', 'max_trans_dist')
end


end

