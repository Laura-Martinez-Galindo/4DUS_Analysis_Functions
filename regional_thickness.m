

%(60x60x60) variable (time, rdata, zdata)

%Apex is ~10, Mid ~30, Base ~50

%returns timepoint index for peak systole
[~,tpt_sys]= min(results_struct.total_volumes);

%returns timepoint index for end diastole
[~,tpt_dias]= max(results_struct.total_volumes);

apex_avg = mean(squeeze(mean(results_struct.length_r(tpt_sys,:,(-6:6)+50),2)));
midlv_avg = mean(squeeze(mean(results_struct.length_r(tpt_sys,:,(-6:6)+30),2)));
baselv_avg = mean(squeeze(mean(results_struct.length_r(tpt_sys,:,(-6:6)+10),2)));

total_avg = mean(squeeze(mean(results_struct.length_r(tpt_sys,:,:),2)));

%apex_avg = squeeze(mean(results_struct.length_r(30,:,4:16),2));