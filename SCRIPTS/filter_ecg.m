function filtered_signal=filter_ecg(signal,fs, varargin)
%% Function to band-pass filter ECG data
% Input:
%      signal: a [N x 1] vector of ECG data, where N are the number of samples;
%      fs:     sampling frequency [Hz]
%      Fhigh:  high-pass frequency [Hz]
%              default: 0.5 Hz
%      Flow:   low-pass frequency [Hz]
%              default:  100 Hz
%      Norder: filter order 
%              default:4
% Output:
%      filtered_signal: a [N x 1] vector of band-pass filtered ECG data 
%--------------------------------------------------------------------------
%% Andrew Creagh. andrew.creagh@eng.ox.ac.uk
%  Last modified on December 2020
%% Parse Arguments
optargs = {0.5 100 4};  % default values for input arguments
newVals = cellfun(@(x) ~isempty(x), varargin);
optargs(newVals) = varargin(newVals);
[Fhigh, Flow, Norder] = optargs{:};
clear optargs newVals
%% Design the filter and apply filtering to the signal
d_bp=design(fdesign.bandpass('N,F3dB1,F3dB2',Norder,Fhigh,Flow,fs),'butter');
%Convert to transfer function
[b_bp,a_bp] = tf(d_bp);
filtered_signal = filtfilt(b_bp,a_bp,signal);
end 
%EOF