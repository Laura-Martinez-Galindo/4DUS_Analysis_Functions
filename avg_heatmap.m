
%% function 
%var_name: needs to be in the format of SAX_analysis.GLcyclic_strain, SAX_analysis.LAX_length_strain, etc. 
%strain_type: Ecc, Ell, Err, Ea
%hm_title: needs to be in string format 
function [avg_strain]=avg_heatmap(results_struct,strain_type,hm_title) %delete h1 from L-side if throwing error

customColorArray=lbmap(256,'BrownBlue'); %Uses Light Bartlein package and customized using https://mycartablog.com/2012/03/15/a-good-divergent-color-palette-for-matlab/ 
%----- For Ecc and Ell ------
%results_struct=SAX_analysis; 
%var_name=SAX_analysis.GLcyclic_strain; 

%-----original attempt----------
%Creating average matrix
%concat_matrix=cat(3,results_struct(i).var_name); %concatinate strain matrices in third dimension
%avg_strain=mean(concat_matrix,3); %take average across third dimension

%Conditional statements for graph annotations
if ismember(strain_type,{'Ecc'}) %Checking for circumferential strain
   concat_matrix=cat(3,results_struct.GLcyclic_strain);
   avg_strain=mean(concat_matrix,3);

 %---------alternative method---------
