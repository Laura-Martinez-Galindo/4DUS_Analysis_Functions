%Create tiled figure 
figure(1)
Ecc_plots=tiledlayout(1,length(avgEcc_data), 'TileSpacing','tight')
nexttile; imagesc(avgEcc_j0(:,:)');  axis image ; axis off; yline(40, 'k--', 'LineWidth', 3); yline(20, 'k--', 'LineWidth', 3); 
       set(gca,'FontSize',12,'FontName','Arial');caxis([-35 0]); caxis([-35 0]); 

nexttile; imagesc(avgEcc_3wtac(:,:)');  axis image ; axis off ;  yline(40, 'k--', 'LineWidth', 3); yline(20, 'k--', 'LineWidth', 3);
        set(gca,'FontSize',12,'FontName','Arial');caxis([-35 0]) ;caxis([-35 0]); 

nexttile; imagesc(avgEcc_1wdetac(:,:)'); axis image ; axis off ; yline(40, 'k--', 'LineWidth', 3); yline(20, 'k--', 'LineWidth', 3);
        set(gca,'FontSize',12,'FontName','Arial');caxis([-35 0]); 

nexttile; imagesc(avgEcc_4wdetac(:,:)'); axis image ; axis off ; yline(40, 'k--', 'LineWidth', 3); yline(20, 'k--', 'LineWidth', 3);
        set(gca,'FontSize',12,'FontName','Arial');caxis([-35 0]);caxis([-35 0]); 

ylabel('Baseline')
c = colorbar; c.Location = 'Eastoutside'; c.FontSize = 24; c.Ticks = [-35 -15 0];
c.TickLabels = {'-35%','-15%','0%'}; c.FontName = 'Arial'; c.FontSize=14;
colormap(flipud(parula));
%% Trying with for-loop
close all

% Data variables (example variables)
avgEcc_data = {avgEcc_j0, avgEcc_3wtac, avgEcc_1wdetac, avgEcc_4wdetac};

figure(2)
Ecc_plots=tiledlayout(1,length(avgEcc_data), 'TileSpacing','tight');
% Loop through each data set
for i = 1:length(avgEcc_data)
    nexttile;
    imagesc(avgEcc_data{i}(:,:)');
    axis image;
    axis off;
    yline(40, 'k--', 'LineWidth', 3);
    yline(20, 'k--', 'LineWidth', 3);
    set(gca, 'FontSize', 12, 'FontName', 'Arial');
    caxis([-35 0]);

    if i==1
       axis on
       ylabel('Baseline')
      set(gca,'Xtick',[],'Ytick',[])
    end
end


c = colorbar; % Add colorbar
c.Location = 'Eastoutside'; c.FontSize = 14; c.Ticks = [-35 -15 0]; c.TickLabels = {'-35%', '-15%', '0%'}; c.FontName = 'Arial'; % Colorbar specs
colormap(flipud(parula));% Set colormap

%% testing creating structure with all of the averages workspaces
% Select all of the folders for the timepoints
SAX_analysis_folder= uigetdir(); %folder where the workspaces for SAX_compiled is saved %Ex: SAX_Analysis_compiled_workspace_for_MATLAB
SAX_analysis_files= uigetfile('MultiSelect','on'); %the .mat SAX_compiled files in the directory above 

for i = 1:length(SAX_analysis_files)    
SAX_analysis_directory = append(SAX_analysis_folder,'/',SAX_analysis_files(i)) ; %create the directory
SAX_analysis_directory=char(SAX_analysis_directory); %convert to string
SAX_analysis_all(i)=load(SAX_analysis_directory,'SAX_analysis');
end

%% testing for loop with subplot


% Create a new figure with a tiled layout
joinedFig = figure;
numPlots=length(SAX_analysis_all);


for i=1:numPlots
    results_struct=SAX_analysis_all(i).SAX_analysis; %these three lines are needed for the func
    strain_type='Ea';
    hm_title='';
    hm=avg_heatmap(results_struct, strain_type, hm_title); % Generate the individual figure using plot_Ea
   
end 

%% testing as ind lines
figure;
hm1=avg_heatmap(SAX_analysis_all(1).SAX_analysis, strain_type, hm_title);
figure
hm2=avg_heatmap(SAX_analysis_all(2).SAX_analysis, strain_type, hm_title);

figure;
 hSub1 = subplot(2,1,1);
 hSub2 = subplot(2,1,2);

 copyobj(hm1,hSub1); % hFigIAxes = findobj('Parent',fig_i,'Type','axes'); 
 copyobj(hm2,hSub2)