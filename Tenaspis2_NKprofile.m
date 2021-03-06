function Tenaspis2_NKprofile(animal_id,sess_date,sess_num)
% Quick & dirty Tenaspis2
% Requires DFF.h5, manualmask.mat, and SLPDF.h5 be present

%% Register base session neuron mask to current session
MasterDirectory = 'C:\MasterData';

[init_date,init_sess] = GetInitRegMaskInfo(animal_id);
init_dir = ChangeDirectory(animal_id,init_date,init_sess);
% init_tif = fullfile(init_dir,'ICmovie_min_proj.tif');

init_mask_loc = fullfile(MasterDirectory,[animal_id,'_initialmask.mat']);

reg_struct.Animal = animal_id;
reg_struct.Date = sess_date;
reg_struct.Session = sess_num;

sess_dir = ChangeDirectory(animal_id,sess_date,sess_num); % Change to session directory
if ~exist('mask_reg.mat','file')
    mask_multi_image_reg(init_mask_loc,init_date,init_sess,reg_struct);
end

load mask_reg
mask_reg = logical(mask_reg); 

%% Extract Blobs
disp('Extracting blobs...'); 
ExtractBlobs('DFF.h5',mask_reg);

%% Connect blobs into transients
disp('Making transients...');
MakeTransients('DFF.h5',0); % Dave - the inputs to this are currently unused
!del InitClu.mat

%% Group together individual transients under individual neurons

disp('Making neurons...'); 
MakeNeurons('min_trans_length',10);

% Pull traces out of each neuron using the High-pass movie
disp('Normalizing traces...'); 
NormalTraces('SLPDF.h5');

% Expand transients
disp('Expanding transients...'); 
ExpandTransients(0);

% Calculate peak of all transients
disp('Calculating pPeak...'); 
Calc_pPeak;

%%
AddPoTransients;

% Determine rising events/on-times for all transients
disp('Finalizing...');
DetectGoodSlopes;


%% Calculate place fields and accompanying statistics
CalculatePlacefields('201b','alt_inputs','T2output.mat','man_savename',...
    'PlaceMapsv2.mat','half_window',0,'minspeed',3);
PFstats;

end

