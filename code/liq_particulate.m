
clc; clear all; close all;

%import and structure data
Folder = cd;
Folder = fullfile(Folder, '..');
warning('off', 'MATLAB:table:ModifiedAndSavedVarnames')
filename = fullfile(Folder, '/data/Table_S3.xlsx');
T = readtable(filename,'Format','auto');

T.sample_loc = categorical (T.sample_loc);
T.Author = categorical(T.Author);
L_authors = flip({'Elmoznino (2018)', 'Shivakoti (2010)', 'Vierke (2013)' ,'Yu (2009)'});
PFAS_l = {'PFHxA_liq','PFHpA_liq', 'PFOA_liq',  'PFNA_liq', 'PFDA_liq','PFBS_liq', 'PFHxS_liq', 'PFOS_liq'};
p_PFAS = {'PFHxA_SPM','PFHpA_SPM', 'PFOA_SPM',  'PFNA_SPM', 'PFDA_SPM','PFBS_SPM', 'PFHxS_SPM', 'PFOS_SPM'};
PFAS_names = {'PFHxA','PFHpA', 'PFOA',  'PFNA', 'PFDA','PFBS', 'PFHxS', 'PFOS'};
T_og = T;
T.WWTP = categorical(T.WWTP);


% T(T.sample_loc~='effluent',:)=[];
% T.Author = removecats(T.Author);
Authors= flip(categories(T.Author));
colors = parula(6); colors([6 2],:)=[];
colors = flip(colors,1);


f = figure();
f.Position = [2499 130 1052 517];
l = 0.005;
width = 0.17;
height = 0.3;
bottom = height*2;

for i = 1:8
    
    if i<6
    left = (l*i) + (width*(i-1));
    end
    if i > 5 
        bottom = (0.13);
        left = (l*(i-5)) + (width*(i-6));
    end

    axes('Position',[0.1+left bottom width height])


    %convert influent values to double and log concentrations
    if isa(T{:,PFAS_l(i)},'cell')
        data_og = table2array(T(:,PFAS_l(i)));
        T(:,PFAS_l(i)) = [];
        T(:,PFAS_l(i)) = table((cell_str_2_num(data_og)));
    end
    if isa(T{:,p_PFAS(i)},'cell')
        data_og = table2array(T(:,p_PFAS(i)));
        T(:,p_PFAS(i)) = [];
        T(:,p_PFAS(i)) = table((cell_str_2_num(data_og)));
    end
logx=linspace(-6,6,10);
x = 10.^(logx);

median_K(i) = median(T{:,p_PFAS(i)}./T{:,PFAS_l(i)},'omitnan');

n_frac1(i)=sum((T{:,p_PFAS(i)}./T{:,PFAS_l(i)})>0.1 & (T{:,p_PFAS(i)}./T{:,PFAS_l(i)}) <1);
n_frac2(i)= sum((T{:,p_PFAS(i)}./T{:,PFAS_l(i)})>0);
n_fraction(i) = n_frac1/n_frac2;
n_SPM(i)= sum((T{:,p_PFAS(i)}./T{:,PFAS_l(i)})>1);

lgnd1= loglog(x, x,'k', 'linewidth',1.5);
hold on
lgnd2= loglog(x*10, x,'k--', 'linewidth',1.5);
lgnd3= loglog(x*100,x,'k-.', 'linewidth',1.5);


for j = 1:length(Authors)
    indx_eff = find(T.Author == Authors(j)& T.sample_loc =='effluent');
    loglog(T{indx_eff, PFAS_l(i)},T{indx_eff,p_PFAS(i)}, 'o','Color',colors(j,:),'MarkerFaceColor',colors(j,:));
    indx = find(T.Author == Authors(j) & T.sample_loc ~='effluent');
    loglog(T{indx, PFAS_l(i)},T{indx,p_PFAS(i)}, '^','Color',colors(j,:));
    if i == 3 
        if ~isempty(indx_eff)
            lgnd_Authors(j) = loglog(T{indx_eff, PFAS_l(i)},T{indx_eff,p_PFAS(i)}, 'o','Color',colors(j,:),'MarkerFaceColor',colors(j,:));
        else
         lgnd_Authors(j)= loglog(T{indx, PFAS_l(i)},T{indx,p_PFAS(i)}, '^','Color',colors(j,:)); 
            
        end
    end
end

title(PFAS_names(i))
ylim([10^-3 10^3.6])
xlim([10^-3 10^3.6])
xticks([10^-2 1  10^2 ])
yticks([10^-2 1  10^2 ])
set(gca, 'fontsize', 14);

if i == 3|i==7
    xlabel(['\bfC_{liq} \rm[ng/L]'] )
end
if i == 1|i==6
    ylabel('\bfC_{SPM} \rm[ng/L]')
else
    set(gca, 'yTickLabel', [])
end
end

l= legend([lgnd_Authors lgnd1 lgnd2 lgnd3 ],[L_authors, 'C_{SPM} = C_{liq}', 'C_{SPM} = C_{liq}\times0.1 ', 'C_{SPM} = C_{liq}\times0.01']);
l.Position = [0.6542 0.1812 0.1231 0.2157];


groupsummary(T, ["Author","WWTP"]);

Folder = cd;
Folder = fullfile(Folder, '..');
saveas(gcf,fullfile(Folder, '/figures and results/liq-spm.png'));