function plot_model(data)


% --- Plot output
f1 = figure; hold on;
axis square
xlabel('cone #')
ylabel('Proportion of captured light')
set(gca, 'TickDir', 'out', 'TickLength', [0.04 0.04], 'FontSize', 20);

disp(mean(mean(data.per_cone_int(:, :, 1), 2)))
disp(mean(mean(data.per_cone_int(:, :, 2), 2)))
disp(mean(mean(mean(data.per_cone_int(:, :, 2:7)))));

plot(mean(data.per_cone_int(:, :, 1), 2), 'bo');
plot(mean(data.per_cone_int(:, :, 2), 2), 'r.');
plot(mean(mean(data.per_cone_int(:, :, 2:7), 2), 3), 'ko');

ylim([0 1]);

%figure saving
print(f1,'-dpsc2', fullfile('img/', [data.savename 'light_cap.eps']);