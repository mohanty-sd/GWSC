%% Generate Mock Data Challenge
%Set Paths: 
% For noise generation
addpath ../NOISE ;
% For normalizations and likelihood ratio
addpath ../DETEST ;
% For signal generation
addpath ../SIGNALS ;
% For PSO
glblPths = loadjson('../globalpaths.json');
addpath(glblPths.SDMBIGDAT19) ;

%%
% Name of files.
trDataFile = 'TrainingData';
analDataFile = 'AnalysisData';
keyFile = 'keyFile';

%%
% Challenge 1: Initial LIGO noise and quadratic chirp signal. Unknown
% parameters are amplitude and phase parameters
nSamplesTraining = 20480;
nSamplesData = 2048;
sampFreq = 1024;

%Signal parameters
sigParamsKey = loadjson('MDCkey.json');
snr = sigParamsKey.snr;
a1 = sigParamsKey.a1;
a2 = sigParamsKey.a2;
a3 = sigParamsKey.a3;

%Filter order for noise generation
fltrOrdr = 400;
fLow = 40;
fHigh = 700;

%Generate noise to be used for training PSD estimate 
rng('default');
noiseVecMaster = gengwnoise(nSamplesTraining+nSamplesData+fltrOrdr,fltrOrdr,sampFreq,fLow,fHigh,'iLigo');
trainData = noiseVecMaster(fltrOrdr:nSamplesTraining);

%Generate noise to be added to challenge data
noiseVecData = noiseVecMaster((1+(nSamplesTraining+fltrOrdr)):end);

%Generate signal
timeVec = (0:(nSamplesData-1))/sampFreq;
sigVec = crcbgenqcsig(timeVec,snr,[a1,a2,a3]);
%Normlalize
kNyq = floor(nSamplesData/2)+1;
[~,psdVec] = gengwnoise(nSamplesData,fltrOrdr,sampFreq,fLow,fHigh,'iLigo'); 
sigVec = normsig4psd(sigVec,sampFreq,psdVec,snr);

%Data vector
dataVec = noiseVecData + sigVec;

%Save data files
save(trDataFile,'trainData','sampFreq');
save(analDataFile','dataVec','sampFreq');
save(keyFile,'a1','a2','a3','snr','psdVec','sigVec');

%Plots
figure;
plot((0:(length(trainData)-1))/sampFreq,trainData);
xlabel('Time (Sec)');
ylabel('Strain');
title('Training data');

figure;
plot(timeVec,dataVec);
hold on;
plot(timeVec,sigVec);
xlabel('Time (Sec)');
ylabel('Strain');

