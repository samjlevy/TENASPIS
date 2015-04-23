function [] = AnalyzePFProx()
% analyze cell proximity and its relation to placefield proximity
close all;

load ProcOut.mat;
load PlaceMaps.mat;
load PFstats.mat;

NumNeurons = length(MaxPF);

% create matrix of distances to feed into Pdist
for i = 1:NumNeurons
    PFcentroid{i,MaxPF(i)}
    if (~isempty(PFcentroid{i,MaxPF(i)}))
      PFxy(i,1:2) = PFcentroid{i,MaxPF(i)};
      ValidPF(i) = 1;
    else
      ValidPF(i) = 0;
    end
    b = bwconncomp(NeuronImage{i});
    r = regionprops(b,'Centroid');
    Nxy(i,1:2) = r(1).Centroid;
end

vPFxy = PFxy(find(ValidPF),:);
vNxy = Nxy(find(ValidPF),:);

dPF = squareform(pdist(vPFxy));
dN = squareform(pdist(vNxy));

% unpack squareforms
curr = 1;
for i = 1:length(dN)
    for j = 1:i-1
        ldPF(curr) = dPF(i,j);
        ldN(curr) = dN(i,j);
        curr = curr + 1;
    end
end

figure;
plot(ldPF,ldN,'*');xlabel('neuron distance (pixels)');ylabel('place field distance');
figure;
hist3([ldPF',ldN'],[40 40]);xlabel('placefield distance');ylabel('neuron distance');zlabel('# of neurons');
set(gcf,'renderer','opengl');
set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');


keyboard;

