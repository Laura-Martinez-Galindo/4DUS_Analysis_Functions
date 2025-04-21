%This code generates Ell (circumferential strain) plots outside ofr the 4D GUI
%2/5/2024: 
% A) Turned plots into for loops to go through all of the datapoints in SAX_analysis 
% B) Added conditional statements for user to define (in FourD_analysis_functions_template) which plot type
% they want to generate

%Laundry list: 

% Find a way to save and output ejection fraction 

function Plot_Ell(SAX_analysis,foldernames,EllHeatMap,EllSurfPlot,EjectionFraction,customColorArray)
nImages = numel(foldernames);
dimN = ceil(sqrt(nImages));
dimM = ceil(nImages/dimN);
nrows = min(dimN, dimM);
ncols = max(dimN, dimM);


%-----------------------------Heat Maps----------------------------------------
    if ismember(EllHeatMap,{'Yes','yes','Y','y'}) %Checking user input
        figure;
        for hm=1:length(foldernames) %hm=heatmap
            subplot(nrows,ncols,hm);
            imagesc(SAX_analysis(hm).LAX_length_strain(:,:)');
            axis image ; axis off ; caxis([-25 0]); %caxis([-25 0])
            c = colorbar; c.Location = 'Eastoutside'; c.FontSize = 24; c.Ticks = [-25 -12 0];
            c.TickLabels = {'-25%','-12%','0%'}; c.FontName = 'Arial';
            %colormap(flipud(parula));
            colormap(customColorArray);
            %yline(15, 'k--', 'LineWidth', 4);
            %yline(30, 'k--', 'LineWidth', 4);
            %yline(45,'k--', 'LineWidth', 4);
            title(sprintf('%s', foldernames{hm}),'Interpreter', 'none' ); %Assigns file name as figure title
            set(colorbar,'visible','off'); %added temporarily
        end
    end 
%-----------------------------Surface Plots----------------------------------------
    if ismember(EllSurfPlot,{'Yes','yes','Y','y'}) 
        figure;
        for sp=1:length(foldernames) %sp=surface plots
            subplot(nrows,ncols,sp);
            %figure(sp+length(foldernames)); %made index fig+length(foldernames) so that new 
            surf(SAX_analysis(sp).LAX_length_strain(:,:)'); %Create a surface plot of data
             title(sprintf('%s', foldernames{sp}),'Interpreter', 'none'  ); %Assigns file name as figure title
        end
    end 

%-----------------------------Ejection Fraction----------------------------------------
    if ismember(EjectionFraction,{'Yes','yes','Y','y'})
    % Calculates Ejection Fraction
        EF=zeros(length(foldernames),1);
        for e=1:length(foldernames) %e=ejectionfraction
            V_Diast(e)=max(SAX_analysis(e).total_volumes);
            V_syst(e) = min(SAX_analysis(e).total_volumes);
            EF(e) = ( V_Diast-V_syst) / V_Diast;
        end 
       EFtable=table(foldernames.',EF)
       %save('EFtable.mat','EFtable');
    end 

    


fprintf('The script for plotting Ell has ended. Please save plots and EF values. :)')
end

%% -------------
% function Plot_Ell(SAX_analysis)
% 
% %figure; imagesc(SAX_analysis.GLcyclic_strain(:,:)');
% figure; imagesc(SAX_analysis.LAX_length_strain(:,:)');
% axis image ; axis off ; caxis([-20 0]); 
% c = colorbar; c.Location = 'Eastoutside'; c.FontSize = 24; 
% c.Ticks = [-20 -10 0];
% c.TickLabels = {'-30%','-15%','0%'}; 
% c.FontName = 'Arial';
% colormap(flipud(parula));
% yline(12.5, 'k--', 'LineWidth', 4);
% yline(25, 'k--', 'LineWidth', 4);
% yline(37.5, 'k--', 'LineWidth', 4);
% yline(50, 'k--', 'LineWidth', 4);
% 
% %surf(SAX_analysis.LAX_length_strain(:,:)'); %Create a surface plot of data
% 
% end



% 
% GL = SAX_analysis.GLcyclic_strain;
% LS = SAX_analysis.LAX_length_strain;
% 
% %Plots average Green Lagrange cyclic strain across cardiac cycle
% plot(mean(GL,2));
% plot(mean(LS,2));
