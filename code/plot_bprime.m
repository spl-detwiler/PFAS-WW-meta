% Plots Temporal LME regression results 

% INPUTS
%   T = table of LME1 and LME2 regression results and stats

function plot_bprime(T)

PFAS_names = {'PFHxA','PFHpA', 'PFOA',  'PFNA', 'PFDA','PFBS', 'PFHxS', 'PFOS'};

% configure country ordering
T.Country = cellstr(T.Country);
G_summary = groupsummary(T, ["Continent","Country"]);
T.Country = categorical(T.Country);
T.Country = reordercats(T.Country, G_summary.Country);

%%
f= figure();
f.Position= [1699 283 1201 478];
%set(gcf,'color','w')
l = 0.01;
bottom = 0.12;
width = 0.1;
height = 0.7;

for i = 1:8
    t = T(T.PFAS == PFAS_names(i),:);
    left = (l*i) + (width*(i-1));
    axes('Position',[0.1+left bottom width height])
    n_c = length(t.b1prime);
    ytick = 1:2:2*n_c-1;

    for j = 1:n_c
            fx_lower = t.b2prime(j) - t.b2prime_uncertainty(j); 
            fx_upper = t.b2prime(j) + t.b2prime_uncertainty(j); 
            fx_center = t.b2prime(j);

            fx_lower = fx_lower + t.b2(j);
            fx_upper = fx_upper + t.b2(j);
            fx_center = fx_center + t.b2(j);
        
        
        if t.b1prime(j) > 0
            f = t.b1prime(j)/max(T.b1prime);
            r = 0.5*(1+f);
            b = 0.5* (1-f);
            color = [r 0 b];
        
         else if t.b1prime(j)< 0
            f = t.b1prime(j)/ min(T.b1prime);
            r = 0.5* (1-f);
            b = 0.5*(1+f);
            color = [r 0 b];

         else if t.b1prime(j)==0
            color = 'k';
            fx_lower = nan;
            fx_upper = nan;
            fx_center = nan;
        end
        end 
        end
        fill([fx_lower fx_lower fx_upper fx_upper], [ytick(j)-1 ytick(j)+1 ytick(j)+1 ytick(j)-1 ], [0.85 0.85 0.6], 'LineStyle','none')
        hold on 
        plot([fx_center fx_center], [ytick(j)-1 ytick(j)+1], 'Color',[0.2 0.5 0.5], 'linewidth',1.5)
        
        if t.n_Plant(j)>0
            plot(zeros(5,1)+t.b1(j),linspace(0,ytick(end)+2.5, 5),'linewidth',1, 'Color', [0.5 0 0.5]);
            ms = ((t.n_Plant(j) - mean(t.n_Plant, 'omitnan'))/ std(t.n_Plant,'omitnan'))*2.3 +5.3;
            errorbar(t.("b1prime")(j) + t.("b1")(j), ytick(j), t.("b1prime_uncertainty")(j), 'horizontal','o', 'MarkerFaceColor', color, 'Color',color, 'LineWidth',1.5,'MarkerSize',ms);
        end
    end

    xlim([-2.2 2.5])
    ylim([0 ytick(end)+1])
    if i>1
        set(gca, 'yTickLabel', [])
    else
        ylabel('Random Effect')
        a = gca;
        a.YTick = ytick;
        a.YTickLabel = string(t.Country') ; 
        
    end
        set(gca, 'XTick', -2:2)
        xlabel("b+b'")
        xlabel("$ b + \boldmath{b'}$",'Interpreter','latex');
    set(gca, 'fontsize', 15);
    grid on
    box on;
    grid minor


% Fixed Effect

    axes('Position',[0.1+left bottom+height+0.02 width 0.06])
    fx_lower = t.b2(17) - t.b2_uncertainty(17);
    fx_upper = t.b2(17) + t.b2_uncertainty(17);
    fx_center = t.b2(17);

    fill([fx_lower fx_lower fx_upper fx_upper], [2 4 4 2], [0.85 0.85 0.6], 'LineStyle','none')
    hold on
    plot([fx_center fx_center], [2 4], 'Color',[0.2 0.5 0.5], 'linewidth',1.5)
    errorbar(t.b1(17), 3, t.b1_uncertainty(17), 'horizontal','s','MarkerFaceColor', [0.5 0 0.5], 'Color',[0.5 0 0.5],'LineWidth',1.5, 'MarkerSize',9);
    if i>1
        set(gca, 'yTickLabel', [])
    else
        a = gca;
        a.YTick = [2.6 3.7];
        a.YTickLabel = ["(b'=0)"; "Global Mean"] ; 
        ylabel('Fixed Effect')
    end


    xlim([-2.2 2.5])
    title(PFAS_names(i))
    set(gca, 'xTickLabel', [])
    set(gca, 'fontsize', 16);
    grid on
    box on;
    grid minor
end
Folder = cd;
Folder = fullfile(Folder, '..');
saveas(gcf,fullfile(Folder, '/figures and results/CountryMean.png'));

end
