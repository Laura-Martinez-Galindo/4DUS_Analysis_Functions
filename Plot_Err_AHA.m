function Plot_AHA17_Strain(results_struct)

% Find peak systole timepoint
[~, tpt2] = min(results_struct.total_volumes);

% Retrieve the segmental AHA strain values at peak systole
results_struct.AHA_length_r_strain(tpt2, :)
segment_values = results_struct.AHA_length_r_strain(tpt2, :);


% Plotting AHA 17-segment Bullseye Plot
rho = [0, 0.2, 0.4, 0.7, 1]; % Radii boundaries for segments
colormap(flipud(lbmap(256,'BrownBlue')));

segment_labels = 1:17;
%Plot_Segment(rho_inner, rho_outer, theta_start, theta_end, value, theta_label, rho_label, seg_label)

% --- Basal (segments 1–6) ---
basal_angles = [60 120 180 240 300 360];
%va de angulo a angulo + 60 porque al ser 6 rebanadas, cada una mide 60, coger el valor de AHA en el array de structs, centrar etiqueta en +30
for k = 1:6
    Plot_Segment(rho(4), rho(5), basal_angles(k), basal_angles(k)+60, segment_values(k), basal_angles(k)+30, rho(4), segment_labels(k));
end

% --- Mid (segments 7–12) ---
mid_angles = [60 120 180 240 300 360];
for k = 1:6
    Plot_Segment(rho(3), rho(4), mid_angles(k), mid_angles(k)+60, segment_values(k+6), mid_angles(k)+30, rho(3), segment_labels(k+6));
end

% --- Apical ring (segments 13–16) ---
apical_angles = [45 135 225 315];
for k = 1:4
    Plot_Segment(rho(2), rho(3), apical_angles(k), apical_angles(k)+90, segment_values(k+12), apical_angles(k)+45, rho(2), segment_labels(k+12));
end

% --- Apex (segment 17) ---
theta_circle = linspace(0,2*pi,100);
fill(rho(2)*cos(theta_circle), rho(2)*sin(theta_circle), segment_values(17), 'EdgeColor', 'k', 'LineWidth', 2);
text(0, 0, num2str(segment_labels(17)), 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 12);

% Regional Labels (LAD, RCA, LCX) - más alejados para evitar solapamiento
text(-0.8, 0.8, 'LAD', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 13);
text(-0.8, -0.8, 'RCA', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 13);
text(1, 0.6, 'LCX', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 13);

axis equal off;
caxis([0,40]); %#ok<CAXIS> % Adjust caxis if needed
cb = colorbar('SouthOutside','FontSize',12);
xlabel(cb, 'Strain (%)', 'FontWeight', 'bold');
%title('AHA 17-segment Radial Strain at Peak Systole','FontWeight','bold','FontSize',14);

% --- Nested helper function to plot one segment ---
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

end
