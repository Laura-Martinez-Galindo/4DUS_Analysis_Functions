function Plot_Err_AHA_Extended(results_struct, more_segments, more_rings)
    % Function to display cardiac strain data in different AHA model formats
    % Format 1: Standard AHA 17-segment model
    % Format 2: Double the number of angular segments
    % Format 3: Increased number of longitudinal rings

    % Set colormap
    colormap(flipud(lbmap(256,'BrownBlue')));


    
    % Determine which format to use
    if more_segments == 0 && more_rings == 0
        Plot_Err_AHA(results_struct);
    elseif more_segments == 1 && more_rings == 0
        % Format 2: Double the number of segments
        plotDoubleSegmentsAHA(results_struct);
    elseif more_segments == 0 && more_rings == 1
        % Format 3: More rings
        plotMoreRingsAHA(results_struct);
    else
        % Both more segments and more rings
        plotBothExtendedAHA(results_struct);
    end
    
    % Add coronary territory labels based on standard AHA model
    % LAD territory (anterior/septal)
    [x_lad, y_lad] = pol2cart(deg2rad(90), 1.2);
    text(x_lad, y_lad, 'LAD', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 13);
    
    % RCA territory (inferior)
    [x_rca, y_rca] = pol2cart(deg2rad(210), 1.2);
    text(x_rca, y_rca, 'RCA', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 13);
    
    % LCX territory (lateral)
    [x_lcx, y_lcx] = pol2cart(deg2rad(330), 1.2);
    text(x_lcx, y_lcx, 'LCX', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 13);
    
    % Set axis properties
    axis equal off;
    caxis([0,40]); % Adjust caxis if needed
    cb = colorbar('SouthOutside','FontSize',12);
    xlabel(cb, 'Strain (%)', 'FontWeight', 'bold');

end

% Function to plot AHA model with double the number of segments (Format 2)
function plotDoubleSegmentsAHA(data)

    metric_data = data.length_r_strain;
    [numT,numR,numZ] = size(metric_data);
    region_avgs   = zeros(numT,33);

    %base,    mid    apical   apex
    lbR = [60,90,  120,150,  180,210,  240,270,  300,330,  0,30,    60,90,  120,150,  180,210,  240,270,  300,330,  0,30    45,90,  135,180,  225,270,  315,0    0];
    ubR = [90,120,  150,180,  210,240,  270,300,  330,0,  30,60,    90,120,  150,180,  210,240,  270,300,  330,0,  30,60    90,135,  180,225,  270,315,  0,45    360];

    lbZ = [0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,  0.4,0.4,0.4,0.4,0.4,0.4,0.4,0.4,0.4,0.4,0.4,0.4,  0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,  0];
    ubZ = [1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,  0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,  0.4,0.4,0.4,0.4,0.4,0.4,0.4,0.4,  0.1];
    
    % Create points for indexing
    rpts_sub = linspace(0, 360, numR+1); rpts_sub(end) = []; %elimina el ultimo punto
    zpts_sub = (1:numZ)./numZ;

    for j = 1:33 %j:segmento, recorro segmentos
        for k = 1:numT %k, timepoint, recorro timepoints
            %recorre 17 segmentos AHA, por cada segmento
            %por cada segmento, recorre todos los frames temporales
            %caso normal
            if lbR(j) < ubR(j) %lbR y ubR tienen 17 pos, recorro ambos a la vez, y compar
                region_avgs(k,j)   = mean(lin_array(metric_data(k,rpts_sub >= lbR(j) & rpts_sub < ubR(j),zpts_sub > lbZ(j) & zpts_sub <= ubZ(j))));
            else
                %para segmentos que cruzan el 0, como el 16
                %seleccionar puntos donde angulo es mayor a lower y es menor a 360 de la lista de angulos
                %o seleccionar angulo mayor a 0 y menor a upper de la lista de angulos
    
                rpts_sub_boo = (rpts_sub >= lbR(j) & rpts_sub < 360) | (rpts_sub >= 0 & rpts_sub < ubR(j));
                %hasta aqui solo filtro angulos que pueden funcionar
                
                region_avgs(k,j)   = mean(lin_array(metric_data(k,rpts_sub_boo,zpts_sub > lbZ(j) & zpts_sub <= ubZ(j))));
            end
        end
    end
    
    [~, tpt_systole] = min(data.total_volumes);
    segment_values = region_avgs(tpt_systole,:);
    rho = [0, 0.2, 0.4, 0.7, 1]; % Radii boundaries for segments
    %segment_labels = [repelem(1:16, 2), 17];
    segment_labels = 1:33;

    % --- Basal (segment 1-6) ---
    basal_angles = linspace(60, 360+30, 12);

    %va de angulo a angulo + 60 porque al ser 6 rebanadas, cada una mide 60, coger el valor de AHA en el array de structs, centrar etiqueta en +30
    for k = 1:12
        Plot_Segment(rho(4), rho(5), basal_angles(k), basal_angles(k)+30, segment_values(k), basal_angles(k)+15, rho(4), segment_labels(k));
    end

    % --- Mid (segments 7–12) ---
    mid_angles = linspace(60, 360+30, 12);
    for k = 1:12
        Plot_Segment(rho(3), rho(4), mid_angles(k), mid_angles(k)+30, segment_values(k+12), mid_angles(k)+15, rho(3), segment_labels(k+12));
    end

    % --- Apical ring (segments 13–16) ---
    apical_angles = [45 90 135 180 225 270 315 0];
    for k = 1:8
        Plot_Segment(rho(2), rho(3), apical_angles(k), apical_angles(k)+45, segment_values(k+24), apical_angles(k)+22.5, rho(2), segment_labels(k+24));
    end

    % --- Apex (segment 17) ---
    theta_circle = linspace(0,2*pi,100);
    fill(rho(2)*cos(theta_circle), rho(2)*sin(theta_circle), segment_values(33), 'EdgeColor', 'k', 'LineWidth', 2);
    text(0, 0, num2str(segment_labels(33)), 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 12);

