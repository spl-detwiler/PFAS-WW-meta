% Global patterns and Temporal Trends of PFAS in Wastewater:  
% A Meta-analysis 
%
%~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

clc; clear all; close all; 

%% Preprocess data 
%import and structure data
Folder = cd;
Folder = fullfile(Folder, '..');
warning('off', 'MATLAB:table:ModifiedAndSavedVarnames')
filename = fullfile(Folder, '/data/Table_S1.xlsx');
data = readtable(filename,'Format','auto');

data.SourceType = categorical(data.SourceType);
data.SourceType2 = categorical(data.SourceType2);

% remove 'High Ind.'data 
ind_indx = data.SourceType == 'High Ind.';
data(ind_indx,:)=[];
% remove 'Mixed' data with unspecified industrial contribution
ind_indx = data.SourceType2 == 'Mixed (unknown)';
data(ind_indx,:)=[];
% remove data with unknown sample year
data(isnan(data.Year),:)=[];

data.Author = categorical(data.Author);
data.Continent = categorical(data.Continent);
data.Country = categorical(data.Country);
% countries = categories(data.Country);

PFAS_names = {'PFHxA','PFHpA', 'PFOA',  'PFNA', 'PFDA','PFBS', 'PFHxS', 'PFOS'};
PFAS_inf = {'PFHxA_inf','PFHpA_inf', 'PFOA_inf',  'PFNA_inf', 'PFDA_inf','PFBS_inf', 'PFHxS_inf', 'PFOS_inf'};
PFAS_eff = {'PFHxA_eff','PFHpA_eff', 'PFOA_eff',  'PFNA_eff', 'PFDA_eff','PFBS_eff', 'PFHxS_eff', 'PFOS_eff'};

% convert concentrations to log concentrations (set ND=0.5*LOD)
for i = 1:8
    data_og = data{:,PFAS_inf(i)};
    data(:,PFAS_inf(i)) = [];
    data{:,PFAS_inf(i)} = log10(cell_str_2_num(data_og));

    data_og = data{:,PFAS_eff(i)};
    data(:,PFAS_eff(i)) = [];
    data{:,PFAS_eff(i)} = log10(cell_str_2_num(data_og));
end

% define sample date by month and year
data.Month = month(datetime(data.Month, 'InputFormat','MMMM'));
data.Month(isnan(data.Month)) = 6;
data.Year = data.Year + (data.Month-1)/12 + 15/365;
%mean_yr_all = nanmean(data.Year);
mean_yr_all = 2012;
data.CenteredYear = data.Year- mean_yr_all;


%% Extract data for LME2

% sort countries by continent
G_summary = groupsummary(data, ["Continent","Country"]);
all_countries = G_summary.Country;
n_C = length(all_countries);

% Countries with at least 30 observations
countries_lme2 = G_summary.Country(G_summary.GroupCount>30);

% Countries with observations across at least 3 years
for i = 1: length(countries_lme2)
    dt_country(i) = max(data.Year(data.Country == countries_lme2(i)))- min(data.Year(data.Country == countries_lme2(i)));
end
countries_lme2 = countries_lme2(dt_country>3);
indx = data.Country == countries_lme2';
data2 = data((find(sum(indx,2))),:);
data2.Continent = removecats(data2.Continent);
data2.Country = removecats(data2.Country);


%% Initialize table for export of regression results (LME1 & LME2)

% PFAS
T_lmeResults = table();
A = repmat(PFAS_names,n_C,1);
T_lmeResults.PFAS = A(:); 
FixedEffectStats = {'b1', 'b1_uncertainty', 'm1', 'm1_uncertainty', 'b2','b2_uncertainty','m2', 'm2_uncertainty'};
T_lmeResults{:, FixedEffectStats} = nan(n_C*8,length(FixedEffectStats));
A = repmat(G_summary.Continent,8,1); 
T_lmeResults.Continent = A(:);
A = repmat(all_countries,8,1);
T_lmeResults.Country = A(:); 
DataStats = {'n_p', 'n', 'n_Plant'};
T_lmeResults{:, DataStats} = nan(n_C*8,length(DataStats));
RandomEffectStats = {'b1prime', 'b1prime_uncertainty','b2prime','b2prime_uncertainty','m2prime', 'm2prime_uncertainty'};
T_lmeResults{:, RandomEffectStats} = nan(n_C*8,length(RandomEffectStats));

%% Temporal Regression Analysis

f = figure();
set(gcf,'color','w')

