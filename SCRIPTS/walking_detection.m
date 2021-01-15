function [BOUT_DATA, keep_indexes, gait_indicator]=walking_detection(SENSOR_DATA, fs, options)
% Heuristic Gait Bout Detection.
% Function to perform heuristic gait bout detection and segmentation from
% body-worn inertial sensor data captured in [1]. Algorithm and parameters
% have been adapted from those presented in [2].
% There are many more sophisticated ways of performing this segmentation
% but we found this simple and heuristic method to work quite well.
%--------------------------------------------------------------------------
% Input:
%     SENSOR_DATA: a [N x C] matrix of inertial sensor data, where N are
%     the number of samples and C are the number of channels such that:
%       SENSOR_DATA(:,1) - a monotonically increasing time vector 
%       SENSOR_DATA(:,2) - aX-axis sensor data
%       SENSOR_DATA(:,3) - aY-axis sensor data
%       SENSOR_DATA(:,4) - aZ-axis sensor data
%       SENSOR_DATA(:,5) - ||a||-axis sensor data
%
%      fs: the sampling frequency in Hertz [Hz]
%
%_______________________________________________________________________
% options: structure containing optional inputs.
%       Default parameter values have been taken from [2].
%
%     - 'window_size' float, functionality to specify the size of the
%       window used to compute the moving average of the vertical
%       acceleration (aY) in  seconds [s];
%       (default, options.window_size=0.1; [s])
% 
%     - 'acc_threshold' float, upright movement threshold correponsindg to 
%       the moving mean of the vertical acceleration (aY);
%      (default, options.acc_threshold=0.77; g, where gravity g=9.81 ms^-2)
% 
%     - 'ssd_threshold' float, combined standard deviation (SSD) threshold
%       correponsindg to the moving stdnard deviation of the combined 
%       standard deviation of aX, aY, and aZ acceleration;
%      (default, options.aYm_threshold=0.77; g, where gravity g=9.81 ms^-2)
%    
%     - 'time_threshold', float, minimum gait-bout length to consider as 
%        measured in seconds [s], i.e. bouts less than this threshold will
%        be removed;
%       (default, options.window_size=0.5; [s])
% 
%     - 'plot_bout_detection' 0/1 (binary off/on). Functionality to plot 
%        the results from the bout detection algorithm;
%       (default,options.plot_bout_detection=0)
%
% =========================================================================
% Output:
%     SENSOR_DATA_OUT: Gait filtered inertial sensor data, where non-gait
%     bouts have been removed. SENSOR_DATA_OUT is a [N x C] matrix of
%     pre-processed inertial sensor data where N  re the number of samples
%     and C are the number of channels such that: Non-gait bouts will be
%     removed from depending on the default parameters or else those set
%     parameters out by the options structure.
%       
%     SENSOR_DATA_OUT(:,1) - a monotonically increasing time vector 
%     SENSOR_DATA_OUT(:,2) - aX-axis sensor data
%     SENSOR_DATA_OUT(:,3) - aY-axis sensor data
%     SENSOR_DATA_OUT(:,4) - aZ-axis sensor data
%     SENSOR_DATA_OUT(:,5) - ||a||-axis sensor data
%--------------------------------------------------------------------------
% References:
% [1] A. P. Creagh et al. (2020), "Smartphone- and Smartwatch-Based Remote
%     Characterisation of Ambulation in Multiple Sclerosis during the
%     Two-Minute Walk Test," in IEEE Journal of Biomedical and Health
%     Informatics, doi: 10.1109/JBHI.2020.2998187.
% [2] H. Aodhan, D. Silvia Del, R. Lynn, and G. Alan, “Detecting free-living
%     steps and walking bouts: validating an algorithm for macro gait
%     analysis,” Physiological Measurement, vol. 38, no. 1, p. N1, 2017.
% [3] Lyons G M et al 2005 A description of an accelerometer-based
%     mobility monitoring technique Med. Eng. Phys. 27 497–504
% [4] Hollman, John H., Eric M. McDade, and Ronald C. Petersen. "Normative
%     spatiotemporal gait parameters in older adults." Gait & posture 34,
%     no. 1 (2011): 111-118.
%--------------------------------------------------------------------------
%% Andrew Creagh. andrew.creagh@eng.ox.ac.uk
% Last modified in June 2020
% If you use this funciton, please reference:
%     A. P. Creagh et al. (2020), "Smartphone- and Smartwatch-Based Remote
%     Characterisation of Ambulation in Multiple Sclerosis during the
%     Two-Minute Walk Test," in IEEE Journal of Biomedical and Health
%     Informatics, doi: 10.1109/JBHI.2020.2998187.
%% Initialisation
aX=SENSOR_DATA(:,2); aY=SENSOR_DATA(:, 3);aZ=SENSOR_DATA(:, 4);aM=SENSOR_DATA(:, 5);
time=SENSOR_DATA(:, 1);

