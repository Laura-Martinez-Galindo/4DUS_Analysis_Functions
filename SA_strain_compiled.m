%Snippet of code that allows strain-based infarct calculation and wall
%thinning based infarct calculation to be called on the compiled results
%struct

for i = 1:length(foldernames);
    [Infarct_SA_Strain(i)] = SA_Strain_MI(results_struct_compiled(i),-20);
end


% for i = 1:length(foldernames);
%     [Infarct_WT_7(i)] = wall_thinning_MI(results_struct_compiled(i), 0.5,1);
% end
