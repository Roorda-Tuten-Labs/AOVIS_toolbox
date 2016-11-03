import plots.*

data = [2 2 2 5 5; 2 3 3 5 5; 5 5 3 3 3; 2 2 2 3 5];

figure();
subplot(1, 1, 1);

plots.plot_uad(data, 10, 'test title');