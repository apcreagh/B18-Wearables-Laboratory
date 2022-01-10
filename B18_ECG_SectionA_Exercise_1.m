%% B18 Biomedical Modelling and Monitoring (A10589) Wearables Laboratory
% This file relates to the Section A, exercise 1.  
%-------------------------------------------------------------------------%
% Lab designed by: Andrew Creagh
% Code written by: Andrew Creagh
% Email: andrew.creagh@eng.ox.ac.uk
%-------------------------------------------------------------------------%
clear
close all
%-------------------------------------------------------------------------%
% SET-UP
%-------------------------------------------------------------------------%
% NOTE: either ensure that your current directory is the main B18 lab
% directory,or else change the data_pathname and save_pathname directiry
% locations manually

[b18lab_pathname, ~, ~] = fileparts(mfilename('fullpath'));
cd(b18lab_pathname)

%manually add correct pathname if you need;
data_pathname=[b18lab_pathname, filesep, 'DATA' filesep, 'B18_ECG_data'];
%manually add correct pathname if you need;
save_pathname=[b18lab_pathname, filesep, 'RESULTS' filesep, 'B18_ECG'];

save_figure=1; %binary key to save figures (1) | do not save (0) figures
%-------------------------------------------------------------------------%
%% Load the Data
load([data_pathname, filesep, 'PhysionetData.mat'])

%chose subjects for analysis
normal_file='A00007';
afib_file='A00267';
other_file='A00077';
noisy_file='A01246';

%determine recordings to use
normal_index=find(contains(RecordingInfo.Filename, normal_file));
afib_index=find(contains(RecordingInfo.Filename, afib_file));
other_index=find(contains(RecordingInfo.Filename, other_file));
noisy_index=find(contains(RecordingInfo.Filename,noisy_file));

ecg_normal_raw=Signals{normal_index};
ecg_aFib_raw=Signals{afib_index};
ecg_other_raw=Signals{other_index};
ecg_noisy_raw=Signals{noisy_index};

%convert from microVolts to miliVolts
ecg_normal_raw=ecg_normal_raw/1000;
ecg_aFib_raw=ecg_aFib_raw/1000;
ecg_noisy_raw=ecg_noisy_raw/1000;
ecg_other_raw=ecg_other_raw/1000;

%switch the polarity of ecg if its negative
if abs(min(ecg_normal_raw))>abs(max(ecg_normal_raw)) ecg_normal_raw=-ecg_normal_raw; end
if abs(min(ecg_aFib_raw))>abs(max(ecg_aFib_raw)) ecg_aFib_raw=-ecg_aFib_raw; end
if abs(min(ecg_other_raw))>abs(max(ecg_other_raw)) ecg_other_raw=-ecg_other_raw; end
if abs(min(ecg_noisy_raw))>abs(max(ecg_noisy_raw)) ecg_noisy_raw=-ecg_noisy_raw; end

%determine a time vector
signal=ecg_normal_raw; 
fs=300; %Sampling frequency (Hz)
samples=1:length(signal); % 'signal' is your vector of ecg values 
%'time' is a corresponding monotonic vector of time values
time=samples./fs;
%-------------------------------------------------------------------------%
%% Exercise 1: Exploratory Data Analysis
%A.1.1) Load the PhysioNet data into MATLAB and determine the proportion of
%classes in the datasetfrom theRecordingInfotable.  (hint:  use
%thetabulate.mfunction)
tabulate(RecordingInfo.Label)
%-------------------------------------------------------------------------%
%A.1.2) Plot a suitable portion of ECG data from a normal subject, which depicts
% at least 2 heartbeats.Identify and label the PQRST points

%make folder for results
if ~isfolder(save_pathname) && save_figure
    mkdir(save_pathname); 
    fprintf('\nSaving figure(s) to: %s', save_pathname)
end 

figure
plot(time, ecg_normal_raw); hold on
xlabel('Time [s]')
ylabel('Amplitude (mV)')
xlim([4.5, 8])
text(6.15,0.05,'P','HorizontalAlignment','center')
text(6.24,-0.0,'Q','HorizontalAlignment','center')
text(6.29,0.55,'R','HorizontalAlignment','center')
text(6.4,0.175,'S','HorizontalAlignment','center')
text(6.55,0.25,'T','HorizontalAlignment','center')

%save figure
if save_figure
fig=gcf;
exportgraphics(fig,[save_pathname, filesep, 'B18_ECG_A12', '.pdf'],'ContentType','vector'); 
exportgraphics(fig, [save_pathname, filesep, 'B18_ECG_A12', '.png'])
end 
%-------------------------------------------------------------------------%
%A.1.3) Visualise a segment of one ECG signal from each of the 4 classes from any
% chosen set of examples.Label each recording.

%initalise as new variables for this section
ecg_normal=ecg_normal_raw;
ecg_aFib=ecg_aFib_raw;
ecg_other=ecg_other_raw;
ecg_noisy=ecg_noisy_raw;

figure
subplot(4,1,1)
plot(time, ecg_normal)
title(sprintf('Normal Rhythm; Recording: %s', string(RecordingInfo.Filename(normal_index))))
% xlim([15,20])
ylabel('Amplitude (mV)')
xlabel('Time [s]')

subplot(4,1,2)
plot(time, ecg_aFib)
title(sprintf('AF Rhythm; Recording: %s', string(RecordingInfo.Filename(afib_index))))
% xlim([15,20])
xlabel('Time [s]')
ylabel('Amplitude (mV)')

subplot(4,1,3)
plot(time, ecg_other)
% xlim([15,20])
title(sprintf('Other Rhythm; Recording: %s', string(RecordingInfo.Filename(other_index))))
xlabel('Time [s]')
ylabel('Amplitude (mV)')

subplot(4,1,4)
plot(time, ecg_noisy)
% xlim([15,20])
title(sprintf('Noisy; Recording: %s', string(RecordingInfo.Filename(noisy_index))))
xlabel('Time [s]')
ylabel('Amplitude (mV)')

%save figure
if save_figure
fig=gcf;
exportgraphics(fig,[save_pathname, filesep, 'B18_ECG_A13', '.pdf'],'ContentType','vector'); 
exportgraphics(fig, [save_pathname, filesep, 'B18_ECG_A13', '.png'])
end 
%-------------------------------------------------------------------------%
% A.1.3a) Describe some of the signal characteristics observed that
% distinguish normal ECG versusAF ECG in your chosen examples.  Use extra
% plots to illustrate your discussion points if required
figure
plot(time, ecg_aFib); hold on
xlabel('Time [s]')
ylabel('Amplitude (mV)')
xlim([14.5, 17])
title(sprintf('AF Rhythm; Recording: %s', string(RecordingInfo.Filename(afib_index))))
set(gca, 'fontsize', 14)
%save figure
if save_figure
fig=gcf;
exportgraphics(fig,[save_pathname, filesep, 'B18_ECG_A13a', '.pdf'],'ContentType','vector'); 
exportgraphics(fig, [save_pathname, filesep, 'B18_ECG_A13a', '.png'])
end 
%-------------------------------------------------------------------------%