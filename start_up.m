%% B18 Biomedical Modelling and Monitoring (A10589) Wearables Laboratory
% Run this file at the beginning of the lab to extract the data and set up
% your folders for analysis and results. 
%-------------------------------------------------------------------------%
% Lab designed by: Andrew Creagh
% Code written by: Andrew Creagh; 
% Email: andrew.creagh@eng.ox.ac.uk
%-------------------------------------------------------------------------%
[b18lab_pathname, ~, ~] = fileparts(mfilename('fullpath'));
cd(b18lab_pathname)

scripts_pathname=[b18lab_pathname, filesep, 'SCRIPTS'];
data_pathname=[b18lab_pathname, filesep, 'DATA'];
save_pathname=[b18lab_pathname, filesep, 'RESULTS'];
cd(data_pathname)

if ~isfolder(save_pathname)
    mkdir(save_pathname); end 

%add all the paths
addpath(data_pathname)
addpath(scripts_pathname)
addpath(save_pathname)

%unpack the data
get_data(data_pathname, 'ECG');
get_data(data_pathname, 'EEG');
get_data(data_pathname, 'GAIT');

%return to the B18 main directory 
cd(b18lab_pathname)
fprintf('Finished data extraction. Ready to start B18 lab\n')
%-------------------------------------------------------------------------%
%EOF