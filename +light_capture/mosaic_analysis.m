subject = '20076';

cones = get_all_cone_locations(subject);
figure;
plot(cones(:, 1), cones(:, 2), 'k+')

[ind, dist] = knnsearch(cones(:, 1:2), cones(:, 1:2), 'k', 7);

figure;
errorbar(1:6, mean(dist(:, 2:7)), std(dist(:, 2:7)), 'o');

set(gca, 'fontsize', 16);

xlabel('nearest neighbor #', 'fontsize', 16)
ylabel('mean distance (px)', 'fontsize', 16);
title(['Subject ' subject], 'fontsize', 16);
box off;

mean(dist(:, 2:7))
mean(mean(dist(:, 2:7)))

% get the cones from a subject
cones = get_all_cone_locations('10001');
% select out a center cone of interest
c_ind = 107;
x_mean = cones(c_ind, 1);
y_mean = cones(c_ind, 2);
% find the 20 nearest neighbors
[indexes, d] = knnsearch(cones(:, 1:2), [x_mean y_mean], 'k', 21);
% create an x, y list of cones
xi = cones(indexes(2:end), 1);
yi = cones(indexes(2:end), 2);
xi = [x_mean; xi];
yi = [y_mean; yi];

figure;
plot(xi, yi, 'ko');