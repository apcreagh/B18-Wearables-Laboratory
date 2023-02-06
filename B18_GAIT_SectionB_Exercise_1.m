%% B18 Biomedical Modelling and Monitoring (A10589) Wearables Laboratory
% This file relates to the Section C, exercise 1.  
%-------------------------------------------------------------------------%
% Lab designed by: Andrew Creagh
% Code written by: Andrew Creagh
% Email: andrew.creagh@eng.ox.ac.uk
%-------------------------------------------------------------------------%
clear
close all
%% Load the Data
%-------------------------------------------------------------------------%
% SET-UP
%-------------------------------------------------------------------------%
% NOTE: either ensure that your current directory is the main B18 lab
% directory,or else change the data_pathname and save_pathname directiry
% locations manually;
%the pathname where the data is stored; You can manually change this to
%your directory where the data is stored by denoting the pathname variable:
%e.g.: data_pathname='C:\MATLAB\B18 Lab\DATA\B18_GAIT_data\'
b18lab_pathname=pwd;
data_pathname=[b18lab_pathname, filesep, 'DATA', filesep, 'B18_GAIT_data'];

%set the device location; in this example we are only interested in
%smartphone accelerometry that recorded when the phone was in the front
%trousers pocket.
device_location='front_pocket';
% returns a table consisting of the filenames extracted and the
% corresponding subject ID as strings.
fileInfo=return_filenames_gait(data_pathname, device_location);
%-------------------------------------------------------------------------%
%% Plotting Options
% 'plot_data' 0/1 (binary off/on).
%Functionality to plot the fugures;
%options.plot_data=0;...turns off plotting
%options.plot_data=1;...turns on plotting
options.plot_data=1; 
%-------------------------------------------------------------------------%
%% Walking Detection Parameters:
%-------------------------------------------------------------------------%
%  - 'acc_threshold': upright movement threshold corresponding to 
%       the moving mean of the vertical acceleration (aY);
%      (default, options.acc_threshold=0.77; g, where gravity g=9.81 ms^-2)
%  - 'ssd_threshold': combined standard deviation (SSD) threshold
%       correponsindg to the moving standard deviation of the combined 
%       standard deviation of aX, aY, and aZ acceleration;
%      (default, options.ssd_threshold=0.77; g, where gravity g=9.81 ms^-2)
%  - 'time_threshold', float, minimum gait-bout length to consider as 
%        measured in seconds [s], i.e. bouts less than this threshold will
%        be removed;
%       (default, options.time_threshold=1; [s])
%-------------------------------------------------------------------------%
G=9.81; %gravity 9.81 m/s^2
options.acc_threshold=0.77;  %choose value
options.ssd_threshold=0.77;  %choose value
options.time_threshold=1;    %choose value [s]
%% Step Detection Parameters:
%-------------------------------------------------------------------------%
% - 'MinPeakDistance': the minimum distance between each detected peak 
%                      (i.e step), in seconds [s] 
% - 'MinPeakHeight': the minimum height of a detected detected peak 
%                    (i.e step),  in terms of gravity 9.81 m/s^2
%-------------------------------------------------------------------------%
options.MinPeakDistance=0.5;    %choose value
options.MinPeakHeight=1;      %choose value
%% Run Walking Detection and Step Detection Algorithm
%choose one of the filenames from the dataset and corresponding subject
%identifier
file_index=1; %choose a value [1, 2, ..., N], where N are the number of files
%get the corresponding filename and subject name from the fileInfo table:
filename=fileInfo.filename(file_index); subject=fileInfo.subject(file_index);

%run walking detection and step detection algorithm
[steps_counted, num_steps, cadence]=run_smartphone_gait(data_pathname, filename, subject, device_location, options);

%EOF
