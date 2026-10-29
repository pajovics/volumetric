
clc;
clear;

%% Load the image and get the intensity profile.
% Add the current folder and subfolders to the MATLAB path.
folder = fileparts(which('length_estimation_v1.m'));
addpath(genpath(folder));

image = imread(uigetfile({'*.png';'*.jpeg'})); % Load the image.
grayscale_image = rgb2gray(image); % Convert to grayscale.

%% Show the image and select the edges of the sample.
% A linear ROI will be generated that can be dragged to update the line profile.
f = figure('Units', 'inches', 'Position', [3, 3, 12, 6]);
t = tiledlayout(f, 1, 3);
set(gcf, 'WindowState', 'maximized');

ax = nexttile([1, 2]);
imshow(grayscale_image, 'Parent', ax); % Display the image.

% Select the edges of the sample.
hLine1 = drawline('Position', [1, size(grayscale_image, 1)/3; size(grayscale_image, 2), size(grayscale_image, 1)/3], 'Color', 'b', 'LineWidth', 1.5);
hLine2 = drawline('Position', [1, 2*size(grayscale_image, 1)/3; size(grayscale_image, 2), 2*size(grayscale_image, 1)/3], 'Color', 'm', 'LineWidth', 1.5);

disp('Press any key when ready to process the patterns.');
pause;

%%
% Get vertical positions and plot.
y1 = round(hLine1.Position(1,2));
y2 = round(hLine2.Position(1,2));
delete(hLine1);
delete(hLine2);
line([1, length(grayscale_image(1,:))], [y1, y1], 'Color', 'r', 'LineStyle', '--');
line([1, length(grayscale_image(1,:))], [y2, y2], 'Color', 'r', 'LineStyle', '--');

% Prompt the user for the number of patterns to process.
numberOfPatterns = input('Enter the number of patterns to process: ');
% Preallocate results array: columns are [pattern number, length (μm), error (μm)].
results = zeros(numberOfPatterns, 3);

for i = 1:numberOfPatterns
%% Set the line profile.
% Linear ROI.
x = round(size(grayscale_image, 2)/2);
hLine = drawline('Position', [x, 1; x, length(grayscale_image(:,1))], 'Color', 'r', 'LineWidth', 1.5);

% Callback function to update intensity profile when line is moved.
addlistener(hLine, 'MovingROI', @(src, evt) updateProfile(grayscale_image, src.Position(1,1), y1, y2));

% Initial plot of intensity profile.
nexttile(3);
cla;
hPlot = plot(y1:y2, grayscale_image(y1:y2, x), 'k-', 'LineWidth', 1.5);
xlabel('Position (px)', 'FontSize', 11);
ylabel('Intensity (a.u.)', 'FontSize', 11);
set(gca, 'FontSize', 9);
grid on;

disp('Press any key when ready to mark the edges of the pattern.');
pause;

%% Find the top and bottom of the pattern and calculate length.
% The idea here is to delineate the extent of the defocus and use that to
% estimate the length of the patterns, with error bars.

dcm_obj = datacursormode();
set(dcm_obj, 'DisplayStyle', 'datatip', 'SnapToDataVertex', 'off', ...
    'Enable', 'on');

% TOP defocused region.
disp('For the TOP defocused region, select TWO points that indicate its width.');
% First end.
disp('Select the FIRST point of the TOP defocused region. Press any key when ready.');
pause;
c_info = getCursorInfo(dcm_obj);
Position = c_info.Position;
top1 = Position(1);
% Second end.
disp('Select the SECOND point of the TOP defocused region. Press any key when ready.');
pause;
c_info = getCursorInfo(dcm_obj);
Position = c_info.Position;
top2 = Position(1);

% BOTTOM defocused region.
disp('For the BOTTOM defocused region, select TWO points that indicate its extent.');
disp('Select the FIRST point of the BOTTOM defocused region. Press any key when ready.');
pause;
c_info = getCursorInfo(dcm_obj);
Position = c_info.Position;
bottom1 = Position(1);
disp('Select the SECOND point of the BOTTOM defocused region. Press any key when ready.');
pause;
c_info = getCursorInfo(dcm_obj);
Position = c_info.Position;
bottom2 = Position(1);

% Compute midpoints and error bars.
mid_top = (top1 + top2)/2;
err_top = abs(top2 - top1)/2;
mid_bottom = (bottom1 + bottom2)/2;
err_bottom = abs(bottom2 - bottom1)/2;

