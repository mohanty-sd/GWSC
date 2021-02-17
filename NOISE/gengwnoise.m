function [outNoise,varargout] = gengwnoise(nSamples,fltrOrdr,sampFreq,fLow,fHigh,dtctrType)
% Generate simulated LIGO noise
%Y = GENGWNOISE(N,O,Fs,Fl,Fh,D)
%Generates a realization Y of stationary gaussian noise with a target power
%spectral density given by the initial LIGO design sensitivity curve in the
%frequency range [Fl, Fh] Hz. (The PSD is set to its value at F<a> for
%frequencies < and > F<a> for <a> = l and h respectively.) Fs is the
%sampling frequency of Y. The order of the FIR filter to be used is given
%by O. D is a string that takes the following possible values:
%    'iLigo' : Initial LIGO design sensitivity
%    'aLIGO' : Advanced LIGO design sensitivity (not implemented)
%    'Kagra' : Kagra design sensitivity curve (not implemented)
%    'Virgo' : Virgo design sensitivity curve (not implemented)
%
%[Y,P] = GENGWNOISE(N,O,Fs,Fl,Fh,D)
%Returns the (two-sided) PSD vector at positive DFT frequencies in P.

%Soumya D. Mohanty, Mar 2019

% File containing target sensitivity curve (first column is frequency and
% second column is square root of PSD).
switch dtctrType
    case 'iLigo'
        targetSens = load('iLIGOSensitivity.txt');
        %Turn one-sided sensitivity to two-sided
        targetSens(:,2) = (1/sqrt(2))*targetSens(:,2);
    case 'aLigo'
        error('Not implemented');
    case 'Kagra'
        error('Not implemented');
    case 'Virgo'
        error('Not implemented');
    otherwise
        error(['Detector type ',dtctrType,' not found']);
end

%%
% Plot the target sensitivity.
% loglog(targetSens(:,1),targetSens(:,2));
% xlabel('Frequency (Hz)');
% ylabel('Strain Sensitivity (1/\sqrt{Hz})');

% Interpolate sensitivity curve to positive DFT frequencies
minF = min(targetSens(:,1));
maxF = max(targetSens(:,1));
if minF ~= 0
% f=0 does not exist, put it in
    targetSens = [0, targetSens(1,2);...
                  targetSens];
end
if maxF < sampFreq/2
    error('High frequency limit requested is higher than supplied');
end
%Positive DFT frequencies
kNyq = floor(nSamples/2)+1;
posFreq = (0:(kNyq-1))*sampFreq/nSamples;
%Interpolate
sensVec = interp1(targetSens(:,1), targetSens(:,2), posFreq);

% Impose band restriction and set PSD outside the band to constants
indxFcutLo = posFreq < fLow;
indxFcutHi = posFreq > fHigh;
sensVec(indxFcutLo) = sensVec(sum(indxFcutLo)+1);
sensVec(indxFcutHi) = sensVec(kNyq-sum(indxFcutHi));

%PSD
psdVec = sensVec.^2;

%Generate noise realization
outNoise = statgaussnoisegen(nSamples,[posFreq(:),psdVec(:)],fltrOrdr,sampFreq);

%Optional outputs
if nargout > 1
    varargout{1} = psdVec;
end