%if no fs provided, calculate it. 
if ~exist('fs', 'var') || isempty(fs) || isnan(fs)
    dt=diff(time); 
    fs=1/median(dt(dt~=0));
end 

%% Parameterization
%Default parameter values have been taken from [2].
window_size=5;   % 5 [s]
acc_threshold=0.77;     % 0.77 g, g=9.81 ms^-2
ssd_threshold=0.05;     % 0.05 g, g=9.81 ms^-2
time_threshold=0.5;     % 0.5 [s]
discard_time=20;
% * Note: ensure that aX, aY and aZ are in terms of gravity (g)

if isfield(options, 'window_size')
    window_size=options.window_size; end
if isfield(options, 'acc_threshold')
    acc_threshold=options.acc_threshold; end
if isfield(options, 'ssd_threshold')
    ssd_threshold=options.ssd_threshold; end
if isfield(options, 'time_threshold')
    time_threshold=options.time_threshold; end
if isfield(options, 'discard_time')
    discard_time=options.discard_time; end
%convert window size from [s] to # of samples
window_size = round(fs*window_size); 
%convert time_threshold from [s] to # of samples
time_threshold=round(time_threshold*fs);
discard_time=round(discard_time*fs);
%% Walking bout detection

aMag=sqrt(aX.^2 + aY.^2 + aZ.^2);
aXm=movmean(aX, window_size); 
aYm=movmean(aY, window_size); 
aZm=movmean(aZ, window_size);
aMagm=movmean(aMag, window_size);

aXsd=movstd(aX, window_size); 
aYsd=movstd(aY, window_size); 
aZsd=movstd(aZ, window_size);
ssd=(aXsd+aYsd+aZsd);

%% Non-gait bout removal
%Removal of non-gait bouts determined by heuristic thresholding parameters

%determine the sections of inertial signal that are determined as "gait"
gait_indicator=abs(aMagm)>acc_threshold & ssd>ssd_threshold;

%switch gait_indictatior to determine the sections of inertial signal that
%are determined as "non-gait" or not bouts
% gait_indicator=~gait_indicator;

