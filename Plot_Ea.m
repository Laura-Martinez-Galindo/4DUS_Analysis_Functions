
function Plot_Ea(results_struct)
%This function will return a polar SA strain plot at peak systole
%example input: SA_Strain_DMD(SAX_compiled(1));

%returns timepoint index for end Diastole
%[dias,tpt1] = max(results_struct.total_volumes);

%returns timepoint index for peak systole
[~,tpt2]= min(results_struct.total_volumes);

% %Orients wall thickness matrix (length_r) at a timepoint for plotting and analysis
data_tpt = transpose(squeeze(results_struct.surfarea_strain(tpt2,:,:)));

rdata = linspace(0,360,size(results_struct.endo_pointcloud,3) + 1);
rdata = wrapTo360(90 - rdata);
zdata = linspace(1,0,size(results_struct.endo_pointcloud,4) + 1);      zdata(end) = [];

%figure;

h1 = polarPcolor(zdata,rdata,cat(2,data_tpt,data_tpt(:,1)));
c = colorbar; c.Location = 'Southoutside'; c.FontSize = 20; 
caxis([-60 0]); c.FontName='Arial';
c.Ticks = [-60 -40, -20, 0];
c.TickLabels = {'-60','-40%','-20','0%'}; 
set(c,'visible','off'); %added temporarily
%----- If you want dotted lines on segments-----
%pause(0.03);
%%circ = [0 0.5 1 0; 0.5 1 4 45; 1 1.5 6 0; 1.5 2 6 0] %AHA 17 segment outline
%circ = createBullseye([0 0.25 1 0; 0.25 0.5 1 45; 0.5 0.75 1 0; .75 1 1 0]);% ([circ1_rho1 circ1_rho2 circ1_nSegs circ1_theta; circ2_rho1 .. ]
%set(circ,'Color','k','LineWidth',2,'LineStyle',"--")
%--------
%clim([-60,0]); c.FontName = 'Arial';
%colormap(flipud(parula));
%colormap(parula);
customColorArray=lbmap(256,'BrownBlue'); colormap(customColorArray);

end

