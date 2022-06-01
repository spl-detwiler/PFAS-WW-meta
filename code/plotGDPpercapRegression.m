function plotGDPpercapRegression(data)
PFAS_names = {'PFHxA','PFHpA', 'PFOA',  'PFNA', 'PFDA','PFBS', 'PFHxS', 'PFOS'};
PFAS_eff = {'PFHxA_eff','PFHpA_eff', 'PFOA_eff',  'PFNA_eff', 'PFDA_eff','PFBS_eff', 'PFHxS_eff', 'PFOS_eff'};

f= figure();
f.Position = [49 21 1291 776];
set(gcf,'color','w')
n_c = 4;
n_r = 2;
l = 0.001;
width = 0.85/n_c;
height = 0.73/n_r;
bottom = height*1.6;

for i = 1:8
        % figure spacing
    if i < 5
        left = (l*i) + ((width+0.02)*(i-1));
    end
    if i > 4 
        bottom = (0.12);
        left = (l*(i-(n_c))) + ((width+0.02)*(i-(n_c+1)));
    end
    axes('Position',[0.06+left bottom width height])
    
    lm = fitlm(data.GDP/10000, data.(PFAS_eff{i}));
    [y ci_y]= predict(lm);
    lmCoef_p = lm.Coefficients.pValue;
    lmcoef = lm.Coefficients.Estimate;
    slope(i) = lmcoef(2);
    coef_CI= lm.coefCI;
    slope_uncertainty(i) = coef_CI(2,2) - slope(i);

    [ci_y I] = sort(ci_y);
    gdp_sorted  = data.GDP/10000 ;
    gdp_sorted = gdp_sorted(I);

    p2 = plot(data{:,'GDP'}/10000, data{:,PFAS_eff{i}} , '.', 'Color', [0.6350 0.0780 0.1840]); 
    hold on
    p3 = plot(data{:,'GDP'}/10000, y, 'k','linewidth',2);
    plot(gdp_sorted(:,1),ci_y(:,1), 'r--'); 
    plot(gdp_sorted(:,2),ci_y(:,2), 'r--');

    txt= ['slope = '  num2str(round(slope(i),2))  '\pm' num2str(round(slope_uncertainty(i) ,2))];
    text (3.5, -1.8, txt , 'FontSize', 14);
    txt =  sprintf('p = %1.2e',  lmCoef_p(2));
    text (3.5, -2.2, txt, 'FontSize', 14);
    text(3.5, -2.6,"R^2 = " + round(lm.Rsquared.Ordinary,2), 'FontSize',14);
    xlim([-0.1 6.9])
    ylim([-2.9 3.4])
    title(PFAS_names(i))

        if i >4
        xlabel('GDP per Capita [10,000 US$]')
    end

    if i == 1|i==(n_c+1)
        ylabel("log(\bfC_{eff}\rm)")
    end

    set(gca, 'fontsize', 18);
    set(gca, 'Color', 'w');
    box on;

end

