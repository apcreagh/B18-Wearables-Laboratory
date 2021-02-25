function [steps_counted, num_steps_detected, cadence]=run_smartphone_gait(pathname, filename, subject, device_location, options)
%%


%%
fprintf(' filename: %s\n subject ID: %s\n device location: %s\n',...
    string(filename), string(subject), string(device_location))

RAW_DATA=load(string(strcat(pathname, filesep, filename)));
DATA=[RAW_DATA.accTs', RAW_DATA.accData];


aX=DATA(:, 2); 
aY=DATA(:, 3); 
aZ=DATA(:, 4); 
t=DATA(:, 1);
dt=diff(t);

fs=round(1/median(dt(dt~=0)));

if isfield(options, 'plot_data') && options.plot_data
options.plot_title='Raw Sensor Signal';
plot_data([t, aX, aY, aZ], options);
end 

%% Filtering
fc=5; %cut off freqyuency (for exampple 5 Hz)
n=4; %4th order
Wn=fc/fs;
% design the filter
[B,A] = butter(n, Wn);
%apply filter to X-, Y, Z- axis inertail sensor data
aX = filter(B, A, aX);                                     
aY = filter(B, A, aY);                                     
aZ = filter(B, A, aZ); 

aX=aX-mean(aX);aY=aY-mean(aY);aZ=aZ-mean(aZ);
aM=sqrt(aX.^2+aY.^2+aZ.^2);

if isfield(options, 'plot_data') && options.plot_data
options.plot_title='Filtered Sensor Signal';
plot_data([t, aX, aY, aZ], options);
end 

%% Trend Removal
window=1*fs;
aX=aX-movmean(aX,window);aY=aY-movmean(aY,window);aZ=aZ-movmean(aZ,window);
aM=aM-movmean(aM,window);

%% GROUND Truth
[WD, SC]=return_ground_truth(pathname, filename, subject, device_location);
start_index=find(t>WD.start_sample/fs, 1, 'first');
end_index=find(t<=WD.end_sample/fs, 1, 'last');

if isfield(options, 'plot_data') && options.plot_data
fig=figure; 
p1=plot(t, aM, 'Color', [150, 150, 150]./255);
hold on
p2=plot(t(start_index:end_index), aM(start_index:end_index), 'k');
xlim([t(1)-1/fs, t(end)+1/fs])
xlabel('Time [s]')
ylabel('Acceleration (m\cdots^{-2})')
legend(p2, 'Ground Truth: Gait Recorded')
fig.Position=[325 447 625 218];
end 

%%
[SENSOR_DATA_OUT, keep_indexes, remove_indexes]=walking_detection([t, aX, aY, aZ, aM], fs, options);

bout_index=1;
time=SENSOR_DATA_OUT{bout_index}(:, 1);
% time=time-time(1);
% aX=SENSOR_DATA_OUT{bout_index}(:, 2);
% aY=SENSOR_DATA_OUT{bout_index}(:, 3);
% aZ=SENSOR_DATA_OUT{bout_index}(:, 4);
aMag=SENSOR_DATA_OUT{bout_index}(:, 5);

[~,locs]=findpeaks(aMag,'MinPeakDistance',options.MinPeakDistance*fs, 'MinPeakHeight', options.MinPeakHeight);

if isfield(options, 'plot_data') && options.plot_data
fig=figure;
p1=plot(time, aMag, 'k');
hold on
p2=plot(time(locs), aMag(locs), 'ro');
xlim([time(1)-1/fs, time(end)+1/fs])
xlabel('Time [s]')
ylabel('Acceleration (m\cdots^{-2})')
legend(p2, 'Steps Identified')
title('Step Detection')
fig.Position=[325 447 625 218];
end 

num_steps_detected=length(locs);
cadence=num_steps_detected/(max(time)-min(time))*60; %change kindly provided by Holly Mortimer <holly.mortimer@univ.ox.ac.uk>; 
steps_counted=SC.steps_counted;

fprintf(' Recorded Steps #: %i\n Detected Steps #: %i\n Cadence %0.2f\n', steps_counted, num_steps_detected, cadence);

end 
%EOF
