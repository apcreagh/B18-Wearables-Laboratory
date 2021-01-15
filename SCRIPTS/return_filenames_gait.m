function fileinfo=return_filenames_gait(pathname, device_location)
%% Function to return the file information from the smartphone dataset:
% Harle, R., & Brajdic, A. (2017). Research data supporting "Walk detection
% and step counting on unconstrained smartphones" [Dataset].
%--------------------------------------------------------------------------
% Input: 
%       pathname - the pathname the data is stored
%             e.g. 'C:\DATASETS\ubicomp13\'
%       device_location -  a string to indicate which device location data 
%                          to extract. The options are: 
%                           'hand_held'
%                           'back_pocket'
%                           'handbag'
%                           'front_pocket'
%                           'backpack'
% =========================================================================
% Output:
%       fileinfo - a table consisting of the filenames extrcated and the
%       corresponding subject ID as strings. 
%--------------------------------------------------------------------------
%% Andrew Creagh. andrew.creagh@eng.ox.ac.uk
% Last modified in December 2020
%% Extract Data
%check files exist
files=dir([pathname, filesep, '*.mat']);
filename(:,1)={files.name};
index=contains({files.name}, {device_location}, 'IgnoreCase',true);
filename=filename(index);
subject=cellfun(@get_subject, filename, 'UniformOutput', false);
fileinfo=table(filename, subject);
end 
%helper function to gather the subject ID
function subject=get_subject(filename)
ui=regexp(filename, '_');
subject=filename(1:ui-1);
end
%EOF 