
%Compilation code that will crreate a MATLAB object/variable with all of
%the results structures compiled together
%Last updated 04/30/2024 by EGR

directory=uigetdir(); %Folder with stored .mat files
foldernames = uigetfile('MultiSelect','on'); %All of the 4D .mat files need to be in the same folder

for i = 1:length(foldernames)    
matObj = matfile(append(directory,'/',foldernames{i}));
results_struct_compiled(i) = matObj.results_struct;
end

SAX_analysis=results_struct_compiled; %Naming results_struct_compiled as SAX_analysis so that it can be used in the other scripts

% After running this code you can use metric extraction
%[metric_comp,metric_grouped] = metric_extraction(SAX_compiled,[],[],foldernames);
