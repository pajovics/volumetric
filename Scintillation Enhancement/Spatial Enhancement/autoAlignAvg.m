% This function uses the cross-correlation between different signals to
% align them properly. The shift value where the cross-correlation is
% maximized is how the data should be shifted to ensure proper spatial
% alignment of the signals.
% This version should be used to align three of the same measurement in
% order to take their average and standard deviation.
% The signals are loaded externally to faciliate fast processing of data.
% 
% <> INPUTS <>
%   data = n x 1 cell array containing n runs of the same measurement.
%          Each cell consists of an m x 2 array with pixel number and intensity.
%   n = number of measurements.
%   baseFilename = base filename for saving the data.
%   displayResults = 1 to plot results.
% >< OUTPUTS ><
% average = N x 3 array containing pixel number, the average signal, and
%           standard deviation.
% 
function average = autoAlignAvg(data, n, baseFilename, displayResults)
    % Align data points.
    base = data{1};
    maxLeft = base(1,1);
    minRight = base(end,1);
    for i = 2:n
        temp = data{i};
        referencePoint = getAlignmentShift(temp(:,2), base(:,2), 0);
        disp(['Current alignment shift: ', num2str(referencePoint)]);
        temp = [(1:length(temp(:,2))).' - referencePoint, temp(:,2)];
        % Replacing the pixel number by some dummy 1:length(temp(:,2))
        % is necessary because the pixel numbers in the dataset are not
        % integers. Rounding will lead to strange behavior as well.
        % At the end of the day, the true pixel number is irrelevant.
        data{i} = temp;
        % We will need these for truncation.
        if min(temp(:,1)) > maxLeft
            maxLeft = min(temp(:,1));
        end
        if max(temp(:,1)) < minRight
            minRight = max(temp(:,1));
        end
    end
    % Rounding consistency...
    base = [(1:length(base(:,2))).', base(:,2)];
    data{1} = base;
    
    % Truncate the data points.
%     disp('Truncating the data points...');
    for i = 1:n
        temp = data{i};
        temp1 = temp(:,1);
        temp2 = temp(:,2);
        rowsToDelete = temp1 <= maxLeft;
        temp1(rowsToDelete) = [];
        temp2(rowsToDelete) = [];
        rowsToDelete = temp1 >= minRight;
        temp1(rowsToDelete) = [];
        temp2(rowsToDelete) = [];
        data{i} = [temp1, temp2];
    end

    % Average them.
%     disp('Averaging the data points...');
    temp1 = [];
    for i = 1:n
        temp2 = data{i};
        temp1 = [temp1, temp2(:,2)];
    end
    average = [temp2(:,1), mean(temp1, 2), std(temp1, 0, 2)];

    % Plot.
    if displayResults
        figure;
        t = tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
        % Plot the raw data.
        nexttile;
        hold on;
        for i = 1:n
            temp = data{i};
            plot(temp(:,1), temp(:,2));
            axis tight;
            grid on;
            box on;
            title('Raw data', 'FontWeight', 'normal');
        end
        % Plot the averaged results.
        nexttile;
        shadedErrorBar(average(:,1), average(:,2), average(:,3));
        axis tight;
        grid on;
        box on;
        title('Average and standard deviation', 'FontWeight', 'normal');
        % Axis labels.
        t.XLabel.String = 'Pixel number (px)';
        t.YLabel.String = 'Intensity (a.u.)';
    end
    
    % Save the data.
    filename = [baseFilename, 'autoaveraged.csv'];
    save(filename, 'average', '-ascii');
end