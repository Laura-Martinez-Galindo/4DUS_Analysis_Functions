%% This is a template that calls the functions in 4DUS_Analysis_Functions
%--------Laundry list----
% Find better way of populating EFtable and heatmaps into workspace
% Ask conner about metric_extraction from Step 1 and about GLcyclic averaging (see Plot_Ecc)

%------- Section 1: Looping through heatmaps for animals individualls ------------

%% Generate the SAX_analysis (results struct necessary for compiling data)

[files, directory] = uigetfile('*.mat', 'Select .mat files', 'MultiSelect', 'On'); %guarda dos valores, como una tupla
%solo muestra archivos .mat
%Titulo: "Select .mat files"
%Se pueden seleccionar varios archivos a la vez

if ischar(files) %un solo archivo
    files = {files}; %convertir a cell array
end

%results_struct_compiled = struct(); %crear un diccionario vacio, lo llenamos con diccionarios
%no es en si un diccionario sno array que guarda clases de java, guarda atributos y datos
%rray de esructs, donde cada struct viene de un archivo diferente

for file_index = 1:length(files)
    full_path = fullfile(directory, files{file_index}); %funciona como os.path.join
    mat_object = matfile(full_path); %crea objeto del achivo mat real sin cargarlo todo en memoria, solo atributos
    results_struct_compiled(file_index) = mat_object.results_struct; %obtener el atributo results_struct del archivo
    %lo guarda en el índice i del arreglo compilado
end

fields = fieldnames(results_struct_compiled(1));

for i = 1:numel(fields)
    field = fields{i};
    value = results_struct_compiled(1).(field);
    fprintf('%s: %s [%s]\n', field, class(value), mat2str(size(value)));
end

SAX_analysis = results_struct_compiled; %Naming results_struct_compiled as SAX_analysis so that it can be used in the other scripts
SAX_compiled = results_struct_compiled; %Also saving as SAX_compiled to be used in compile_regional codes

%Determining size of subplot
nImages = numel(files);
dimN = ceil(sqrt(nImages));
dimM = ceil(nImages/dimN); %ceil: redondeo hacia arriba
nrows = min(dimN, dimM);
ncols = max(dimN, dimM);
%queremos más columnas que filas

% After running this code you can use metric extraction
%[metric_comp,metric_grouped] = metric_extraction(SAX_compiled,[],[],foldernames);

%% Circumferential (ECC) Graphs and Heatmaps
%Creates heatmap for all animals *individually* (each row of SAX_compiled)
EccHeatMap='Y'; %Type 'Yes' or 'No' for creating Ecc heatmaps
EccSurfPlot='N'; %Type 'Yes' or 'No' for creating Ecc surface plots
EjectionFraction='N'; %Type 'Yes' or 'No' for calculating EF
%GLavg='Y'; %not sure if works

customColorArray=lbmap(256,'BrownBlue'); 
Plot_Ecc(SAX_analysis,files,EccHeatMap,EccSurfPlot,EjectionFraction,customColorArray); 

%% Longitudinal Graphs (Ell) and Heatmaps
%Creates heatmap for all animals *individually* (each row of SAX_compiled)
EllHeatMap='Y'; %Type 'Yes' or 'No' for creating Ecc heatmaps
EllSurfPlot='Y'; %Type 'Yes' or 'No' for creating Ecc surface plots
EjectionFraction='N'; %Type 'Yes' or 'No' for calculating EF
%GLavg='Y'; %Type 'Yes' or 'No' for calculating EF

customColorArray=lbmap(256,'BrownBlue'); 
Plot_Ell(SAX_analysis,files,EllHeatMap,EllSurfPlot,EjectionFraction,customColorArray);

%% Radial Graphs (Err)
N = length(SAX_analysis); %numero de archivos
nrows = ceil(sqrt(N));
ncols = ceil(N / nrows);

%figure;
%results_struct_compiled(1).length_r;
for i = 1:N
    figure;
    results_struct = SAX_analysis(i); % Extract the current structure
    Plot_Err(results_struct); % Generate the avg heatmap
end

% tiledlayout(nrows, ncols, 'TileSpacing', 'Compact', 'Padding', 'tight');
% 
% for i = 1:length(SAX_analysis)
%     nexttile
%     results_struct = SAX_analysis(i); % Extract the current structure
%     Plot_Err(results_struct); % Generate the avg heatmap
% end

