
function [Infarct_SA_Strain] = SA_Strain_MI(results_struct,thresh);


% Example: [Infarct_SA_Strain] = SA_Strain_MI(results_struct,-20);

%returns timepoint index for end Diastole
[dias,tpt1] = max(results_struct.total_volumes);

%returns timepoint index for peak systole
[sys,tpt2]= min(results_struct.total_volumes);


%Orients wall thickness matrix (length_r) at a timepoint for plotting and analysis
data_tpt = transpose(squeeze(results_struct.surfarea_strain(tpt2,:,:)));

%Threshold value
% thresh = 0.6;

Thi = zeros(size(data_tpt));
Thi(data_tpt>thresh) = 1;
Thi(data_tpt<thresh) = 0;

%Percentage value of number of elements that fall under the threshold for
%infarct
Infarct_SA_Strain = mean2(Thi)*100; %(1-mean2(Thi))*100;


% for tpt = 1:60;
rdata = linspace(0,360,size(results_struct.endo_pointcloud,3) + 1);
rdata = wrapTo360(90 - rdata);
zdata = linspace(1,0,size(results_struct.endo_pointcloud,4) + 1);      zdata(end) = [];

figure;
h1 = polarPcolor(zdata,rdata,cat(2,data_tpt,data_tpt(:,1)));
c = colorbar; c.Location = 'Southoutside'; c.FontSize = 20; 
c.FontName = 'Times New Roman'; 
c.Ticks = [-40 -20 0];
c.TickLabels = {'-40%','-20%','0%'}; c.FontName = 'Arial'; 
colormap(flipud(parula));
caxis([-40,0]); 

figure;
h2 = polarPcolor(zdata,rdata,cat(2,Thi,Thi(:,1)));
c = colorbar; c.Location = 'Southoutside'; c.FontSize = 24;
caxis([0 .7]); 
c.Ticks = [-40 -20 0];
c.TickLabels = {'-40%','-20%','0%'}; c.FontName = 'Arial';

% pause(0.03);
% end
% c = createBullseye([0 0.5 1 0; 0.5 1 4 45; 1 1.5 6 0; 1.5 2 6 0]);
% set(c,'Color','k','LineWidth',4)


end