% Plot the defocused region bounds and midpoints.
nexttile(3);
yLimits = ylim();
% Plot the user-selected defocused region endpoints.
% TOP endpoints:
line([top1, top1], [yLimits(1), yLimits(2)], ...
    'Color', [0.85, 0.33, 0.10], 'LineStyle', '--', 'LineWidth', 1.5);
line([top2, top2], [yLimits(1), yLimits(2)], ...
    'Color', [0.85, 0.33, 0.10], 'LineStyle', '--', 'LineWidth', 1.5);
% BOTTOM endpoints:
line([bottom1, bottom1], [yLimits(1), yLimits(2)], ...
    'Color', [0.00, 0.45, 0.74], 'LineStyle', '--', 'LineWidth', 1.5);
line([bottom2, bottom2], [yLimits(1), yLimits(2)], ...
    'Color', [0.00, 0.45, 0.74], 'LineStyle', '--', 'LineWidth', 1.5);
% Midpoints:
line([mid_top, mid_top], [yLimits(1), yLimits(2)], ...
    'Color', [0.93, 0.69, 0.13], 'LineStyle', '-.', 'LineWidth', 2);
line([mid_bottom, mid_bottom], [yLimits(1), yLimits(2)], ...
    'Color', [0.49, 0.18, 0.56], 'LineStyle', '-.', 'LineWidth', 2);
% Shade the defocused regions.
patch([min(top1, top2), min(top1, top2), max(top1, top2), max(top1, top2)], ...
    [yLimits(1), yLimits(2), yLimits(2), yLimits(1)], [0.93, 0.69, 0.13], ...
    'FaceAlpha', 0.1, 'EdgeColor', 'none');
patch([min(bottom1, bottom2), min(bottom1, bottom2), max(bottom1, bottom2), max(bottom1, bottom2)], ...
    [yLimits(1), yLimits(2), yLimits(2), yLimits(1)], [0.49, 0.18, 0.56], ...
    'FaceAlpha', 0.1, 'EdgeColor', 'none');

nexttile(1, [1, 2]);
hold on;
pos = hLine.Position;
scatter(pos(1,1), mid_top, 80, [0.93, 0.69, 0.13], 'filled', 'MarkerEdgeColor', 'k');
scatter(pos(1,1), mid_bottom, 80, [0.49, 0.18, 0.56], 'filled', 'MarkerEdgeColor', 'k');

% Compute and display the waveguide length with error.
% The scale bars are in units of microns per pixel.
% I precisely determined them using Photoshop.
% scaleBar = 500/852; % PC-27_1st_Etch_1-22.png and PC-27_1st_Etch_23-33.png.
% scaleBar = 500/277; % PC-27_2nd_Etch_1-22.png and PC-27_2nd_Etch_23-33.png.
scaleBar = 500/277; % 3rd etch images starting in 10x.
% scaleBar = 500/557; % 3rd etch images starting in 20x.
length_px = abs(mid_bottom - mid_top);
length_microns = length_px*scaleBar;
% Propagate error.
length_error = scaleBar*sqrt(err_top^2 + err_bottom^2);

patternNumber = input('Pattern number? ');
disp(['The depth of the pattern is ', num2str(length_microns), ' μm ± ', ...
    num2str(length_error), ' μm.']);
results(i,:) = [patternNumber, length_microns, length_error];

if i < numberOfPatterns
    disp('Press any key when ready for the next pattern.');
    pause;
    % Delete the line profile so a new one can be drawn in the next iteration.
    nexttile(1);
    set(dcm_obj, 'Enable', 'off');
    delete(hLine);
end
end

% Finalize the figure (help from ChatGPT).
axis tight;
set(findall(gcf,'Type','text'),'FontName','Arial');
set(findall(gcf,'Type','axes'),'FontName','Arial');
set(gcf, 'Units', 'inches', 'Position', [0, 0, 9, 3]); % Oversized, fix in Adobe Illustrator.
saveas(gcf, 'length_estimation_example.pdf');


function updateProfile(image, x, y1, y2)
    x = round(x); % Ensure it's an integer pixel index.
    x = max(1, min(size(image,2), x)); % Keep it within bounds.
    nexttile(3); % Select the tile where intensity profile is plotted.
    hPlot = findobj(gca, 'Type', 'Line');
    set(hPlot, 'XData', y1:y2, 'YData', image(y1:y2, x)); % Update the plot data.
end