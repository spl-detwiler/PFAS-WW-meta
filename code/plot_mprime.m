% Plots Temporal LME regression results 

% INPUTS
%   T = table of LME regression results and stats
%   countries_lme2 = countries with n>30 observations and measured across
%   over 3 sampling years

function plot_mprime(T,countries_lme2)
%% Plot lme2 estimates
PFAS_names = {'PFHxA','PFHpA', 'PFOA',  'PFNA', 'PFDA','PFBS', 'PFHxS', 'PFOS'};

% configure country ordering
T.Country = cellstr(T.Country);
G_summary = groupsummary(T, ["Continent","Country"]);
T.Country = categorical(T.Country);
T.Country = reordercats(T.Country, G_summary.Country);


f= figure();
f.Position= [191 263 1201 404];
%set(gcf,'color','w')
l = 0.01;
bottom = 0.12;
width = 0.1;
height = 0.69;

for i = 1:8
    t = T(T.PFAS == PFAS_names(i),:);
    left = (l*i) + (width*(i-1));
    axes('Position',[0.1+left bottom width height]);

    [row column] = find(t.Country == countries_lme2');
    tbl = table();
    tbl.country = countries_lme2;
    tbl.slope = t.m2prime(row);
    tbl.slope_uncertainty = t.m2prime_uncertainty(row);
    n_c = length(tbl.country);
%     
    ytick = 1:2:2*n_c-1;

    
    for j = 1: length(tbl.country)
        fx_lower = tbl.slope(j) - tbl.slope_uncertainty(j);
        fx_upper = tbl.slope(j) + tbl.slope_uncertainty(j);
        fx_center = tbl.slope(j);
       
        fx_lower = fx_lower + t.m2(row);
        fx_upper = fx_upper + t.m2(row);
        fx_center = fx_center + t.m2(row);

        if fx_lower >  0
            fill([fx_lower fx_lower fx_upper fx_upper], [ytick(j)-1 ytick(j)+1 ytick(j)+1 ytick(j)-1 ], [ 0.89 0.85 0.85], 'LineStyle','none')
        elseif fx_upper < 0
            fill([fx_lower fx_lower fx_upper fx_upper], [ytick(j)-1 ytick(j)+1 ytick(j)+1 ytick(j)-1 ], [ 0.85 0.89 0.89], 'LineStyle','none')
        else 
            fill([fx_lower fx_lower fx_upper fx_upper], [ytick(j)-1 ytick(j)+1 ytick(j)+1 ytick(j)-1 ], [ 0.86 0.86 0.86], 'LineStyle','none')
        end
        hold on 

        if fx_center < 0
            plot([fx_center fx_center], [ytick(j)-1 ytick(j)+1], 'Color',[0 0 0.8], 'linewidth',1.5)
        elseif fx_center > 0
            plot([fx_center fx_center], [ytick(j)-1 ytick(j)+1], 'Color',[0.8 0 0], 'linewidth',1.5)
        end

        plot(zeros(5,1)+t.m2(row(1)),linspace(0,ytick(end)+2.5, 5),'k--','linewidth',1.5);
        plot(zeros(5,1),linspace(0,ytick(end)+2.5, 5),'Color', [0.5 0 0.5], 'linewidth',1);

    end

    if i>1
        set(gca, 'yTickLabel', [])
    else
        ylabel('Random Effect')
        a = gca;
        a.YTick = ytick;
        a.YTickLabel = string(tbl.country') ; 
        
    end

    title([PFAS_names{i}])
    xlim ([-0.15 0.32])
    ylim ([0 ytick(end)+1])
    set(gca,'FontSize', 16);
    xlabel("$ m + \boldmath{m'}$",'Interpreter','latex');
    grid on
    box on;
    grid minor

    % Fixed Effect
    axes('Position',[0.1+left bottom+height+0.01 width 0.11])
    fx_lower = t.m2(row(1)) - t.m2_uncertainty(row(1));
    fx_upper = t.m2(row(1)) + t.m2_uncertainty(row(1));
    fx_center = t.m2(row(1));


    if fx_lower >  0
        fill([fx_lower fx_lower fx_upper fx_upper], [0 5 5 0], [ 0.89 0.85 0.85], 'LineStyle','none')
    elseif fx_upper < 0
        fill([fx_lower fx_lower fx_upper fx_upper], [0 5 5 0], [ 0.85 0.89 0.89], 'LineStyle','none')
    else 
        fill([fx_lower fx_lower fx_upper fx_upper], [0 5 5 0], [ 0.86 0.86 0.86], 'LineStyle','none')
    end
    hold on
    plot([fx_center fx_center], [0 5], 'k--', 'linewidth',1.5)
    if t.("m1")(17) - t.("m1_uncertainty")(17) > 0 
        errorbar(t.("m1")(17), 3, t.("m1_uncertainty")(17), 'horizontal','s','MarkerFaceColor', [1 0 0], 'Color',[1 0 0],'LineWidth',1.5);
    elseif t.("m1")(17) + t.("m1_uncertainty")(17) < 0 
        errorbar(t.("m1")(17), 3, t.("m1_uncertainty")(17), 'horizontal','s','MarkerFaceColor', [0 0 1], 'Color',[0 0 1],'LineWidth',1.5);
    else
    errorbar(t.("m1")(17), 3, t.("m1_uncertainty")(17), 'horizontal','s','MarkerFaceColor', [0.4 0 0.6], 'Color',[0.4 0 0.6],'LineWidth',1.5);
    end

    plot(zeros(2,1),[0 5],'Color',[0.5 0 0.5], 'linewidth',1);
    if i>1
        set(gca, 'yTickLabel', [])
    else
        a = gca;
        a.YTick = [1.8 3.7];
        a.YTickLabel = ["(m'=0)"; "Global Mean"] ; 

        ylabel('Fixed Effect')
    end
    xlim ([-0.15 0.32])
    title(PFAS_names(i))

    set(gca, 'xTickLabel', [])
    set(gca, 'fontsize', 16);
    grid on
    box on;
    grid minor

end

Folder = cd;
Folder = fullfile(Folder, '..');
saveas(gcf,fullfile(Folder, '/figures and results/CountryTrends.png'));



