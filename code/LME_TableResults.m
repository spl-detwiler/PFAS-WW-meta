% Organizes LME1 and LME2 statistical results to table

% INPUTS
%   T = table of LME1 and LME2 regression results and stats

function T_lmeResults = LME_TableResults(T_lmeResults,i,lme, lme2, all_countries)
n_C = length(all_countries);

%%%%% LME1 %%%%%%%%%%
% fixed effect estimates
beta(i,:) = fixedEffects(lme);
param_CI= lme.coefCI;
lme_slopeCI(i,:) = param_CI(2,:);

% country effect estimates (b')
[~,~,STATS] = randomEffects(lme); 
STATS.Level = nominal(STATS.Level);

%%%%% LME2 %%%%%%%%%%
% fixed effect estimates
beta2(i,:)= fixedEffects(lme2);
param2_CI= lme2.coefCI;
% country effect estimates (b' + m')
[~,~,STATS2] = randomEffects(lme2); % Compute the random-effects statistics (STATS)
STATS2.Level = nominal(STATS2.Level);
STATS2.Name = nominal(STATS2.Name);

    for j = 1: n_C
        if ~isempty(STATS.Estimate(STATS.Level == all_countries(j)))
            T_lmeResults.("b1")(j + ((i-1)*n_C)) = beta(i,1);
            T_lmeResults.("b1_uncertainty")(j + ((i-1)*n_C))= beta(i,1)-param_CI(1,1);
            T_lmeResults.("m1")(j + ((i-1)*n_C)) = beta(i,2);
            T_lmeResults.("m1_uncertainty")(j + ((i-1)*n_C)) = beta(i,2)- param_CI(2,1);
            T_lmeResults.("b1prime")(j+((i-1)*n_C)) = STATS.Estimate(STATS.Level == all_countries(j));
            T_lmeResults.("b1prime_uncertainty")(j+((i-1)*n_C)) = STATS.Upper(STATS.Level == all_countries(j)) - STATS.Estimate(STATS.Level == all_countries(j));
            if sum(STATS2.Level == all_countries(j))>1
                T_lmeResults.("b2")(j+((i-1)*n_C)) = beta2(i,1);
                T_lmeResults.("b2_uncertainty")(j+((i-1)*n_C)) = beta2(i,1)- param2_CI(1,1);
                T_lmeResults.("m2")(j+((i-1)*n_C)) = beta2(i,2);
                T_lmeResults.("m2_uncertainty")(j+((i-1)*n_C)) = param2_CI(2,2)- beta2(i,2);
                T_lmeResults.("b2prime")(j+((i-1)*n_C)) = STATS2.Estimate(STATS2.Name ==  '(Intercept)' & STATS2.Level == all_countries(j));
                T_lmeResults.("b2prime_uncertainty")(j+((i-1)*n_C)) = STATS2.Upper(STATS2.Name == '(Intercept)' & STATS2.Level == all_countries(j))- T_lmeResults.("b2prime")(j+((i-1)*n_C));
                T_lmeResults.("m2prime")(j+((i-1)*n_C)) = STATS2.Estimate(STATS2.Name == 'CenteredYear' & STATS2.Level == all_countries(j));
                T_lmeResults.("m2prime_uncertainty")(j+((i-1)*n_C)) = STATS2.Upper(STATS2.Name == 'CenteredYear' & STATS2.Level == all_countries(j))- T_lmeResults.("m2prime")(j+((i-1)*n_C));

            end
        end
    end