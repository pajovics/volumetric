function shift = getAlignmentShift(signal1, signal2, dispResults)
    % Calculate the cross-correlation.
    [xc, lags] = xcorr(signal1, signal2, 'none');
    [~, maxidx] = max(xc);
    shift = lags(maxidx);  % This is the shift where the cross-correlation peaks.

    % Plot the cross-correlation as a function of shift.
    if dispResults
        figure;
        plot(lags, xc, 'LineWidth', 1.5);
        xlabel('Shift (px)');
        ylabel('Normalized cross-correlation');
        grid on;

        % Display the shift at maximum cross-correlation.
        disp(['Alignment shift: ', num2str(shift)]);
    end
end