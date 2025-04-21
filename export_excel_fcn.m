%For a single file, you can load in the results and specify a filename. The
%excel file will be exported into the current directory

function export_excel_fcn(results_all, file)

T = readcell([pwd,filesep,'metric_output_template.xlsx'],'Range','A4:G56');
for i = 1:numel(T)
    if ismissing(T{i})
        T{i} = [];
    end
end

max_vol = max(results_all.total_volumes(:));
min_vol = min(results_all.total_volumes(:));
T{1,3}  = max_vol;
T{2,3}  = min_vol;
T{3,3}  = (max_vol - min_vol);
T{4,3}  = (max_vol - min_vol)/max_vol*100;
T{5,3}  = results_all.myo_vol(1)*1.05;
     
excel_rows = [8:10,12:17,19:35,37:53];
for m = 1:43
    volume = results_all.total_volumes(:);
    [~,max_vol_idx] = max(volume);
    
    switch m
        case 1
            metric = mean(results_all.GLcyclic_strain(:,(-6:6)+10),2);
        case 2
            metric = mean(results_all.GLcyclic_strain(:,(-6:6)+30),2);
        case 3
            metric = mean(results_all.GLcyclic_strain(:,(-6:6)+50),2);
        case 4
            metric = mean(results_all.LAX_length_strain(:,(-4:4)+6),2);
        case 5
            metric = mean(results_all.LAX_length_strain(:,(-4:4)+16),2);
        case 6
            metric = mean(results_all.LAX_length_strain(:,(-4:4)+26),2);
        case 7
            metric = mean(results_all.LAX_length_strain(:,(-4:4)+36),2);
        case 8
            metric = mean(results_all.LAX_length_strain(:,(-4:4)+46),2);
        case 9
            metric = mean(results_all.LAX_length_strain(:,(-4:4)+56),2);
		otherwise
            if m > 9 && m <= 26
                metric = results_all.AHA_SA_strain(:,m-9);
            else
                metric = results_all.AHA_length_r_strain(:,m-26);
            end		 
    end
    metric = circshift(metric,-1*(max_vol_idx-1));
    [max_val,max_idx] = max(metric);
    [min_val,min_idx] = min(metric);
    T{excel_rows(m),3} = min_val;
    T{excel_rows(m),4} = (min_idx/60)*100;
    
    % Perform Slope Analysis on Absolute Data
	if m <= 26
        T{excel_rows(m),3} = min_val;
        T{excel_rows(m),4} = (min_idx/60)*100;		  
		buffer = (max_val - min_val)*0.12;
		X_prev = [];

        %These next if statements account for flipping of curves
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
            T{excel_rows(m),3} = max_val;
        end


	else				   
		T{excel_rows(m),3} = max_val;
        T{excel_rows(m),4} = (max_idx/60)*100;
        buffer = (max_val - min_val)*0.12;
        X_prev = [];
        
        %CE Add in conditional statement here to account for transmural
        %strain curves being both positive and negative
        %variability
        if max_val>abs(min_val)
            X_prev(1) = find(metric > (min_val + buffer),1,'first');
            X_prev(3) = find(metric < (max_val - buffer) & transpose(1:60) < max_idx,1,'last');
            X_prev(2) = X_prev(1) + (X_prev(3)-X_prev(1))*0.6;
            X_prev(4) = find(metric < (max_val - buffer) & transpose(1:60) > max_idx,1,'first');
            X_prev(6) = find(metric > (min_val + buffer),1,'last');
            X_prev(5) = X_prev(4) + (X_prev(6)-X_prev(4))*0.4;
            X = X_prev;	
        else
            X_prev(1) = find(metric < (max_val - buffer),1,'first');
            X_prev(3) = find(metric > (min_val + buffer) & transpose(1:60) < min_idx,1,'last');
            X_prev(2) = X_prev(1) + (X_prev(3)-X_prev(1))*0.6;
            X_prev(4) = find(metric > (min_val + buffer) & transpose(1:60) > min_idx,1,'first');
            X_prev(6) = find(metric < (max_val - buffer),1,'last');
            X_prev(5) = X_prev(4) + (X_prev(6)-X_prev(4))*0.4;
            X = X_prev;
            T{excel_rows(m),3} = min_val;
        end
            
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
    
    T{excel_rows(m),5} = sys_b(1);
    T{excel_rows(m),6} = dia1_b(1);
    T{excel_rows(m),7} = dia2_b(1);
end
T{1,6} = datestr(clock);
writecell(T,[pwd,filesep,file,'.xlsx'],'Range','A4:G56');
