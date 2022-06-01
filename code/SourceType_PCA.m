

clc; clear all; close all;
rng('default')

% import and structure data
Folder = cd;
Folder = fullfile(Folder, '..');
warning('off', 'MATLAB:table:ModifiedAndSavedVarnames')
filename = fullfile(Folder, '/data/Table_S2.xlsx');
data = readtable(filename,'Format','auto');
data.SourceType = categorical(data.SourceType);
data.SourceType2 = categorical(data.SourceType2);

PFAS_names = {'PFHxA','PFHpA', 'PFOA',  'PFNA', 'PFDA','PFBS', 'PFHxS', 'PFOS'};
PFAS_inf = {'PFHxA_inf','PFHpA_inf', 'PFOA_inf',  'PFNA_inf', 'PFDA_inf','PFBS_inf', 'PFHxS_inf', 'PFOS_inf'};
PFAS_eff = {'PFHxA_eff','PFHpA_eff', 'PFOA_eff',  'PFNA_eff', 'PFDA_eff','PFBS_eff', 'PFHxS_eff', 'PFOS_eff'};


for i = 1:8
    %convert influent values to double and log concentrations, remove ND
    data_og = data{:,PFAS_inf(i)};
    data(:,PFAS_inf(i)) = [];
    data{:,PFAS_inf(i)} = log10(cell_str_2_num(data_og));

    %convert effluent values to double and log concentrations, remove ND
    data_og = table2array(data(:,PFAS_eff(i)));
    data(:,PFAS_eff(i)) = [];
    data{:,PFAS_eff(i)} = log10(cell_str_2_num(data_og));

end

% remove data with no effluent observations
data(find(all(isnan(data{:,PFAS_eff}),2)),:) = [];
pca_data = data{:,PFAS_eff};

% Order source categories
data.SourceType = reordercats(data.SourceType, {'Domestic', 'Mixed', ...
    'Unspecified', 'High Ind.'});
data.SourceType2 = reordercats(data.SourceType2, {'Domestic (Ind. < 5%)', 'Domestic (N/A)', 'Mixed (Ind. < 35%)',...
    'Mixed (N/A)' ,'Unspecified', 'High Ind. (Ind. > 35%)', 'High Ind. (N/A)'});

data.Month = month(datetime(data.Month, 'InputFormat','MMMM'));
data.Month(isnan(data.Month)) = 6;
data.Year = data.Year + (data.Month-1)/12 + 15/365;

var_label= PFAS_names;
n_v = length(var_label)*3;

%% Correlation 
[rho,pval]= corr(data{:,PFAS_eff},'rows','complete'); %,'Type','Spearman' );
rho_H = heatmap(rho); 
rho_H.YDisplayLabels = PFAS_names;
rho_H.XDisplayLabels =PFAS_names;
title('Correlations between PFAS in Effluent Data')
set(gcf,'color','w');


%% Perform PCA

b = 2;  % number of pc

% calculate z-scores

pca_data = pca_data  - nanmean(pca_data,1);
pca_data = pca_data ./ nanstd(pca_data,1);

% perform PCA
[coeff,score,pcvar,mu,v] = ppca(pca_data,b);


%% Plotting

% source
f_source = figure();
f_source.Position = [1711 -116 745 634];
left = 0.18;
bottom = 0.45;
width = 0.7;
height = 0.5;
axes('Position',[0.1+left bottom width height])
h2 = biplot(coeff(:,1:b),'Scores',score(:,1:b),'VarLabels',var_label);
g = data.SourceType; g= fillmissing(g,'constant','Unspecified');
groups = categories(removecats(g));
n_groups = length(groups);
n = countcats(data.SourceType2);

colors = parula(5);
colors = flipud(colors([1 3 4 5],:));
colors(end,1) = 0.4;
colors(1,:) = [0.97       0.88       0];
colors(2,:) = [0.7     0.80      0.1585];
colors(4,:) = colors(4,:)+0.1;

colors2 = [0.97         0.88            0;
         0.97         0.88            0;
          0.7          0.8       0.1585;
          0.7          0.8       0.1585;
       0.0704       0.7457       0.7258;
          0.5       0.2504       0.7603;
          0.5       0.2504       0.7603];

for i = 1:n_groups
    indx = find(g == groups(i));
    
    for j = 1:length(indx)
        if ismissing(data.IndustrialContribution(indx(j)))
            h2(indx(j)+n_v).Marker = 'o';
            h2_g(i) = h2(indx(j)+n_v);
         
        else
            h2(indx(j)+n_v).Marker = 'o';
            h2(indx(j)+n_v).MarkerFaceColor = colors(i,:);
        end
        h2(indx(j)+n_v).MarkerEdgeColor = colors(i,:);
        h2(indx(j)+n_v).MarkerSize = 5;
        
    end
end

for i =0:7
    h2(17+i).FontSize = 14;
end

xlim([-0.52 0.52])
format short g
set(gca, 'FontSize', 16)
set(gca,'XTickLabel',[])
xlabel([])
ylabel("PC 2, total variance = "+ round(pcvar(2),2, 'significant'), 'FontSize',16)
l=legend(h2_g,groups);
l.Position = [0.18792 0.75473 0.13893 0.11909];
set(gcf,'color','w')
set(gca,'color',[0.93 0.93 0.93])
box on;
title('PFAS Biplot and Source Type', 'FontSize', 14)


axes('Position',[0.1+left 0.08 width 0.34])
source_cat = categories(data.SourceType);
TS = table(score(:,1), data.SourceType2);
bc = boxchart(TS.Var2, TS.Var1/var(score(:,1))/3.3444, 'GroupByColor', TS.Var2, 'BoxWidth', 2.8, 'BoxFaceAlpha',0.4); 

bc(1).Orientation = "horizontal";
bc(1).BoxFaceAlpha = 0.4;
colororder(colors2)

bc(1).MarkerStyle = '.'; bc(1).MarkerSize = 15; 
bc(2).MarkerStyle = 'o';
bc(3).MarkerStyle = '.'; bc(3).MarkerSize = 15; 
bc(4).MarkerStyle = 'o';
bc(5).MarkerStyle = 'o';
bc(6).MarkerStyle = '.'; bc(6).MarkerSize = 15; 
bc(7).MarkerStyle = 'o';

xlim([-0.52 0.52])
xlabel("PC 1, total variance = "+ round(pcvar(1),2, 'significant'), 'FontSize',16)
ylabels_formatted = (string(categories(data.SourceType2)) + newline+  ", n=" + n); 
yticklabels(string(categories(data.SourceType2)) + ", n=" + n)
ax= gca;
ax.FontSize = 15;
box on;
set(gca,'color',[0.95 0.95 0.95])

Folder = cd;
Folder = fullfile(Folder, '..');
saveas(gcf,fullfile(Folder, '/figures and results/SourceType.png'));
