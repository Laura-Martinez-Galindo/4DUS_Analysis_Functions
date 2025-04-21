% difference maps 

% Ecc
%Timepoints minus J0
%create the averages and use them below Ex:  concat_matrix=cat(3,SAX_analysis.GLcyclic_strain); avgEcc_j0=mean(concat_matrix,3);
avgEcc_3wtac_diff=avgEcc_3wtac-avgEcc_j0; %3W TAC - J0
avgEcc_1wdetac_diff=avgEcc_1wdetac-avgEcc_j0; %1W deTAC - J0
avgEcc_4wdetac_diff=avgEcc_1wdetac-avgEcc_j0; %4W deTAC - J0

avgEcc_diff= cat(3, avgEcc_3wtac_diff,avgEcc_1wdetac_diff, avgEcc_4wdetac_diff);
maxEcc=max(avgEcc_diff, [], 'all') %use these values to update labels on plots
minEcc=min(avgEcc_diff, [], 'all')

% Ell
avgEll_3wtac_diff=avgEll_3wtac-avgEll_j0; %3W TAC - J0
avgEll_1wdetac_diff=avgEll_1wdetac-avgEll_j0; %1W deTAC - J0
avgEll_4wdetac_diff=avgEll_1wdetac-avgEll_j0; %4W deTAC - J0

avgEll_diff= cat(3, avgEll_3wtac_diff,avgEll_1wdetac_diff, avgEll_4wdetac_diff);
maxEll=max(avgEll_diff, [], 'all') %use these values to update labels on plots
minEll=min(avgEll_diff, [], 'all')

%% plot individually
figure; imagesc(avgEcc_3wtac_diff');   axis image ; axis off ; caxis([-5 16]); 
    c = colorbar; c.Location = 'Eastoutside'; c.FontSize = 24; c.Ticks = [-5 0 16];
    c.TickLabels = {'-5%','0%','16%'}; c.FontName = 'Arial';
    colormap(flipud(gray));
   
    yline(40, 'k--', 'LineWidth', 4);
    yline(20, 'k--', 'LineWidth', 4)

% 1W deTAC - J0
    figure; imagesc(avgEcc_1wdetac_diff');   axis image ; axis off ; caxis([-5 16]); 
    c = colorbar; c.Location = 'Eastoutside'; c.FontSize = 24; c.Ticks = [-5 0 16];
    c.TickLabels = {'-5%','0%','16%'}; c.FontName = 'Arial';
    colormap(flipud(gray));
   
    yline(40, 'k--', 'LineWidth', 4);
    yline(20, 'k--', 'LineWidth', 4)

% 4W deTAC - J0
    figure; imagesc(avgEcc_4wdetac_diff');   axis image ; axis off ; caxis([-5 16]); 
    c = colorbar; c.Location = 'Eastoutside'; c.FontSize = 24; c.Ticks = [-5 0 16];
    c.TickLabels = {'-5%','0%','16%'}; c.FontName = 'Arial';
    colormap(flipud(gray));
   
    yline(40, 'k--', 'LineWidth', 4);
    yline(20, 'k--', 'LineWidth', 4)

%% if want tiled together 
figure
tiledlayout(1,3, 'TileSpacing','compact') 
nexttile; imagesc(avgEcc_3wtac_diff');  axis image ; axis off ; caxis([-5 16]);   yline(40, 'k--', 'LineWidth', 4); yline(20, 'k--', 'LineWidth', 4);
nexttile; imagesc(avgEcc_1wdetac_diff'); axis image ; axis off ; caxis([-5 16]);  yline(40, 'k--', 'LineWidth', 4); yline(20, 'k--', 'LineWidth', 4);
nexttile; imagesc(avgEcc_4wdetac_diff'); axis image ; axis off ; caxis([-5 16]);  yline(40, 'k--', 'LineWidth', 4); yline(20, 'k--', 'LineWidth', 4);

c = colorbar; c.Location = 'Eastoutside'; c.FontSize = 24; c.Ticks = [-5 0 5 10 16];
c.TickLabels = {'-5%','0%','5%','10%','16%'}; c.FontName = 'Arial';
colormap(flipud(pink));

figure
tiledlayout(1,3, 'TileSpacing','compact') 
nexttile; imagesc(avgEll_3wtac_diff');  axis image ; axis off ; caxis([-2 12]);  ...
    yline(12, 'k--', 'LineWidth', 4); yline(24, 'k--', 'LineWidth', 4); yline(36, 'k--', 'LineWidth', 4); yline(48, 'k--', 'LineWidth', 4);
nexttile; imagesc(avgEll_1wdetac_diff'); axis image ; axis off ; caxis([-2 12]);  ...
    yline(12, 'k--', 'LineWidth', 4); yline(24, 'k--', 'LineWidth', 4); yline(36, 'k--', 'LineWidth', 4); yline(48, 'k--', 'LineWidth', 4);
nexttile; imagesc(avgEll_4wdetac_diff'); axis image ; axis off ; caxis([-2 12]);  ...
    yline(12, 'k--', 'LineWidth', 4); yline(24, 'k--', 'LineWidth', 4); yline(36, 'k--', 'LineWidth', 4); yline(48, 'k--', 'LineWidth', 4);

c = colorbar; c.Location = 'Eastoutside'; c.FontSize = 24; c.Ticks = [-2 0 4 8 12];
c.TickLabels = {'-2%','0%','4%','8%','12%'}; c.FontName = 'Arial';
colormap(flipud(pink));

