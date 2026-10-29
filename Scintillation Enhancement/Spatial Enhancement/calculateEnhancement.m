% >~~~< INPUTS >~~~<
%   P, U, B = patterned, unpatterned, background signals.
%   dP, dU, dB = patterned, unpatterned, background errors.
%   
% <~~~> OUTPUTS <~~~>
%   etaprime = spatial scintillation enhancement.
%   error = error of spatial scintillation enhancement.
function [etaprime, error] = calculateEnhancement(P, U, B, dP, dU, dB)
    num = P - B; % Numerator.
    den = U - B; % Denominator.
    etaprime = (P - B)./(U - B); % Calculate etaprime.

    numError = sqrt(dP.^2 + dB.^2); % Error of the numerator term.
    denError = sqrt(dU.^2 + dB.^2); % Error of the denominator term.
    error = etaprime.*sqrt((numError./num).^2 + (denError./den).^2); % Error of etaprime.
end