end

% Function to plot AHA model with more rings (Format 3)
function plotMoreRingsAHA(data)
    metric_data = data.length_r_strain;
    [numT,numR,numZ] = size(metric_data);
    region_avgs   = zeros(numT,33);

    %base,    mid    apical   apex

    lbR = [ 60,120,180,240,300,0  , 60,120,180,240,300,0  ,     60,120,180,240,300,0  , 60,120,180,240,300,0  ,         45,135,225,315, 45,135,225,315,        0  ]; %limites inferiores pa cada segmento
    ubR = [120,180,240,300,360,60 , 120,180,240,300,360,60 ,    120,180,240,300,360,60 , 120,180,240,300,360,60 ,       135,225,315,45 , 135,225,315,45 ,     360]; %limites superiores pa cada segmento
    
    lbZ = [0.85,0.85,0.85,0.85,0.85,0.85      0.7,0.7,0.7,0.7,0.7,0.7,     0.55,0.55,0.55,0.55,0.55,0.55,       0.4,0.4,0.4,0.4,0.4,0.4,       0.25,0.25,0.25,0.25,        0.1,0.1,0.1,0.1,         0  ];
    ubZ = [1.0,1.0,1.0,1.0,1.0,1.0,      0.85,0.85,0.85,0.85,0.85,0.85,       0.7,0.7,0.7,0.7,0.7,0.7,          0.55,0.55,0.55,0.55,0.55,0.55,    0.4,0.4,0.4,0.4,         0.25,0.25,0.25,0.25,    0.1];

    % Create points for indexing
    rpts_sub = linspace(0, 360, numR+1); rpts_sub(end) = []; %elimina el ultimo punto
    zpts_sub = (1:numZ)./numZ;

    for j = 1:33 %j:segmento, recorro segmentos
        for k = 1:numT %k, timepoint, recorro timepoints
            %recorre 17 segmentos AHA, por cada segmento
            %por cada segmento, recorre todos los frames temporales
            %caso normal
            if lbR(j) < ubR(j) %lbR y ubR tienen 17 pos, recorro ambos a la vez, y compar
                region_avgs(k,j) = mean(lin_array(metric_data(k,rpts_sub >= lbR(j) & rpts_sub < ubR(j),zpts_sub > lbZ(j) & zpts_sub <= ubZ(j))));
            else
                %para segmentos que cruzan el 0, como el 16
                %seleccionar puntos donde angulo es mayor a lower y es menor a 360 de la lista de angulos
                %o seleccionar angulo mayor a 0 y menor a upper de la lista de angulos
    
                rpts_sub_boo = (rpts_sub >= lbR(j) & rpts_sub < 360) | (rpts_sub >= 0 & rpts_sub < ubR(j));
                %hasta aqui solo filtro angulos que pueden funcionar
                
                region_avgs(k,j) = mean(lin_array(metric_data(k,rpts_sub_boo,zpts_sub > lbZ(j) & zpts_sub <= ubZ(j))));
            end
        end
    end
    
    [~, tpt_systole] = min(data.total_volumes);
    segment_values = region_avgs(tpt_systole,:);
    rho = [0, 0.1, 0.25, 0.4, 0.55, 0.7, 0.85, 1]; % Radii boundaries for segments
    segment_labels = [repelem(1:16, 2), 17];

    % --- Basal (segment 1-6) ---
    basal_angles = [60 120 180 240 300 360];
    %va de angulo a angulo + 60 porque al ser 6 rebanadas, cada una mide 60, coger el valor de AHA en el array de structs, centrar etiqueta en +30

    contador = 1;
    for k = 1:6
        Plot_Segment(rho(7), rho(8), basal_angles(k), basal_angles(k)+60, segment_values(contador), basal_angles(k)+30, rho(7), segment_labels(contador));
        Plot_Segment(rho(6), rho(7), basal_angles(k), basal_angles(k)+60, segment_values(contador+1), basal_angles(k)+30, rho(6), segment_labels(contador+1));
        contador = contador + 2;
    end

    % --- Mid (segments 7–12) ---
    mid_angles = [60 120 180 240 300 360];
    contador = 1;
    for k = 1:6
        Plot_Segment(rho(5), rho(6), mid_angles(k), mid_angles(k)+60, segment_values(contador+12), mid_angles(k)+30, rho(5), segment_labels(contador+12));
        Plot_Segment(rho(4), rho(5), mid_angles(k), mid_angles(k)+60, segment_values(contador+12+1), mid_angles(k)+30, rho(4), segment_labels(contador+12+1));
        contador = contador + 2;
    end

    % --- Apical ring (segments 13–16) ---
    apical_angles = [45 135 225 315];
    contador = 1;
    for k = 1:4
        Plot_Segment(rho(3), rho(4), apical_angles(k), apical_angles(k)+90, segment_values(contador+24), apical_angles(k)+45, rho(3), segment_labels(contador+24));
        Plot_Segment(rho(2), rho(3), apical_angles(k), apical_angles(k)+90, segment_values(contador+24+1), apical_angles(k)+45, rho(2), segment_labels(contador+24+1));
        contador = contador + 2;
    end


    % --- Apex (segment 17) ---
    theta_circle = linspace(0,2*pi,100);
    fill(rho(2)*cos(theta_circle), rho(2)*sin(theta_circle), segment_values(33), 'EdgeColor', 'k', 'LineWidth', 2);
    text(0, 0, num2str(segment_labels(33)), 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 12);

