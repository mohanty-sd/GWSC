%% Minimize the fitness function QCLRFUNC using PSO
% Folder for quadratic chirp signal generator
% For noise generation
addpath ../NOISE ;
% For normalizations and likelihood ratio
addpath ../DETEST ;
% For signal generation
addpath ../SIGNALS ;
% For PSO
glblPths = loadjson('../globalpaths.json');
addpath(glblPths.SDMBIGDAT19) ;

% Data length
nSamples = 512;
% Sampling frequency
Fs = 512;
% Signal to noise ratio of the true signal
snr = 10;
% Phase coefficients parameters of the true signal
a1 = 10;
a2 = 3;
a3 = 3;

% Search range of phase coefficients
rmin = [1, 1, 1];
rmax = [180, 10, 10];

% Number of independent PSO runs
nRuns = 8;
%% Do not change below
% Generate data realization
dataX = (0:(nSamples-1))/Fs;
% Reset random number generator to generate the same noise realization,
% otherwise comment this line out
rng('default');
% Generate data realization
%---------------------
% This is the noise psd we will use.
noisePSD = @(f) (f>=50 & f<=100).*(f-50).*(100-f)/625 + 1;
dataLen = nSamples/Fs;
kNyq = floor(nSamples/2)+1;
posFreq = (0:(kNyq-1))*(1/dataLen);
psdVec = noisePSD(posFreq);
% Generate colored Gaussian noise realization 
noiseVec = statgaussnoisegen(nSamples,[posFreq(:),psdVec(:)],10,Fs);
% This is the signal we will add 
sig = crcbgenqcsig(dataX,1,[a1,a2,a3]);
% Signal normalized to specified SNR
[sig,~]=normsig4psd(sig,Fs,psdVec,snr);
%Data realization
dataY = noiseVec+sig;

% Input parameters for QCPSO
inParams = struct('dataX', dataX,...
                  'dataY', dataY,...
                  'dataXSq',dataX.^2,...
                  'dataXCb',dataX.^3,...
                  'sampFreq',Fs,...
                  'psd',psdVec,...
                  'rmin',rmin,...
                  'rmax',rmax);
% QCPSO runs PSO on the QCLRFUNC fitness function. As an
% illustration of usage, we change one of the PSO parameters from its
% default value.
outStruct = qcpso(inParams,struct('maxSteps',2000),nRuns);

%%
% Plots
figure;
hold on;
plot(dataX,dataY,'.');
plot(dataX,sig);
for lpruns = 1:nRuns
    plot(dataX,outStruct.allRunsOutput(lpruns).estSig,'Color',[51,255,153]/255,'LineWidth',4.0);
end
plot(dataX,outStruct.bestSig,'Color',[76,153,0]/255,'LineWidth',2.0);
disp(['Estimated parameters: a1=',num2str(outStruct.bestQcCoefs(1)),...
                             '; a2=',num2str(outStruct.bestQcCoefs(2)),...
                             '; a3=',num2str(outStruct.bestQcCoefs(3))]);





