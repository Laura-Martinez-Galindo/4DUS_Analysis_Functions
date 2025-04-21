
function [metric_comp] = AHA_Regional_Err_Compilation(SAX_compiled,foldernames,excelname)

%[metric_comp] = metric_extraction_AHA(SAX_compiled,'SAX_ctrl_SR_v1.xlsx');

num_metrics = 4;
num_sheets = 4;
metric_comp = cell(numel(SAX_compiled),num_metrics, num_sheets);

for i = 1:numel(SAX_compiled)
    
    %metric_data = SAX_compiled(i).surfarea_strain;
    
%   metric_data = SAX_compiled(i).length_r_strain;
    metric_data = SAX_compiled(i).radius_strain;

    % function [region_avgs,region_stdevs,region_sum] = extract_3D(metric_data)
    % Create region averages following AHA 17-Segment model:
    %     1-6) Base    (70% < z <= 100%)
    %    7-12) Mid-LV  (40% < z <= 70%)
    %   13-16) Apical  (10% < z <= 40%)
    %      17) Apex    ( 0% < z <= 10%)

    [numT,numR,numZ] = size(metric_data);
    region_avgs   = zeros(numT,17);
    lbR = [60,120,180,240,300,0  ,  60,120,180,240,300,0  ,  45,135,225,315, 0  ];
    ubR = [120,180,240,300,360,60 , 120,180,240,300,360,60 , 135,225,315,45 , 360];
    lbZ = [0.0,0.0,0.0,0.0,0.0,0.0, 0.3,0.3,0.3,0.3,0.3,0.3, 0.6,0.6,0.6,0.6, 0.9];
    ubZ = [0.3,0.3,0.3,0.3,0.3,0.3, 0.6,0.6,0.6,0.6,0.6,0.6, 0.9,0.9,0.9,0.9, 1.0];  
    rpts_sub = linspace(0,360,numR+1); rpts_sub(end) = [];
    zpts_sub = (1:numZ)./numZ;
    
    for j = 1:17
        for k = 1:numT
            if lbR(j) < ubR(j)
                region_avgs(k,j)   = mean(lin_array(metric_data(k,rpts_sub >= lbR(j) & rpts_sub < ubR(j),zpts_sub > lbZ(j) & zpts_sub <= ubZ(j))));
            else
                rpts_sub_boo = (rpts_sub >= lbR(j) & rpts_sub < 360) | (rpts_sub >= 0 & rpts_sub < ubR(j));
                region_avgs(k,j)   = mean(lin_array(metric_data(k,rpts_sub_boo,zpts_sub > lbZ(j) & zpts_sub <= ubZ(j))));
            end
        end
    end


    %returns timepoint index for end Diastole
    [dias,tpt1] = max(SAX_compiled(i).total_volumes);

    %returns timepoint index for peak systole
    [sys,tpt2]= min(SAX_compiled(i).total_volumes);

    % SA_Strain = SAX_analysis.AHA_SA_strain(tpt2,:);
    PeakSystolic_SA_Strain = region_avgs(tpt2,:);

    base_avg = mean(PeakSystolic_SA_Strain(1:6));
    midlv_avg = mean(PeakSystolic_SA_Strain(7:12));
    apical_avg = mean(PeakSystolic_SA_Strain(13:16));
    global_avg = mean(PeakSystolic_SA_Strain(1:16));
    
    metric_comp{i,1,1} = base_avg;
    metric_comp{i,2,1} = midlv_avg;
    metric_comp{i,3,1} = apical_avg;
    metric_comp{i,4,1} = global_avg;
    
    metric_comp{i,6,1} = PeakSystolic_SA_Strain;

    
    for m = 1:17
        metric = region_avgs(:,m);
    
        % identify peak systole and end-diastole
        volume = SAX_compiled(i).total_volumes(:);
        [~,max_vol_idx] = max(volume); %end diastole
        metric = circshift(metric,-1*(max_vol_idx-1));
        
        [max_val,max_idx] = max(metric);
        [min_val,min_idx] = min(metric);
    
        % Perform Slope Analysis on Absolute Data
	      
	    buffer = (max_val - min_val)*0.12;
	    X_prev = [];
    
        if max_val<abs(min_val) % negative strain value    
	        X_prev(1) = find(metric < (max_val - buffer),1,'first');
	        X_prev(3) = find(metric > (min_val + buffer) & transpose(1:60) < min_idx,1,'last');
	        X_prev(2) = X_prev(1) + (X_prev(3)-X_prev(1))*0.6;
	        X_prev(4) = find(metric > (min_val + buffer) & transpose(1:60) > min_idx,1,'first');
	        X_prev(6) = find(metric < (max_val - buffer),1,'last');
	        X_prev(5) = X_prev(4) + (X_prev(6)-X_prev(4))*0.4;
	        X = X_prev;
        else %positive strain value
            X_prev(1) = find(metric > (min_val + buffer),1,'first');
            X_prev(3) = find(metric < (max_val - buffer) & transpose(1:60) < max_idx,1,'last');
            X_prev(2) = X_prev(1) + (X_prev(3)-X_prev(1))*0.6;
            X_prev(4) = find(metric < (max_val - buffer) & transpose(1:60) > max_idx,1,'first');
            X_prev(6) = find(metric > (min_val + buffer),1,'last');
            X_prev(5) = X_prev(4) + (X_prev(6)-X_prev(4))*0.4;
            X = X_prev;	
        end
																       
    
        % Calculate Systolic Metric Trend
        sys_rng = (ceil(X(1)):floor(X(3)));
        sys_b = polyfit(squeeze(sys_rng),metric(sys_rng)',1);
        
        % Calculate Early Diastolic Metric Trend
        dia1_rng = (ceil(X(4)):floor(X(5)));
        dia1_b = polyfit(squeeze(dia1_rng),metric(dia1_rng)',1);
        
        % Calculate Late Diastolic Metric Trend
        dia2_rng = (ceil(X(5))+1:floor(X(6)));
        dia2_b = polyfit(squeeze(dia2_rng),metric(dia2_rng)',1);
        
        metric_comp{i,m+5,2} = sys_b(1);
        metric_comp{i,m+5,3} = dia1_b(1);
        metric_comp{i,m+5,4} = dia2_b(1);

    end
    
    for n = 2:4
        base_avg = mean(cell2mat(metric_comp(i,5+1:5+6,n)));
        midlv_avg = mean(cell2mat(metric_comp(i,5+7:5+12,n)));
        apical_avg = mean(cell2mat(metric_comp(i,5+13:5+16,n)));
        global_avg = mean(cell2mat(metric_comp(i,5+1:5+16,n)));

        metric_comp{i,1,n} = base_avg;
        metric_comp{i,2,n} = midlv_avg;
        metric_comp{i,3,n} = apical_avg;
        metric_comp{i,4,n} = global_avg;

    end

    tabNames_1 = {'Basal_peak','Midlv_peak','Apical_peak','Global_peak','','seg1','seg2','seg3','seg4','seg5','seg6','seg7','seg8','seg9','seg10','seg11','seg12','seg13','seg14','seg15','seg16','seg17'};
    tabNames_2 = {'Basal_SR','Mid_SR','Apical_SR','Global_SR','','seg1','seg2','seg3','seg4','seg5','seg6','seg7','seg8','seg9','seg10','seg11','seg12','seg13','seg14','seg15','seg16','seg17'};
    tabNames_3 = {'Basal_SR','Mid_SR','Apical_SR','Global_SR','','seg1','seg2','seg3','seg4','seg5','seg6','seg7','seg8','seg9','seg10','seg11','seg12','seg13','seg14','seg15','seg16','seg17'};
    tabNames_4 = {'Basal_SR','Mid_SR','Apical_SR','Global_SR','','seg1','seg2','seg3','seg4','seg5','seg6','seg7','seg8','seg9','seg10','seg11','seg12','seg13','seg14','seg15','seg16','seg17'};

    tabNames = [tabNames_1;tabNames_2;tabNames_3;tabNames_4];

    sheetNames = {'Peak','Systolic_SR','Early_Diastolic_SR','Late_Diastolic_SR'};

    for k = 1:4
        writecell(metric_comp(:,:,k),excelname, 'Sheet',sheetNames{k}, 'Range','B2' );
        writecell(tabNames(k,:), excelname, 'Sheet',sheetNames{k},'Range','B1');
        writecell(foldernames', excelname,'Sheet',sheetNames{k},'Range','A2');
    end

end