%     for i= 1:length(results_struct)
%     concat_matrix(:,:,i)=results_struct(i).GLcyclic_strain;
%     end
%     avg_strain=mean(concat_matrix,3);
 %---------alternative method--------- 
    
    %Generate heatmap
    figure; 
    imagesc(avg_strain');

    axis image ; axis off ; caxis([-35 0]); 
    c = colorbar; c.Location = 'Eastoutside'; c.FontSize = 24; c.Ticks = [-35 -15 0];
    c.TickLabels = {'-35%','-15%','0%'}; c.FontName = 'Arial';
    %colormap(flipud(parula));
    colormap(customColorArray);
   
    yline(40, 'k--', 'LineWidth', 4);
    yline(20, 'k--', 'LineWidth', 4);
    %yline(30, 'k--', 'LineWidth', 4);
   
    if ~exist('hm_title','var') %in case a title is not passed
        hm_title='';
    else  
        title(hm_title)
    end

end 

if ismember(strain_type,{'Ell'}) %Checking for longitudinal strain
    for i= 1:length(results_struct)
    concat_matrix(:,:,i)=results_struct(i).LAX_length_strain;
    end
    
    avg_strain=mean(concat_matrix,3);
   
    figure
    imagesc(avg_strain');
    axis image ; axis off ; caxis([-25 0]); 
    c = colorbar; c.Location = 'Eastoutside'; c.FontSize = 24; c.Ticks = [-25 -12 0];
    c.TickLabels = {'-25%','-12%','0%'}; c.FontName = 'Arial';
    %colormap(flipud(parula));
    colormap(customColorArray);
    yline(12, 'k--', 'LineWidth', 4);
    yline(24, 'k--', 'LineWidth', 4);
    yline(36,'k--', 'LineWidth', 4);
    yline(48,'k--', 'LineWidth', 4);

   if ~exist('hm_title','var') %in case a title is not passed
    hm_title='Average Longitudinal Strain (%)';
   else  
    title(hm_title)
   end 

end



if ismember(strain_type,{'Ea'}) %need to adjust so that .mat struct file name does not have to be SAX_analysis
    concat_endo_pointcloud=cat(5,results_struct.endo_pointcloud); 
    concat_surfarea_strain=cat(4,results_struct.surfarea_strain); 
    concat_total_volumes=cat(3,results_struct.total_volumes);
    
    avg_endo_pointcloud=mean(concat_endo_pointcloud,5); 
    avg_surfarea_strain=mean(concat_surfarea_strain, 4);
    avg_strain=avg_surfarea_strain; %Saving as separate variable so that can be easily saved/output
    avg_total_volumes= mean(concat_total_volumes,3);
    
    %This function will return a polar SA strain plot at peak systole
    %example input: SA_Strain_DMD(SAX_compiled(1));

    %returns timepoint index for end Diastole
    %[dias,tpt1] = max(results_struct.total_volumes);

    %returns timepoint index for peak systole
    [~,tpt2]= min(avg_total_volumes);

    % %Orients wall thickness matrix (length_r) at a timepoint for plotting and analysis
    data_tpt = transpose(squeeze(avg_surfarea_strain(tpt2,:,:)));

    rdata = linspace(0,360,size(avg_endo_pointcloud,3) + 1);
    rdata = wrapTo360(90 - rdata);
    zdata = linspace(1,0,size(avg_endo_pointcloud,4) + 1);      zdata(end) = [];

    figure; %delete  "hm=" if throwing error
    h1 = polarPcolor(zdata,rdata,cat(2,data_tpt,data_tpt(:,1)));
    c = colorbar; c.Location = 'Southoutside'; c.FontSize = 20; 
    caxis([-60 0]); c.FontName='Arial';
    c.Ticks = [-60 -30 0];
    c.TickLabels = {'-60%', '-30%', '0%'}; 
    
    %if want outline----
    circ = createBullseye([0 0.25 1 0; 0.25 0.5 1 45; 0.5 0.75 1 0; .75 1 1 0]);% ([circ1_rho1 circ1_rho2 circ1_nSegs circ1_theta; circ2_rho1 .. ]
    set(circ,'Color','k','LineWidth',2,'LineStyle',"--")
    %----
    
    %clim([-60,0]); c.FontName = 'Arial';
    %colormap(flipud(parula));
    colormap(customColorArray)
    %colormap(parula);
    
     if ~exist('hm_title','var') %in case a title is not passed
        hm_title='Average Surface Area Strain (%)';
     else  
        title(hm_title)
     end 

end 


if ismember(strain_type,{'Err'}) %need to adjust so that .mat struct file name does not have to be SAX_analysis
    concat_length_r_strain=cat(4,results_struct.length_r_strain); 
    concat_total_volumes=cat(3,results_struct.total_volumes);
    concat_endo_pointcloud=cat(5,results_struct.endo_pointcloud); 
    
    avg_length_r_strain=mean(concat_length_r_strain,4);
    avg_strain=avg_length_r_strain; %Saving as separate variable so that can be easily saved/output
    avg_total_volumes= mean(concat_total_volumes,3);
    avg_endo_pointcloud=mean(concat_endo_pointcloud,5); 
    %This function will return a polar SA strain plot at peak systole
    %example input: SA_Strain_DMD(SAX_compiled(1));

    %returns timepoint index for end Diastole
    %[dias,tpt1] = max(results_struct.total_volumes);

    %returns timepoint index for peak systole
    [~,tpt2]= min(avg_total_volumes);

    % %Orients wall thickness matrix (length_r) at a timepoint for plotting and analysis
    % data_tpt = transpose(squeeze(results_struct.surfarea_strain(tpt2,:,:)));

    % Changing to the code below will give you a different output, needs to be
    % 60X60X60 data size
    data_tpt = transpose(squeeze(avg_length_r_strain(tpt2,:,:)));
    %data_tpt = transpose(squeeze(results_struct.radius_strain(tpt2,:,:)));

    rdata = linspace(0,360,size(avg_endo_pointcloud,3) + 1);
    rdata = wrapTo360(90 - rdata);
    zdata = linspace(1,0,size(avg_endo_pointcloud,4) + 1);      zdata(end) = [];

    figure; %delete  "hm=" if throwing error
    h1 = polarPcolor(zdata,rdata,cat(2,data_tpt,data_tpt(:,1)));
    c = colorbar; c.Location = 'Southoutside'; c.FontSize = 20; 
    caxis([0,40]); c.FontName = 'Arial';
    
    %clim([0,40]); c.FontName = 'Arial';
    %c.Ticks = [-50, -25, 0, 25];
    %c.Ticks = [-50, -25, 0];
    c.Ticks = [0, 20, 40];
    c.TickLabels = {'0%','20%','40%'}; 
    %c.TickLabels = {'-50%','-25%','0%'}; 
    c.TickLabels = {'0%','20%','40%'};
    %colormap(flipud(parula));
    colormap(flipud(customColorArray));
    
    %if want outline----
    circ = createBullseye([0 0.25 1 0; 0.25 0.5 1 45; 0.5 0.75 1 0; .75 1 1 0]);% ([circ1_rho1 circ1_rho2 circ1_nSegs circ1_theta; circ2_rho1 .. ]
    set(circ,'Color','k','LineWidth',2,'LineStyle',"--")
    %----
     if ~exist('hm_title','var') %in case a title is not passed
        hm_title='Average Radial Strain (%)';
     else  
        title(hm_title)
     end 

end 
end 