
clc;
clear;

% Define filenames.
imageFile = 'YbYAG_PC-27_160kVp_25W_patterns=23L-27R_binning=4_width=16_patterned.png';
dataFile = 'YbYAG_PC-27_160kVp_25W_patterns=23L-27R_binning=4_width=16_patterned_autoaveraged.csv';

% Load image.
img = imread(imageFile);

% Load data.
data = readmatrix(dataFile);
x = data(:,1);
y = data(:,2);
err = data(:,3);

% Create figure and tiled layout.
fig = figure('Units', 'normalized', 'Position', [0.2 0.2 0.3 0.6]);  % Tall aspect ratio helps.
t = tiledlayout(2, 1, 'TileSpacing', 'none', 'Padding', 'none');

% First tile: image.
ax1 = nexttile;
imshow(img, 'InitialMagnification','fit');
axis off

% Second tile: plot with shaded error bar.
ax2 = nexttile;
shadedErrorBar(x, y, err, 'lineprops', '-r');
box on
axis tight
set(ax2, 'XTickLabelMode', 'auto', 'YTickLabelMode', 'auto');

% --- Match axes widths exactly. ---
% Wait for graphics to render.
drawnow;

% Get actual width (in normalized units) of the imshow axes.
pos1 = get(ax1, 'Position');
pos2 = get(ax2, 'Position');

% Force ax2 to match the width of ax1.
pos2(1) = pos1(1);        % Left edge.
pos2(3) = pos1(3);        % Width.
set(ax2, 'Position', pos2);

% Adjust figure size.
set(gcf, 'Units', 'inches', 'Position', [1, 1, 2, 4]);

% Export as a PDF.
% exportgraphics(gcf, 'YbYAG_PC-27_160kVp_25W_patterns=23L-27R_binning=4_width=16_patterned.pdf');
% close all;