end


% Function to plot AHA model with both more segments and more rings
function plotBothExtendedAHA(data)
    metric_data = data.length_r_strain;
    [numT,numR,numZ] = size(metric_data);
    region_avgs = zeros(numT,65);

    % Definir límites para 65 segmentos (64 subsegmentos + 1 apex)
    % Límites angulares (R) - Definidos en una sola línea para evitar errores de concatenación
    lbR = [60,90,120,150,180,210,240,270,300,330,0,30, 60,90,120,150,180,210,240,270,300,330,0,30, 60,90,120,150,180,210,240,270,300,330,0,30, 60,90,120,150,180,210,240,270,300,330,0,30, 45,90,135,180,225,270,315,0, 45,90,135,180,225,270,315,0, 0];
    
    ubR = [90,120,150,180,210,240,270,300,330,360,30,60, 90,120,150,180,210,240,270,300,330,360,30,60, 90,120,150,180,210,240,270,300,330,360,30,60, 90,120,150,180,210,240,270,300,330,360,30,60, 90,135,180,225,270,315,360,45, 90,135,180,225,270,315,360,45, 360];
    
    % Límites longitudinales (Z)
    lbZ = [0.85,0.85,0.85,0.85,0.85,0.85,0.85,0.85,0.85,0.85,0.85,0.85, 0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7, 0.55,0.55,0.55,0.55,0.55,0.55,0.55,0.55,0.55,0.55,0.55,0.55, 0.4,0.4,0.4,0.4,0.4,0.4,0.4,0.4,0.4,0.4,0.4,0.4, 0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25, 0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1, 0];
    
    ubZ = [1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0, 0.85,0.85,0.85,0.85,0.85,0.85,0.85,0.85,0.85,0.85,0.85,0.85, 0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7,0.7, 0.55,0.55,0.55,0.55,0.55,0.55,0.55,0.55,0.55,0.55,0.55,0.55, 0.4,0.4,0.4,0.4,0.4,0.4,0.4,0.4, 0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25, 0.1];

    % Create points for indexing
    rpts_sub = linspace(0, 360, numR+1); rpts_sub(end) = [];
    zpts_sub = (1:numZ)./numZ;

    % Calcular valores promedio para cada segmento
    for j = 1:65
        for k = 1:numT
            if lbR(j) < ubR(j)
                region_avgs(k,j) = mean(lin_array(metric_data(k,rpts_sub >= lbR(j) & rpts_sub < ubR(j),zpts_sub > lbZ(j) & zpts_sub <= ubZ(j))));
            else
                rpts_sub_boo = (rpts_sub >= lbR(j) & rpts_sub < 360) | (rpts_sub >= 0 & rpts_sub < ubR(j));
                region_avgs(k,j) = mean(lin_array(metric_data(k,rpts_sub_boo,zpts_sub > lbZ(j) & zpts_sub <= ubZ(j))));
            end
        end
    end
    
    [~, tpt_systole] = min(data.total_volumes);
    segment_values = region_avgs(tpt_systole,:);
    
    % Definir radios para los anillos
    rho = [0, 0.1, 0.25, 0.4, 0.55, 0.7, 0.85, 1];
    
    % Crear etiquetas para los segmentos (cada 4 subsegmentos comparten el mismo número, excepto el ápex)
    segment_labels = zeros(1, 65);
    
    % Asignar etiquetas para los segmentos basales (1-6)
    for i = 1:6
        % Cada segmento original se divide en 4 subsegmentos (2 angulares x 2 radiales)
        idx_start = (i-1)*4 + 1;
        segment_labels(idx_start:idx_start+3) = i;
    end
    
    % Asignar etiquetas para los segmentos medios (7-12)
    for i = 1:6
        idx_start = 24 + (i-1)*4 + 1;
        segment_labels(idx_start:idx_start+3) = i+6;
    end
    
    % Asignar etiquetas para los segmentos apicales (13-16)
    for i = 1:4
        idx_start = 48 + (i-1)*4 + 1;
        segment_labels(idx_start:idx_start+3) = i+12;
    end
    
    % Asignar etiqueta para el ápex (17)
    segment_labels(65) = 17;
    
    % --- Basal exterior angular (segmentos 1-12) ---
    % Definir ángulos para asegurar que cubran todo el círculo
    basal_angles = [60, 90, 120, 150, 180, 210, 240, 270, 300, 330, 0, 30];
    
    % Mapeo de los 12 segmentos angulares a los 6 segmentos originales
    basal_map = [1,1,2,2,3,3,4,4,5,5,6,6];
    
    for k = 1:12
        % Calcular ángulo final (asegurando que sea mayor que el inicial)
        end_angle = basal_angles(k) + 30;
        if end_angle <= basal_angles(k)
            end_angle = end_angle + 360;
        end
        
        % Segmento exterior radial
        Plot_Segment(rho(7), rho(8), basal_angles(k), end_angle, segment_values(k), basal_angles(k)+15, rho(7), basal_map(k));
        
        % Segmento interior radial
        Plot_Segment(rho(6), rho(7), basal_angles(k), end_angle, segment_values(k+12), basal_angles(k)+15, rho(6), basal_map(k));
    end
    
    % --- Mid exterior e interior (segmentos 25-48) ---
    % Definir ángulos para asegurar que cubran todo el círculo
    mid_angles = [60, 90, 120, 150, 180, 210, 240, 270, 300, 330, 0, 30];
    
    % Mapeo de los 12 segmentos angulares a los 6 segmentos originales
    mid_map = [7,7,8,8,9,9,10,10,11,11,12,12];
    
    for k = 1:12
        % Calcular ángulo final (asegurando que sea mayor que el inicial)
        end_angle = mid_angles(k) + 30;
        if end_angle <= mid_angles(k)
            end_angle = end_angle + 360;
        end
        
        % Segmento exterior radial
        Plot_Segment(rho(5), rho(6), mid_angles(k), end_angle, segment_values(k+24), mid_angles(k)+15, rho(5), mid_map(k));
        
        % Segmento interior radial
        Plot_Segment(rho(4), rho(5), mid_angles(k), end_angle, segment_values(k+36), mid_angles(k)+15, rho(4), mid_map(k));
    end
    
    % --- Apical exterior e interior (segmentos 49-64) ---
    % Definir ángulos para asegurar que cubran todo el círculo
    apical_angles = [45, 90, 135, 180, 225, 270, 315, 0];
    
    % Mapeo de los 8 segmentos angulares a los 4 segmentos originales
    apical_map = [13,13,14,14,15,15,16,16];
    
    for k = 1:8
        % Calcular ángulo final (asegurando que sea mayor que el inicial)
        end_angle = apical_angles(k) + 45;
        if end_angle <= apical_angles(k)
            end_angle = end_angle + 360;
        end
        
        % Segmento exterior radial
        Plot_Segment(rho(3), rho(4), apical_angles(k), end_angle, segment_values(k+48), apical_angles(k)+22.5, rho(3), apical_map(k));
        
        % Segmento interior radial
        Plot_Segment(rho(2), rho(3), apical_angles(k), end_angle, segment_values(k+56), apical_angles(k)+22.5, rho(2), apical_map(k));
    end
    
    % --- Apex (segmento 65) ---
    theta_circle = linspace(0,2*pi,100);
    fill(rho(2)*cos(theta_circle), rho(2)*sin(theta_circle), segment_values(65), 'EdgeColor', 'k', 'LineWidth', 2);
    text(0, 0, num2str(segment_labels(65)), 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 12);
end

% Helper function to plot one segment
function Plot_Segment(rho_inner,rho_outer,theta_start,theta_end,value,theta_label,rho_label,seg_label)
    theta = linspace(deg2rad(theta_start), deg2rad(theta_end), 30);
    [x_outer,y_outer] = pol2cart(theta, rho_outer);
    [x_inner,y_inner] = pol2cart(flip(theta), rho_inner);
    fill([x_outer x_inner], [y_outer y_inner], value, 'EdgeColor', 'k', 'LineWidth', 2);
    hold on;

    % Label center of the segment
    [x_text, y_text] = pol2cart(deg2rad(theta_label), (rho_inner + rho_outer)/2);
    text(x_text, y_text, num2str(seg_label), 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 12);
end



function out_array = lin_array(input_array)
    out_array = input_array(:);
end