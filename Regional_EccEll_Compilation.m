%Main purpose is to generate an excel spreadsheet with selected metrics for
%all folders in a SAX_compiled MATLAB struct

function [metric_comp] = Regional_EccEll_Compilation(SAX_compiled,foldernames,excelname)

num_metrics = 11;

metric_comp    = cell(numel(SAX_compiled),num_metrics, 5);

for i = 1:numel(SAX_compiled)
    
    volume = SAX_compiled(i).total_volumes(:);
    [max_vol,max_vol_idx] = max(volume);
    min_vol               = min(volume);
    myo_mg                = SAX_compiled(i).myo_vol(1)*1.05;
    myo_thk               = mean(SAX_compiled(i).length_r(1,:,:),'all');
    metric_comp{i,1,1} = max_vol/1000;
    metric_comp{i,2,1} = min_vol/1000;
    metric_comp{i,3,1} = (max_vol - min_vol)/1000;
    metric_comp{i,4,1} = ((max_vol - min_vol) ./ max_vol) * 100;
    metric_comp{i,5,1} = myo_mg/1000;
    metric_comp{i,6,1} = myo_thk;



%  region averages for 4 sections from base to apex:
%   1) Base    (70% < z <= 100%) (-6:6)+10
%   2) Mid-LV  (40% < z <= 70%)  (-6:6)+30
%   3) Apical  (10% < z <= 40%)  (-6:6)+50
%   4) Apex    ( 0% < z <= 10%)  
    
%  region averages for six rotations around the LV for LAX_length_strain:
%   1) Anterior          (60  <= r < 120) (-4:4)+6)
%   2) Anterior-Septum   (120 <= r < 180) (-4:4)+16)
%   3) Posterior-Septum  (180 <= r < 240) (-4:4)+26)
%   4) Inferior          (240 <= r < 300) (-4:4)+36)
%   5) Posterior-Lateral (300 <= r < 360) (-4:4)+46)
%   6) Anterior-Lateral  (0   <= r < 60 ) (-4:4)+56)

    mIdx = 1;
    for m = 1:11              
        switch m
            
            case 1,  metric = mean(SAX_compiled(i).GLcyclic_strain(:,(-6:6)+10),2);      
            case 2,  metric = mean(SAX_compiled(i).GLcyclic_strain(:,(-6:6)+30),2);    
            case 3,  metric = mean(SAX_compiled(i).GLcyclic_strain(:,(-6:6)+50),2); 
            case 4,  metric = mean(SAX_compiled(i).GLcyclic_strain(:,1:60),2);
            
            case 5,  metric = mean(SAX_compiled(i).LAX_length_strain(:,(-4:4)+6),2); 
            case 6,  metric = mean(SAX_compiled(i).LAX_length_strain(:,(-4:4)+16),2);              
            case 7,  metric = mean(SAX_compiled(i).LAX_length_strain(:,(-4:4)+26),2);                
            case 8,  metric = mean(SAX_compiled(i).LAX_length_strain(:,(-4:4)+36),2);
            case 9,  metric = mean(SAX_compiled(i).LAX_length_strain(:,(-4:4)+46),2);  
            case 10, metric = mean(SAX_compiled(i).LAX_length_strain(:,(-4:4)+56),2);
            case 11, metric = mean(SAX_compiled(i).LAX_length_strain(:,1:60),2);            
        end

        metric = circshift(metric,-1*(max_vol_idx-1));
        [max_val,max_idx] = max(metric);
        [min_val,min_idx] = min(metric);
        metric_comp{i,mIdx,2}      = min_val;      
        buffer = (max_val - min_val)*0.12;
        
        % Perform Slope Analysis on Absolute Data
        
        % These following if/else statement accounts for flipping of curves
        if max_val<abs(min_val)
		    X_prev(1) = find(metric < (max_val - buffer),1,'first');
		    X_prev(3) = find(metric > (min_val + buffer) & transpose(1:60) < min_idx,1,'last');
		    X_prev(2) = X_prev(1) + (X_prev(3)-X_prev(1))*0.6;
		    X_prev(4) = find(metric > (min_val + buffer) & transpose(1:60) > min_idx,1,'first');
		    X_prev(6) = find(metric < (max_val - buffer),1,'last');
		    X_prev(5) = X_prev(4) + (X_prev(6)-X_prev(4))*0.4;
		    X = X_prev;
        else
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
        [sys_b,~] = polyfit(sys_rng,metric(sys_rng),1);
        metric_comp{i,mIdx,3}      = sys_b(1); %mIdx = mIdx + 1;

        % Calculate Early Diastolic Metric Trend
        dia1_rng = (ceil(X(4)):floor(X(5)));
        [dia1_b,~] = polyfit(dia1_rng,metric(dia1_rng),1);
        metric_comp{i,mIdx,4}      = dia1_b(1); %mIdx = mIdx + 1;

        % Calculate Late Diastolic Metric Trend
        dia2_rng = (ceil(X(5))+1:floor(X(6)));
        [dia2_b,~] = polyfit(dia2_rng,metric(dia2_rng),1);
        metric_comp{i,mIdx,5}      = dia2_b(1); %mIdx = mIdx + 1;

        mIdx = mIdx + 1; 
    end
end


tabNames_1 = {'EDV','PSV','SV','EF','LVM','LV_Thickness',"","","","",""};
tabNames_2 = {'Ecc_BP','Ecc_MP','Ecc_AP','Ecc_GP','Ell_AFWP','Ell_AP','Ell_ASP','Ell_PSP','Ell_PP','Ell_PFWP','Ell_GP'};    
tabNames_3 = {'Ecc_BS','Ecc_MS','Ecc_AS','Ecc_GS','Ell_AFWS','Ell_AS','Ell_ASS','Ell_PSS','Ell_PS','Ell_PFWS','Ell_GS'};  
tabNames_4 = {'Ecc_BD1','Ecc_MD1','Ecc_AD1','Ecc_GD1','Ell_AFWD1','Ell_AD1','Ell_ASD1','Ell_PSD1','Ell_PD1','Ell_PFWD1','Ell_GD1'};
tabNames_5 = {'Ecc_BD2','Ecc_MD2','Ecc_AD2','Ecc_GD2','Ell_AFWD2','Ell_AD2','Ell_ASD2','Ell_PSD2','Ell_PD2','Ell_PFWD2','Ell_GD2'};  

tabNames = [tabNames_1;tabNames_2;tabNames_3;tabNames_4;tabNames_5];

sheetNames = {'Function','Peak_Strain','Systolic_SR','Early_Diastolic_SR','Late_Diastolic_SR'};

for k = 1:5
    writecell(metric_comp(:,:,k),excelname, 'Sheet',sheetNames{k}, 'Range','B2' );
    writecell(tabNames(k,:), excelname, 'Sheet',sheetNames{k},'Range','B1');
    writecell(foldernames', excelname,'Sheet',sheetNames{k},'Range','A2');
end

end


        
        