%% AHA 17-Segment Radial Graphs (Err)

for i = 1:N
    figure;
    results_struct = SAX_analysis(i); % Extract current structure
    Plot_Err_AHA(results_struct); % Call the new 17-segment plot function
    %title(sprintf('Subject %d: AHA 17-Segment Radial Strain', i), 'FontSize',14);
end

%% Extended AHA 17-Segment Radial Graphs (Err)

more_segments = 1; % Double the number of angular segments
more_rings = 1; % Increase the number of longitudinal rings

for i = 1:N
    figure;
    results_struct = SAX_analysis(i);
    Plot_Err_AHA_Extended(results_struct, more_segments, more_rings);
end

%% Surface Area Graphs (Eaa)
N = length(SAX_analysis);
nrows = ceil(sqrt(N)); % Optimal number of rows
ncols = ceil(N / nrows); % Corresponding number of columns

 for i = 1:length(SAX_analysis)
     figure
     results_struct = SAX_analysis(i); % Extract the current structure
     Plot_Ea(results_struct); % Generate the avg heatmap
 end


% tiledlayout(nrows, ncols, 'TileSpacing', 'Compact', 'Padding', 'tight');

% for i = 1:length(SAX_analysis)
%     nexttile
%     results_struct = SAX_analysis(i); % Extract the current structure
%     Plot_Ea(results_struct); % Generate the avg heatmap
% end


%% Average heatmaps
%------- Section 2: Creating Average Plots------------
% This will create the average of a desired strain type based on the SAX_analysis .mat structure
% As of current, you have to run each strain type separately 

results_struct=SAX_analysis; 
%var_name='GLcyclic_strain'; %Example: GLcyclic_strain %if doing Ea or Err, it doesn't matter what you write here
strain_type='Ell'; %Options: Ecc, Ell, Ea, Err
hm_title= 'J0: Average Ecc strain (%)'; % Optional

[avg_strain]=avg_heatmap(results_struct, strain_type, hm_title);


%[avg_strain]=avg_heatmap(results_struct, strain_type);
%% If want to generate average heatmaps for all time points all at once
% Select all of the folders for the timepoints
SAX_analysis_folder= uigetdir(); %folder where the workspaces for SAX_compiled is saved %Ex: SAX_Analysis_compiled_workspace_for_MATLAB
SAX_analysis_files= uigetfile('MultiSelect','on'); %the .mat SAX_compiled files in the directory above 

for i = 1:length(SAX_analysis_files)    
    SAX_analysis_directory = append(SAX_analysis_folder,'/',SAX_analysis_files(i)) ; %create the directory
    SAX_analysis_directory=char(SAX_analysis_directory); %convert to string
    SAX_analysis_all(i)=load(SAX_analysis_directory,'SAX_analysis');
end

for i=1:length(SAX_analysis_all)
    results_struct=SAX_analysis_all(i).SAX_analysis; %these three lines are needed for the func
    strain_type='Err';
    hm_title='';
    hm=avg_heatmap(results_struct, strain_type, hm_title); % Generate the avg heatmap
    colorbar off
end 

%% Create stand alone colorbar 
customColorArray=flipud(lbmap(256,'BrownBlue')); %Uses Light Bartlein package and customized using https://mycartablog.com/2012/03/15/a-good-divergent-color-palette-for-matlab/ 

figure
ax=axes; ax.Visible='off';
c = colorbar; c.Location = 'Southoutside'; c.FontSize = 24; c.FontName = 'Arial';
colormap(flipud(customColorArray));

% %No labels, only ticks
% caxis([-35 0]); 
% c.Ticks = [-35 -17 0];
% c.TickLabels = {'','',''}; 

%---uncomment as needed---
%%Ecc 
% caxis([-35 0]); 
% c.Ticks = [-35 -17 0];
% c.TickLabels = {'0%','-17%','-35%'}; 

%%Ell
% caxis([-25 0]); 
% c.Ticks = [-25 -12 0];
% c.TickLabels = {'0%','-12%','-25%'};

%Err
% caxis([0 40]); 
% colormap(flip(customColorArray));
% c.Ticks = [0 20 40];
% c.TickLabels = {'0%','20%','40%'};

%%Esa
caxis([-60 0]); 
c.Ticks = [-60 -30 0];
c.TickLabels = {'0%','-30%','60%'};