for i = 1:8
    
    % organize data specific to the i'th PFAS
    T = table();
    T = [data(:, PFAS_eff(i)) data(:, {'Country', 'Year', 'CenteredYear', 'Continent','Author','Plant'})];
    T((ismissing(data(:,PFAS_eff(i)))) | isinf(data{:,PFAS_eff(i)}) ,:) =[];
    g = unique(T.Country);
    g2 = unique(T.Continent);
    Tg_summary = groupsummary(T, ["Continent","Country"]);
    Tg_summary.PFAS(:) = PFAS_names(i);
    T = sortrows(T,'Year');

    %%%%%% LM %%%%%%%%%%%
    lm = fitlm(T.CenteredYear, T{:,PFAS_eff(i)});
    lm_c_CI = lm.coefCI;
    lm_slope(i) = lm.Coefficients.Estimate(2);
    lm_slopeCI(i,:) = lm_c_CI(2,:);
    lm_intCI(i,:) = lm_c_CI(1,:);

    %%%%%% LME with Random Intercept %%%%%%%%%%%
    formula = append(string(PFAS_eff(i)), "~CenteredYear+1 +(1|Country)");
    lme = fitlme(T,formula);
    
    % fixed effect estimates
    beta(i,:) = fixedEffects(lme);
    param_CI= lme.coefCI;
    lme_slopeCI(i,:) = param_CI(2,:);

    % country effect estimates (b')
    [~,~,STATS] = randomEffects(lme); 
    STATS.Level = nominal(STATS.Level);
  
    %%%%%% LME2 with random slope %%%%%%%%
    T2 = table();
    T2 = [data2(:, PFAS_eff(i)) data2(:, {'Country', 'Year', 'CenteredYear', 'Continent','Author', 'sampleTechnique'})];
    T2((ismissing(data2(:,PFAS_eff(i)))) | isinf(data2{:,PFAS_eff(i)}) ,:) =[];
    formula2 = append(string(PFAS_eff(i)), "~CenteredYear+1 +(CenteredYear|Country)");
    lme2 = fitlme(T2,formula2);
    beta2(i,:)= fixedEffects(lme2);
    param2_CI= lme2.coefCI;
 
    %%%%%% plot observations and regression predictions %%%%%% 
    plotTemporalRegression(i, PFAS_eff, T, G_summary, lm, beta, beta2, PFAS_names);
    
    if ismember(i, [8 6 3 1])
        plotUSandChina (i,lme2,T2,mean_yr_all)
    end

    %%%%%%%%% Export results to Table %%%%%

    % Add country specific Effect / Descritpions to table
    [~,idx_C] = ismember(Tg_summary.Country,all_countries,'rows');
    T_lmeResults.n((idx_C)+ ((i-1)*n_C)) = Tg_summary.GroupCount;
    Tg_summary = groupsummary(T, ["Continent","Country","Author"]);
    n_p = sum(Tg_summary.Country == all_countries');
    T_lmeResults.n_p((1:n_C) + ((i-1)*n_C))= n_p';
    Tg_summary = groupsummary(T, ["Continent","Country","Plant"]);
    n_Plant = sum(Tg_summary.Country == all_countries');
    T_lmeResults.n_Plant((1:n_C) + ((i-1)*n_C))= n_Plant';

    T_lmeResults = LME_TableResults(T_lmeResults,i,lme, lme2, all_countries);

 clear STATS; clear STATS2; clear x; clear y; clear T; clear T2;
end


figure(1)
Folder = cd;
Folder = fullfile(Folder, '..');
saveas(gcf,fullfile(Folder, '/figures and results/TemporalRegression.png'));

figure(2)
Folder = cd;
Folder = fullfile(Folder, '..');
saveas(gcf,fullfile(Folder, '/figures and results/USandChina.png'));

%% Export LME Results Table 
T2 = T_lmeResults(~isnan(T_lmeResults.b1),:);

Folder = cd;
Folder = fullfile(Folder, '..');
writetable(T2,fullfile(Folder, '/figures and results/LME_stat_results.xlsx'));

%% Plot Random Effect Estimates for LME1 vs. LME2

T_lmeResults.PFAS = categorical(T_lmeResults.PFAS);
plot_bprime(T_lmeResults)
plot_mprime(T_lmeResults, countries_lme2)

%% GDP per capita analysis 

Folder = cd;
Folder = fullfile(Folder, '..');
warning('off', 'MATLAB:table:ModifiedAndSavedVarnames')
filename = fullfile(Folder, '/data/GDP_per_cap_ALL.xls');
GDP = readtable(filename,'Format','auto');
GDP_years= 2000:2020;
ColYears = append ('x', string(GDP_years));

GDP.CountryName = categorical(GDP.CountryName);
data.GDP = nan(size(data,1),1);

for i = 1:length(all_countries)
    GDPindx = find(GDP.CountryName==all_countries(i)); 
    dataindx = find(data.Country == all_countries(i)); 
    measured_year = floor(data.Year(dataindx));
    Logical = measured_year == GDP_years;
    [row_upper col_upper] = find(Logical);

    if length (row_upper) < length(measured_year)
        display('Warning!')
    else
        data.GDP(dataindx(row_upper)) = GDP{GDPindx, ColYears(col_upper)'}';
    end  
end

plotGDPpercapRegression(data)

Folder = cd;
Folder = fullfile(Folder, '..');
saveas(gcf,fullfile(Folder, '/figures and results/GDPperCapita.png'));

