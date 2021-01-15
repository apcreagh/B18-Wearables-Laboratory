%% B18 Biomedical Modelling and Monitoring (A10589) Wearables Laboratory
% This file relates to the Section C, exercise 2. 
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
data_pathname=[b18lab_pathname, filesep, 'DATA\B18_GAIT_data'];

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
options.plot_data=0; %leave off
%-------------------------------------------------------------------------%
%% Walking Detection Parameters:
%-------------------------------------------------------------------------%
%  - 'acc_threshold': upright movement threshold corresponding to 
%       the moving mean of the vertical acceleration (aY);
%      (default, options.aYm_threshold=0.77; g, where gravity g=9.81 ms^-2)
%  - 'ssd_threshold': combined standard deviation (SSD) threshold
%       correponsindg to the moving standard deviation of the combined 
%       standard deviation of aX, aY, and aZ acceleration;
%      (default, options.ssd_threshold=0.77; g, where gravity g=9.81 ms^-2)
%  -  'time_threshold': The minimum duration of activity to be considered
%      walking, in seconds [s];(default, options.ssd_threshold=5; [s]).
%-------------------------------------------------------------------------%
G=9.81; %gravity 9.81 m/s^2
options.acc_threshold;   %choose a value
options.ssd_threshold;   %choose a value;
options.time_threshold;  %choose a value %[s]
%% Step Detection Parameters:
%-------------------------------------------------------------------------%
% - 'MinPeakDistance': the minimum distance between each detected peak 
%                      (i.e step), in seconds [s] 
% - 'MinPeakHeight': the minimum height of a detected detected peak 
%                    (i.e step),  in terms of gravity 9.81 m/s^2
%-------------------------------------------------------------------------%
options.MinPeakDistance; %choose a value
options.MinPeakHeight;   %choose a value
%% Run Walking Detection and Step Detection algorithm for all subjects
% In this section you will run the step detection algorithm for all
% subjects with front trouser pocket recordings. We will gather all step
% data into vectors for use in analysis later. You should use your best
% performing paramter combinations to get the most accurate step detection
% you can. Don't worry however, no step detection algorithm will be
% perfect, so do not spend time optimsing your paramater values.
%-------------------------------------------------------------------------%
%close any residual plots 
close all
%turn off plotting fucntion so we don't plot hundreds of graphs
options.plot_data=0; 

%initialise our variables
num_subjects=size(fileInfo,1);
steps_counted=zeros(num_subjects,1);
num_steps_detected=zeros(num_subjects,1); 
cadence=zeros(num_subjects,1);

%return the step information for all filenames
for s=1:num_subjects     
    filename=fileInfo.filename(s);
    subject=fileInfo.subject(s);
    [steps_counted(s), num_steps_detected(s), cadence(s)]=...
        run_smartphone_gait(pathname, filename, subject, device_location, options);       
end
%% Step Detection Analysis
% In this section you will perform some simple step detection analysis. We
% will calculate some commn performance metrics, the mean absolute error
% (MAE) and the mean squared error (MSE). We will also perform a simple
% paired t-test between the number of actual steps recorded and the number of
% steps detected over all the subjects. 
%calculate MAE;
MAE=sum(abs(steps_counted-num_steps_detected))/num_subjects;
%calculate MSE;
MSE=sum((steps_counted-num_steps_detected).^2)/num_subjects;
%Perform a paired t-test;
[~, p_value]=ttest(steps_counted, num_steps_detected);

%print to the terminal window: the mean number steps recorded and detected,
%as well aa the MAE, MSE and p-value from the paired t-test
fprintf(' # steps (actual): %0.1f \x00B1 %0.1f | # steps (detected): %0.1f \x00B1 %0.1f | p=%0.2f\n MAE: %0.2f\n MSE: %0.2f\n',  ...
    mean(steps_counted), std(steps_counted), mean(num_steps_detected), std(num_steps_detected), p_value, MAE, MSE)

%-------------------------------------------------------------------------%
%% Plotting actual vs. detected steps
%Plot the actual number of steps counted versus the number of steps
%detected by our algorithm as boxplots, as well and a scatter plot.

%determine the minimum and maximum limits of our plot +/- a little bit so
%we can make a nice plot with equal axis limits;
limits=[...
    min([num_steps_detected; steps_counted])-5,...
    max([num_steps_detected; steps_counted])+5];

%plot the boxplot
figure
subplot(1,2,1)
boxplot([steps_counted, num_steps_detected], 'Labels',{'actual', 'detected'})
ylabel('# steps')
ylim(limits);

%plot the scatter plot
subplot(1,2,2)
plot(steps_counted,num_steps_detected,  'o'); hold on
plot(num_steps_detected, num_steps_detected, 'k-'); hold on
ylabel('# steps (detected)')
xlabel('# steps (actual)')
ylim(limits); xlim(limits)

%EOF