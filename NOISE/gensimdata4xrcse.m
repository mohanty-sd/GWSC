%% Generate simulated data containing QC signal and colored noise
addpath ../SIGNALS
clear all;
%Sampling frequency for noise realization
sampFreq = 1024; %Hz
%Number of samples to generate
nSamples = 16384;
%Time samples
timeVec = (0:(nSamples-1))/sampFreq;

%Load signal parameters from JSON file
%{
%    "a1":,
%    "a2":,
%    "a3":,
%    "A":,
%    "ta":,
%    "sigLen":
%}
sigParams = loadjson('sigparams.json');
a1 = sigParams.a1;
a2 = sigParams.a2;
a3 = sigParams.a3;
A = sigParams.A;
ta = sigParams.ta;
sigLen = sigParams.sigLen;

strtIndx = max(1,find(timeVec<=ta, 1, 'last' ));
stpIndx = min(nSamples,strtIndx+floor(sigLen*sampFreq));
sigVecTmp = crcbgenqcsig(timeVec(strtIndx:stpIndx)-timeVec(strtIndx),A,[a1,a2,a3]);
sigVec = zeros(1,nSamples);
sigVec(strtIndx:stpIndx) = sigVecTmp;
% figure;
% plot(timeVec,sigVec);

%Target PSD given by the inline function handle
targetPSD = @(f) 0.1+(f>=100 & f<=300).*(f-100).*(300-f)/10000;

%Plot PSD
freqVec = 0:0.1:512;
psdVec = targetPSD(freqVec);
plot(freqVec,psdVec);

%% Generate noise realization
fltrOrdr = 500;
outNoise = statgaussnoisegen(nSamples,[freqVec(:),psdVec(:)],fltrOrdr,sampFreq);
outNoise = outNoise/std(outNoise);
%%
% Estimate the PSD
% (Pwelch plots in dB (= 10*log10(x)); plot on a linear scale)
[pxx,f]=pwelch(outNoise, 256,[],[],sampFreq);
figure;
plot(f,pxx);
xlabel('Frequency (Hz)');
ylabel('PSD');
% Plot the colored noise realization
figure;
plot(timeVec,outNoise);

%Generate data realization
dataVec = (outNoise+sigVec)';

figure;
plot(timeVec,dataVec,timeVec,sigVec);

testData = [timeVec',dataVec];
save('testData.txt','testData','-ascii');

