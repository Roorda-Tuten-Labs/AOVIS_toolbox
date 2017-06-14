function plot_mosaic(model_im, xloc, yloc, xi, yi, halfwidth, savename)

    f1 = figure;
    imshow(model_im); 
    hold on; 
    axis square;

    medx = median(xloc); 
    medy = median(yloc);
    plot(xloc, yloc, 'g.'); 
    xlim([medx - halfwidth medx + halfwidth]);
    ylim([medy - halfwidth medy + halfwidth]);
    for j = 1:length(xi)
        text(xi(j)-0.5, yi(j), num2str(j), 'Color', 'r', 'FontSize', 12)
    end

    % save mosaic plot
    print(f1,'-dpsc2', '-bestfit', [savename 'mosaic.eps']);
end