% This function uses the cross-correlation between different signals to
% align them properly. The shift value where the cross-correlation is
% maximized is how the data should be shifted to ensure proper spatial
% alignment of the signals.
% PUB = Patterned, Unpatterned, and Background. This version should be used
% with the averaged signals for each of these three measurements.
% The signals are loaded externally to faciliate fast processing of data.
%
% <> INPUTS <>
%   background = l x 2 array, consisting of pixel number and the
%                corresponding background signal.
%   patterned = m x 2 array, patterned signal and pixel number.
%   unpatterned = n x 2 array, unpatterned signal and pixel number.
%   method = 'full': uses the entire signal cross-correlation.
%            'part': uses a region of interest selected by the user.
%   displayResults = 1 to plot results.
% >< OUTPUTS ><
% results = N x 4 array containing the aligned signals, with arbitrary pixel number,
%           background, patterned, and unpatterned signals in that order.
%
function results = autoAlignPUB(background, patterned, unpatterned, baseFilename, ...
    method, displayResults)
    
    % Initial plot.
    f1 = figure;
    t = tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    nexttile(t,1);
    hold on;
    plot(patterned(:,1), patterned(:,2));
    plot(unpatterned(:,1), unpatterned(:,2));
    plot(background(:,1), background(:,2));
    
    % Method 1: use the full dataset to compute the cross-correlation.
    if strcmp(method, 'full')
        % Shift unpatterned data.
        referencePoint = getAlignmentShift(unpatterned(:,2), patterned(:,2), 0);
        disp(['Unpatterned alignment shift: ', num2str(referencePoint)]);
        unpatterned = [unpatterned(:,1) - referencePoint, unpatterned(:,2), unpatterned(:,3)];
    
        % Shift background data.
        referencePoint = getAlignmentShift(background(:,2), patterned(:,2), 0);
        disp(['Background alignment shift: ', num2str(referencePoint)]);
        background = [background(:,1) - referencePoint, background(:,2), background(:,3)];
        % Method 2: select a region of interest and use that.
    elseif strcmp(method, 'part')
        disp('To align the data, you will select a region with one or more features that can be used as a reference point.');
        f2 = figure;
        hold on;
    
        disp('Pick the left edge of the region.');
        plot(patterned(:,1), patterned(:,2));
        dcm_obj = datacursormode();
        set(dcm_obj, 'DisplayStyle', 'datatip', ...
            'SnapToDataVertex', 'off', 'Enable', 'on');
        pause;
        c_info = getCursorInfo(dcm_obj);
        Position = c_info.Position;
        leftidx = Position(1);
        scatter(Position(1), Position(2));
    
        disp('Pick the right edge of the region.');
        dcm_obj = datacursormode();
        set(dcm_obj, 'DisplayStyle', 'datatip', ...
            'SnapToDataVertex', 'off', 'Enable', 'on');
        pause;
        c_info = getCursorInfo(dcm_obj);
        Position = c_info.Position;
        rightidx = Position(1);
        scatter(Position(1), Position(2));
    
        referenceRegion = leftidx:rightidx;
        % Shift unpatterned data.
        referencePoint = getAlignmentShift(unpatterned(referenceRegion,2), ...
            patterned(referenceRegion,2), 0);
        disp(['Unpatterned alignment shift: ', num2str(referencePoint)]);
        unpatterned = [unpatterned(:,1) - referencePoint, unpatterned(:,2), unpatterned(:,3)];
    
        % Shift background data.
        referencePoint = getAlignmentShift(background(referenceRegion,2), ...
            patterned(referenceRegion,2), 0);
        disp(['Background alignment shift: ', num2str(referencePoint)]);
        background = [background(:,1) - referencePoint, background(:,2), background(:,3)];
    
        close(f2);
    elseif strcmp(method, 'manual')
        % This method does not align the background, as it is too noisy to do manually.
        disp('To align the data, you will select two points that appear on both plots.');
        f2 = figure;
        hold on;

        disp('Pick a reference point to align the data (patterned).');
        plot(patterned(:,1), patterned(:,2));
        dcm_obj = datacursormode();
        set(dcm_obj, 'DisplayStyle', 'datatip', ...
            'SnapToDataVertex', 'off', 'Enable', 'on');
        pause;
        c_info = getCursorInfo(dcm_obj);
        Position = c_info.Position;
        referencePoint(1) = Position(1);
        scatter(Position(1), Position(2));
    
        disp('Pick a reference point to align the data (unpatterned).');
        plot(unpatterned(:,1), unpatterned(:,2));
        dcm_obj = datacursormode();
        set(dcm_obj, 'DisplayStyle', 'datatip', ...
            'SnapToDataVertex', 'off', 'Enable', 'on');
        pause;
        c_info = getCursorInfo(dcm_obj);
        Position = c_info.Position;
        referencePoint(2) = Position(1);
        scatter(Position(1), Position(2));
    
        patterned = [patterned(:,1)+(referencePoint(1)-referencePoint(1)), ...
            patterned(:,2), patterned(:,3)];
        unpatterned = [unpatterned(:,1)+(referencePoint(1)-referencePoint(2)), ...
            unpatterned(:,2), unpatterned(:,3)];

        close(f2);
    end
    
    left = max([min(patterned(:,1)), min(unpatterned(:,1)), min(background(:,1))]);
    right = min([max(patterned(:,1)), max(unpatterned(:,1)), max(background(:,1))]);
    
    lind = find(patterned == left);
    rind = find(patterned == right);
    patterned = patterned(lind:rind,:);
    lind = find(unpatterned == left);
    rind = find(unpatterned == right);
    unpatterned = unpatterned(lind:rind,:);
    lind = find(background == left);
    rind = find(background == right);
    background = background(lind:rind,:);
    
    figure(f1);
    nexttile(t,2);
    hold on;
    plot(patterned(:,2));
    plot(unpatterned(:,2));
    plot(background(:,2));
    
    % Gather the results.
    % Since the data are aligned, we don't need specific pixel numbers anymore,
    % so just use 1:length(background) as the pixel number.
    results = [(1:length(background)).', ...
        background(:,2:3), patterned(:,2:3), unpatterned(:,2:3)];
    filename = [baseFilename, 'PUBstdev.csv'];
    save(filename, 'results', '-ascii');
end