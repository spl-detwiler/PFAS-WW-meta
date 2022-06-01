function plotUSandChina (i,lme2,T2, mean_yr_all)

Country1 = "US";
Country2 = "China";
T2.sampleTechnique = categorical(T2.sampleTechnique);

figure(2)
colors = magma(5);    
title_name = {'PFHxA','PFHpA', 'PFOA',  'PFNA', 'PFDA','PFBS', 'PFHxS', 'PFOS'};
PFAS_eff = {'PFHxA_eff','PFHpA_eff', 'PFOA_eff',  'PFNA_eff', 'PFDA_eff','PFBS_eff', 'PFHxS_eff', 'PFOS_eff'};

l = 0.0017;
n_c = 2;
n_r = 4;
width = 0.72/n_c;
height = 0.87/n_r;
% bottom = height*1.51;

ii = [8 6 3 1];
k = find (ii == i);

    beta2(i,:)= fixedEffects(lme2);
    param2_CI= lme2.coefCI;

    set(gcf, 'Position', [471 30 603 763])
    left = 0.15;
    bottom = 0.06+ (height*1.04*(k-1));
%     left = (l*i) + ((width+0.015)*(i-1));
    axes('Position',[left bottom width height])
    
    tblnew=table();
    tblnew.Year= (2000:2021)';
    tblnew.CenteredYear=(tblnew.Year- mean_yr_all);
    tblnew.Country = repmat(Country1,(size(tblnew.Year)));
    tblnew.Country = categorical(cellstr(tblnew.Country));

    hold on
    for alpha = [0.95 0.68 0.50]
        [ypred2, ci2] = predict(lme2,tblnew, 'Prediction','observation', 'Alpha', 1-alpha);
        x2 = [tblnew.Year', fliplr(tblnew.Year')];
        inBetween2 = [ci2(:,1)' fliplr(ci2(:,2)')];
        l_text = [alpha*100+"% CI"];
        fill(x2, inBetween2, [0.79 0.81 0.81],'LineStyle', ':', 'FaceAlpha', 2-(2*alpha), 'DisplayName', l_text);
    end
    s_c = plot(T2.Year(T2.Country == Country1 & T2.sampleTechnique == 'composite'), ...
        T2.(PFAS_eff{ii(k)})(T2.Country == Country1 & T2.sampleTechnique == 'composite'),'o',...
        'Color',[0.1010 0.6 0.8], 'MarkerFaceColor',[0.1010 0.6 0.8], 'HandleVisibility','off');
    s_g = plot(T2.Year(T2.Country == Country1 & T2.sampleTechnique == 'grab'),...
         T2.(PFAS_eff{ii(k)})(T2.Country == Country1 & T2.sampleTechnique == 'grab'),'^',...
         'Color',[0.1010 0.6 0.8], 'MarkerFaceColor',[0.1010 0.6 0.8],...
         'HandleVisibility', 'off');
    p2 = plot(tblnew.Year, ypred2,'linewidth',2,'Color',[0 0.4 0.7], 'DisplayName',string({'LME2 Predicted C_{eff} for ' + Country2}));
    
    xlim([2003 2021])
    ylim([-1.7 3.5])
    if k ==4
        title('United States', 'Color', [0 0.4 0.7])
    end
    if k ==1
        xlabel('Sampled Year','FontWeight','bold')
    end
    ylabel(title_name(ii(k)),'FontWeight','bold','Color','k', 'Rotation',0, 'HorizontalAlignment','right','VerticalAlignment','middle')
    
    if k >1
        set(gca, 'xTickLabel', [])
    end

    set(gca, 'fontsize', 15);
    box on;
    grid on;
    hold off
%     title(title_name(ii(k)))
    

%     bottom = height*1.2*(i-1);
    left = left + (1.03*width);
    axes('Position',[left bottom width height]);
    tblnew2 =table();
    tblnew2.Year= (2000:2021)';
    tblnew2.CenteredYear=(tblnew2.Year- mean_yr_all);
    tblnew2.Country = repmat(Country2,(size(tblnew2.Year)));
    tblnew2.Country = categorical(cellstr(tblnew2.Country));
    
    hold on
    for alpha = [0.95 0.68 0.50]
        [ypred, ci] = predict(lme2,tblnew2, 'Prediction','observation', 'Alpha', 1-alpha);
        x = [tblnew2.Year', fliplr(tblnew2.Year')];
        inBetween = [ci(:,1)' fliplr(ci(:,2)')];
        l_text = [alpha*100+"% CI"];
        fill(x, inBetween, [0.81 0.79 0.79],'LineStyle', ':', 'FaceAlpha', 2-(2*alpha), 'DisplayName', l_text);
    end
    s_c = plot(T2.Year(T2.Country == Country2 & T2.sampleTechnique == 'composite'), ...
        T2.(PFAS_eff{ii(k)})(T2.Country == Country2 & T2.sampleTechnique == 'composite'),'o',...
        'Color',[0.75 0.3 0.12], 'MarkerFaceColor',[0.75 0.3 0.12], 'HandleVisibility','off');
    s_g = plot(T2.Year(T2.Country == Country2 & T2.sampleTechnique == 'grab'),...
         T2.(PFAS_eff{ii(k)})(T2.Country == Country2 & T2.sampleTechnique == 'grab'),'^',...
         'Color',[0.75 0.3 0.12], 'MarkerFaceColor',[0.75 0.3 0.12],...
         'HandleVisibility', 'off');
    p2 = plot(tblnew.Year, ypred,'linewidth',2,'Color',[0.72 0.25 0.05], 'DisplayName',string({'LME2 Predicted C_{eff} for ' + Country2}));
    p2 = plot(tblnew.Year, ypred2+8,'linewidth',2,'Color',[0 0.4 0.7], 'DisplayName',string({'LME2 Predicted C_{eff} for ' + Country1}));
 
    
   xlim([2003 2021])
   ylim([-1.7 3.5])
    if k ==4
        title('China', 'Color', [0.72 0.25 0.05])
    end

    if k >1
        set(gca, 'xTickLabel', [])
    end
    if k ==1
        xlabel('Sampled Year','FontWeight','bold')
    end
    set(gca, 'yTickLabel', [])
    set(gca, 'fontsize', 15);
    box on;
    grid on;
    hold off

    yyaxis right
    ylabel('log (\bfC_{eff}\rm)', 'Color', 'k',"Rotation",270, 'VerticalAlignment','bottom')
    set(gca,'yColor','k')
    ylim([-1.7 3.5])
% 
% end
