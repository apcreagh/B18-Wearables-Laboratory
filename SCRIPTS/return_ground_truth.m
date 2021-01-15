function [WD, SC]=return_ground_truth(pathname, filename, subject, device_location)

if ~(contains(filename, subject) && contains(filename, device_location))
    error('specified subject id or device location does not match input filename'); end 

load([pathname, filesep, 'groundtruth_SC.mat']);
load([pathname, filesep, 'groundtruth_WD.mat']);

index_WD=contains(groundtruth_WD.subject, subject) & contains(groundtruth_WD.device_location, device_location);
index_SC=contains(groundtruth_SC.subject, subject); 

WD=groundtruth_WD(index_WD, :);SC=groundtruth_SC(index_SC, :);

end