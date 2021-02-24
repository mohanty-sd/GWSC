%% MDC solution
% We will use the training data to estimate the noise PSD. The estimate
% will be smoothed. Then we will use the smoothed PSD to do GLRT and fine
% estimated parameters.

%% Set up.
% (Ensure that the path extensions used for generating MDC are removed.)
% Path for PSO code.
% For noise generation
addpath ../NOISE ;
% For normalizations and likelihood ratio
addpath ../DETEST ;
% For signal generation
addpath ../SIGNALS ;
% For PSO
glblPths = loadjson('../globalpaths.json');
addpath(glblPths.SDMBIGDAT19) ;

%% File names
% Analysis data file
anlDataFile = 'analysisData';
%%
% Training data file
trnDataFile = 'TrainingData';

%% Settings for QCPSO.
nRuns = 8;
rmin = [40, 1, 1];
rmax = [100, 50, 15];

%% Estimate noise PSD from training data
% The estimated PSD will be smoothed.
load(trnDataFile);
%%
% Estimate PSD (2Hz resolution).
[pxx,f]=pwelch(trainData,sampFreq/2,[],[],sampFreq);
semilogy(f,pxx);
%% Smooth the PSD estimate
smthOrdr = 10;
b = ones(1,smthOrdr)/smthOrdr;
pxxSmth = filtfilt(b,1,pxx);
hold on;
semilogy(f,pxxSmth);

%% Obtain GLRT and MLE
% Load analysis data.
load(anlDataFile);
nSamples = length(dataVec);
timeVec = (0:(nSamples-1))/sampFreq;
%%
% PSD must be supplied at DFT frequencies.
kNyq = floor(nSamples/2)+1;
posFreq = (0:(kNyq-1))*sampFreq/nSamples;
psdVecEst = interp1(f,pxxSmth,posFreq);
%%
% Set up PSO input parameter structure.
inParams = struct('dataX', timeVec,...
                  'dataY', dataVec,...
                  'dataXSq',timeVec.^2,...
                  'dataXCb',timeVec.^3,...
                  'sampFreq',sampFreq,...
                  'psd',psdVecEst,...
                  'rmin',rmin,...
                  'rmax',rmax);
% QCPSO runs PSO on the QCLRFUNC fitness function. As an
% illustration of usage, we change one of the PSO parameters from its
% default value.
outStruct = qcpso(inParams,struct('maxSteps',2000),nRuns);
% Plots
figure;
hold on;
plot(timeVec,dataVec,'.');
for lpruns = 1:nRuns
    plot(timeVec,outStruct.allRunsOutput(lpruns).estSig,'Color',[51,255,153]/255,'LineWidth',4.0);
end
plot(timeVec,outStruct.bestSig,'Color',[76,153,0]/255,'LineWidth',2.0);
disp(['Estimated parameters: a1=',num2str(outStruct.bestQcCoefs(1)),...
                             '; a2=',num2str(outStruct.bestQcCoefs(2)),...
                             '; a3=',num2str(outStruct.bestQcCoefs(3))]);
