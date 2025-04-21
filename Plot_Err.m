
function Plot_Err(results_struct)
    %This function will return a polar SA strain plot at peak systole

    %Total volumes (60, 1), #60 frames en los que se midio volumen del corazon

    %cuando corazon esta más contraído, sístole máxima (peak systole)

    [vol_sistole, tpt2] = min(results_struct.total_volumes); %[indice, minimum value]
    %Desempaquetar: (valor mínimo, indice)
    %tpt2: instante de tiempo donde el volumen es el menor, sístole máxima
    %es en ese instante de tiempo que vamos a extraer los datos de strain

    %MAPA POLAR -------------------------------------------------------------------------------------
    %Length fibras musculares

    % Orients wall thickness matrix (length_r) at a timepoint for plotting and analysis
    results_struct.length_r_strain(tpt2,:,:)
    %(T, Z, R)

    data_tpt = transpose(squeeze(results_struct.length_r_strain(tpt2,:,:)));
    %data_tpt = transpose(squeeze(results_struct.radius_strain(tpt2,:,:)));

    %[0..360]
    %endo_poinclud: nube de puntos superficie endocardica (interna) del corazón
    %representación 3D de la superficie interna del ventriculo
    %size de la 3era dimensión, numero de segmentos radiales del ventriculo
    rdata = linspace(0,360,size(results_struct.endo_pointcloud,3) + 1);
    rdata = wrapTo360(90 - rdata);
    zdata = linspace(1,0,size(results_struct.endo_pointcloud,4) + 1);
    zdata(end) = [];

    %figure;
    %cat(dim en la que se concatena, matriz completa y el primer valor de la misma). apilo matrices horizontalmente, a lo largo de columnas y le pego la primera columna de matriz original pa cerrar el circulo
    h1 = polarPcolor(zdata,rdata,cat(2,data_tpt,data_tpt(:,1)));
    c = colorbar; c.Location = 'Southoutside'; c.FontSize = 20; 
    caxis([0,40]); c.FontName = 'Arial';

    %c.Ticks = [-50, -25, 0, 25];
    %c.Ticks = [-50, -25, 0];
    %c.Ticks = [-20, 0, 20, 40]
    %c.TickLabels = {'-50%','-25%','0%','25%'}; 
    %c.TickLabels = {'-50%','-25%','0%'}; 
    %c.TickLabels = {'-20%','0%','20%','40%'};

    %----- If you want dotted lines on segments-----
    %pause(0.03);
    %%circ = [0 0.5 1 0; 0.5 1 4 45; 1 1.5 6 0; 1.5 2 6 0] %AHA 17 segment outline
    %circ = createBullseye([0 0.25 1 0; 0.25 0.5 1 45; 0.5 0.75 1 0; .75 1 1 0]);% ([circ1_rho1 circ1_rho2 circ1_nSegs circ1_theta; circ2_rho1 .. ]
    %set(circ,'Color','k','LineWidth',2,'LineStyle',"--")
    %----------
    customColorArray=lbmap(256,'BrownBlue'); colormap(flipud(customColorArray));
    set(c,'visible','on'); %added temporarily
end

