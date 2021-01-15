function HRV=hrv_measures(RR, f, pxx)
%% Function to return Heart Rate Variability (HRV) measures
%-------------------------------------------------------------------------%
%Input:
%     RR: A vector of RR interval series, in miliseconds [ms]
%     f:  The frequency vector returned by the Lomb-Scargle periodogram
%     pxx: The Lomb-Scargle power spectral density (PSD) estimate at f
% 
%Output: 
%     HRV: A table of HRV measures:
%      RR_mean: The mean RR interval
%      RR_std: The standard deviation in RR
%      LF_peak: The dominant freq. in the low-freq. range between 0.04-0.15 Hz.
%      HF_peak: The dominant freq. in the low-freq. range between 0.15-0.4 Hz
%      total_power: Total spectral power of all RR intervals up to 0.04 Hz
%      Lf_power: Total spectral power of all RR intervals between 0.04-0.15 Hz.
%      Hf_power: Total spectral power of all RR intervals between 0.15-0.4 Hz
%      Lf_power_norm: Normalised Lf_power
%      Hf_power_norm: Normalised Hf_power
%      Lf_Hf_ratio: Ratio of low to high frequency power
%-------------------------------------------------------------------------%
%% Andrew Creagh. andrew.creagh@eng.ox.ac.uk
%  Last modified on December 2020
%  Based on code modified from:
%   Andreotti, F., Carr, O., Pimentel, M.A.F., Mahdi, A., & De Vos, M.
%   (2017). Comparing Feature Based Classifiers and Convolutional Neural
%   Networks to Detect Arrhythmia from Short Segments of ECG. In Computing
%   in Cardiology. Rennes (France).
%-------------------------------------------------------------------------%
%%
% set frequency ranges for very low, low and high ranges (Hz)
vlow_thresh=0.003; %Very low frequency
low_thresh=0.04; 
mid_thresh=0.15;
high_thresh=0.4;
%%
HRV.RR_mean=mean(RR);
HRV.RR_std=std(RR);

[~,vlow_index]=min(abs(f-vlow_thresh));
[~,low_index]=min(abs(f-low_thresh));
[~,mid_index]=min(abs(f-mid_thresh));
[~,high_index]=min(abs(f-high_thresh));

% VLf=pxx(vlow_index:low_index);
Lf=pxx(low_index+1:mid_index);
Hf=pxx(mid_index+1:high_index);

% [~,very_low_peak_index]=max(VLf);
[~,low_peak_index]=max(Lf);
[~,high_peak_index]=max(Hf);

% HRV.VLf_peak=f(very_low_peak_index);
HRV.Lf_peak=f(low_peak_index+low_index);
HRV.Hf_peak=f(high_peak_index+mid_index);

HRV.total_power=trapz(f,pxx)*1000000;
if vlow_index~=1
    HRV.Lf_power=trapz(f(low_index-1:mid_index),pxx(low_index-1:mid_index))*1000000;%sum(Lf)*1000000;
    HRV.Hf_power=trapz(f(mid_index-1:high_index),pxx(mid_index-1:high_index))*1000000;%sum(Hf)*1000000;
elseif low_index~=1
    HRV.Lf_power=trapz(f(low_index-1:mid_index),pxx(low_index-1:mid_index))*1000000;%sum(Lf)*1000000;
    HRV.Hf_power=trapz(f(mid_index-1:high_index),pxx(mid_index-1:high_index))*1000000;%sum(Hf)*1000000;
elseif mid_index~=1
    HRV.Lf_power=trapz(f(low_index:mid_index),pxx(low_index:mid_index))*1000000;%sum(Lf)*1000000;
    HRV.Hf_power=trapz(f(mid_index-1:high_index),pxx(mid_index-1:high_index))*1000000;%sum(Hf)*1000000;
elseif high_index<length(pxx)
    HRV.Lf_power=trapz(f(low_index:mid_index),pxx(low_index:mid_index))*1000000;%sum(Lf)*1000000;
    HRV.Hf_power=trapz(f(mid_index:high_index+1),pxx(mid_index:high_index+1))*1000000;%sum(Hf)*1000000;
else
    HRV.Lf_power=trapz(f(low_index:mid_index),pxx(low_index:mid_index))*1000000;%sum(Lf)*1000000;
    HRV.Hf_power=trapz(f(mid_index:high_index),pxx(mid_index:high_index))*1000000;%sum(Hf)*1000000;    
end

HRV.Lf_power_norm=100*HRV.Lf_power/(trapz(f,pxx)*1000000);
HRV.Hf_power_norm=100*HRV.Hf_power/(trapz(f,pxx)*1000000);

HRV.Lf_Hf_ratio=HRV.Lf_power/HRV.Hf_power;

HRV=struct2table(HRV);

end 