%Establish the points at which we transition from gait to non-gait and
%vice-versa; TRUE if values change. 
gait_transitions = [true; diff(gait_indicator(:)) ~= 0];  
% Indicate elements without repetitions
elem_rep = gait_indicator(gait_transitions);  
%Gather the indices of gait_transitions
transition_indexes = find([gait_transitions', true]);
% Determine the run length (i.e. for how many samples in a row there are
% "non-gait" events
run_length = diff(transition_indexes);                                

%The transition indexes contain the start and the end index of a
%transition as a continous vector. Reshape these indexes to seperate paired
%"start" and "end" points of the transitions
transition_indexes_=buffer(transition_indexes, 2);
% transition_indexes_(:, transition_indexes_(2, :)==0)=[];
%The run_length vector contains the (a) bout lengths of consecutive "non-gait"
%events as well as (b) the distance between consecutive "non-gait" bout events,
%which we are not interested in.  Reshape these indexes to seperate (a) and
%(b), where we can easily keep indexes for (a).
run_length=buffer(run_length,2);
% run_length=transition_indexes_(2, :)-transition_indexes_(1, :);
%only keep "non-gait" samples with a consecutive bout length greater than
%time_threshold (now measured in # of samples)
keep_bouts=run_length(1,:)/fs>time_threshold/fs;
transition_indexes_=transition_indexes_(:, keep_bouts);
[~, num_bouts]=size(transition_indexes_);
%indexing of 'transition_indexes' will add extra sample at the end which is
%longer than our signal. Simply go back one sample. 
if ~isempty(transition_indexes_) && transition_indexes_(end)>length(time)
transition_indexes_(end)=transition_indexes_(end)-1; end 

%Concatonate a vector of  "gait" bout indexes to keep 
keep_indexes=[];
for ii=1:num_bouts
    keep_indexes=[...
        keep_indexes, ...
        transition_indexes_(1, ii):transition_indexes_(2, ii)];
end 

keep_indexes(keep_indexes<discard_time)=[];
keep_indexes(keep_indexes>length(time)-discard_time)=[];

gait_indicator=zeros(length(time),1);
gait_indicator(keep_indexes)=1;

%create a dummy vector of indexes to keep; initailse as all indexes and
%then remove indexes associated with bouts of "non-gait". This is the final
%index to use to keep identified "gait bouts" onlys. 
% keep_indexes=1:length(time); 
% keep_indexes=keep_indexes(remove_indexes);
transition_indexes_(transition_indexes_<discard_time)=discard_time;
transition_indexes_(transition_indexes_>length(time)-discard_time)=length(time)-discard_time;
transition_indexes_(:, transition_indexes_(1,:)==transition_indexes_(2,:))=[];

num_bouts=size(transition_indexes_,2);
BOUT_DATA=cell(num_bouts,1);bout_length=NaN(num_bouts, 1);
for ii=1:num_bouts
ind=transition_indexes_(1, ii):transition_indexes_(2, ii); 
BOUT_DATA{ii}=SENSOR_DATA(ind, :);
bout_length(ii)=length(ind);
end 

BOUT_DATA(bout_length<time_threshold)=[];
num_bouts=length(BOUT_DATA);
%% Plot Bout Detection Results
% This (optional) section plots bout detection results for visual and
% confirmatory purposes. It can also be used to adjust the heuristic
% parameters
if isfield(options, 'plot_data') && options.plot_data
    options.plot_bout_detection=1;
else
    options.plot_bout_detection=0;
end

if isfield(options, 'plot_bout_detection') && options.plot_bout_detection 
    
    %Plot the theresholding parameters for gait / non-gait bout detection
    fig_threshold=figure;
    subplot(2,1,1)
    p1=plot(time, abs(aMagm), 'Color', [8,81,156]./255);
    hold on
    plot([time(1), time(end)], [acc_threshold,acc_threshold],  'Color', [8,81,156]./255)
    hold on
    p2=plot(time, ssd, 'k');
    hold on
    plot([time(1), time(end)], [ssd_threshold,ssd_threshold],  'k')
    hold on
%     xlabel('Time [s]')
    ylabel('Accel. (m\cdots^{-2})')
    legend([p1, p2],'aM', 'ssd')
    xlim([time(1)-1/fs, time(end)+1/fs])
    title('Bout Thresholding Parameters')

    sp2=subplot(2,1,2);
    stairs(time, gait_indicator, 'k')
    ylim([-0.1, 1.1])
    yticks([0,1])
    yticklabels({'n/a', 'gait'})
    xlim([time(1)-1/fs, time(end)+1/fs])
    xlabel('Time [s]')
    sp2.TickDir = 'out';
    box off
     title('Gait Detector')
    fig_threshold.Position=[325 447 625 218];
    
    % Visualise the segments / bouts of inertial sensor data considered "non-gait"
    fig_gait_segment=figure;
    plt_gait{1}=plot(time, aX, 'Color', [150, 150, 150]./255);
    hold on
    plt_gait{2}=plot(time, aY, 'Color', [150, 150, 150]./255);
    hold on
    plt_gait{3}=plot(time, aZ, 'Color', [150, 150, 150]./255);
    hold on
    for ii=1:num_bouts
        plt_gait{1, ii}=plot(BOUT_DATA{ii}(:,1), BOUT_DATA{ii}(:,2), 'b');
        hold on
        plt_gait{2, ii}=plot(BOUT_DATA{ii}(:,1), BOUT_DATA{ii}(:,3), 'b');
        hold on
        plt_gait{3, ii}=plot(BOUT_DATA{ii}(:,1), BOUT_DATA{ii}(:,4), 'b');
        hold on
    end
    xlabel('Time [s]')
    ylabel('Accel. (m\cdots^{-2})')
    legend([plt_gait{1, 1}], {'gait detected'}, 'Location', 'southeast')
    title('Gait Detector')
    xlim([time(1)-1/fs, time(end)+1/fs])
    %make the positioning nice
    fig_gait_segment.Position=[325 447 625 218];
    
    % visualise the signal after the non-gait bouts have been removed
    options.plot_title='Processed Sensor Signal (after non-gait removed)';
    for ii=1:num_bouts
    plot_data(BOUT_DATA{ii}, options);
    end 
end
end 
%EOF