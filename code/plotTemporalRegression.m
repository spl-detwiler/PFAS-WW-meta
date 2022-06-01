% Plots global mean temporal regressions of LM, LME1, and LME2

% INPUTS
%   i = PFAS # (i'th PFAS, 1-8)
%   PFAS_eff = ex: 'PFOA_eff'
%   T = data for i'th PFAS
%   G_summary = summary table for country and continents
%   lm = standard linear model
%   beta = LME1 mean slope and intercept
%   beta2 = LME2 mean slope and intercept
%   PFAS_names: 'PFHxA', 'PFHPA', 'PFOA', ...etc

function plotTemporalRegression(i, PFAS_eff, T, G_summary, lm, beta, beta2, PFAS_names)
figure(1)
    l = 0.019;
    width = 0.17;
    height = 0.4;
    bottom = height*1.4;
   
    n_c = length(unique(G_summary.Continent));
    colors = parula(n_c+1);  % color by continent
    markersymbol= {'o','d','*', '|', '+','s', 'v', '^','p'};    % symbol per European country
    
    if i < 6
        left = (l*i) + (width*(i-1));
    end
    if i > 5 
        bottom = (0.08);
        left = (l*(i-5)) + (width*(i-6));
    end
    axes('Position',[0.03+left bottom width height])

    %plot color by continent and marker by country
    for j = 1: n_c
       continents = categories(G_summary.Continent);
       idx = find(T.Continent == G_summary.Continent(j));
       num_countries = sum(G_summary.Continent == continents(j));
       countries = G_summary.Country(G_summary.Continent == continents(j));
       for k = 1: num_countries
           scatter_y = T{T.Country == countries(k), PFAS_eff(i)};
           scatter_x = T.Year(T.Country == countries(k));
           plot(scatter_x, scatter_y, 'Color', colors(j,:), 'Marker', markersymbol(k),'LineStyle','none','LineWidth',1.2)
           hold on
       end
    end

    plot(T.Year, lm.Coefficients.Estimate(1) + (lm.Coefficients.Estimate(2)* T.CenteredYear), 'k', 'LineWidth',1.5);
    plot(T.Year, beta(i,1) + (beta(i,2) * T.CenteredYear),'b', 'LineWidth',1.5);
    plot(T.Year, beta2(i,1) + (beta2(i,2) * T.CenteredYear),'r', 'LineWidth',1.2);


    title(PFAS_names(i))
    xlim([2004 2021])
    ylim([-3.5 3.5])
    set(gcf, 'color','w')
    set(gca,'color',[0.95 0.95 0.95])
    set(gca,'FontSize', 14)
    set(gcf, 'Position', [50 138 1370 638])
    if i ==3
        lgnd= legend([G_summary.Country', 'LM', 'LME', 'LME2'], 'NumColumns',3);
        lgnd.Position= [0.65925 0.18685 0.21241 0.17555];
    end
    
    if i == 8
        xlabel(["Year"], 'FontSize',16)
    end

    if i == 1|i==6
        ylabel(['log(\bfC_{eff}\rm)'],'FontSize',16)
    end

    box on;
end

