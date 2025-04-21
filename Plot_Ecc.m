%This code generates Ecc (circumferential strain) plots outside ofr the 4D GUI
%2/5/2024: 
% A) Turned plots into for loops to go through all of the datapoints in SAX_analysis 
% B) Added conditional statements for user to define (in FourD_analysis_functions_template) which plot type
% they want to generate


function Plot_Ecc(SAX_analysis,foldernames,EccHeatMap,EccSurfPlot,EjectionFraction,customColorArray)
nImages = numel(foldernames);
dimN = ceil(sqrt(nImages));
dimM = ceil(nImages/dimN);
nrows = min(dimN, dimM);
ncols = max(dimN, dimM);
%-----------------------------Heat Maps----------------------------------------
    if ismember(EccHeatMap,{'Yes','yes','Y','y'}) %Checking user input
        figure;
        for hm=1:length(foldernames) %hm=heatmap
            subplot(nrows,ncols,hm);
            imagesc(SAX_analysis(hm).GLcyclic_strain(:,:)');
            axis image ; axis off ; caxis([-35 0]); 
            c = colorbar; c.Location = 'Eastoutside'; c.FontSize = 24; c.Ticks = [-35 -15 0];
            c.TickLabels = {'-35%','-15%','0%'}; c.FontName = 'Arial';
            %colormap(flipud(parula));
            colormap(customColorArray);
            %yline(40, 'k--', 'LineWidth', 4);
            %yline(20, 'k--', 'LineWidth', 4);
            %yline(30, 'k--', 'LineWidth', 4);
            title(sprintf('%s', foldernames{hm}),'Interpreter', 'none' ); %Assigns file name as figure title
            set(colorbar,'visible','on'); %added temporarily
        end
         
    end 
%-----------------------------Surface Plots----------------------------------------
    if ismember(EccSurfPlot,{'Yes','yes','Y','y'}) 
        figure;
        for sp=1:length(foldernames) %sp=surface plots
            subplot(nrows,ncols,sp);
            surf(SAX_analysis(sp).GLcyclic_strain(:,:)','FaceAlpha','.9'); %Create a surface plot of data
            set(gca, 'ZDir', 'reverse');
            title(sprintf('%s', foldernames{sp}),'Interpreter', 'none'  ); %Assigns file name as figure title
            colormap(customColorArray)
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

    
%-----------------------------GL Cyclic Strain Across Cardiac Cycle--------------------------------------
% if ismember(GLavg,{'Yes','yes','Y','y'})
%     %GL=zeros(size(SAX_analysis));
%     %LS=zeros(size(SAX_analysis));
%         for a=1:length(foldernames)
%            figure(a+2*length(foldernames)); %so that does not overwrite other figures
%            GL(a) = SAX_analysis(a).GLcyclic_strain(a);
%            LS(a) = SAX_analysis(a).length_z_strain(a);
%          % Plots average Green Lagrange cyclic strain across cardiac cycle
%            plot(mean(GL(a),2));
%            plot(mean(LS(a),2));
%            %plots color figure representing each point on cardiac surface
%         end 
%        
% end 

fprintf('The script for plotting Ecc has ended. Thank you, come again. ')
end
