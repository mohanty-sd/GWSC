%% Verify Mock data generation
% Set Paths: 
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
%Clear workspace
clear all;

%%
% Analysis data and key file
anlDataFile = 'analysisData'; keyFile = 'keyFile';
%anlDataFile = 'analysisDataTF'; keyFile = 'keyFileTF';
%%
% Key data file

%% Load analysis data
load(anlDataFile);
nSamples = length(dataVec);

%% Load key file
load(keyFile);

%% Estimate SNR from data
tmpltVec = normsig4psd(sigVec,sampFreq,psdVec,1);
estSNR = innerprodpsd(dataVec,tmpltVec,sampFreq,psdVec);

%Run PSO
% Input parameters for QCPSO
timeVec = (0:(nSamples-1))/sampFreq;
nRuns = 8;
rmin = [40, 1, 1];
rmax = [100, 50, 15];
inParams = struct('dataX', timeVec,...
                  'dataY', dataVec,...
                  'dataXSq',timeVec.^2,...
                  'dataXCb',timeVec.^3,...
                  'sampFreq',sampFreq,...
                  'psd',psdVec,...
                  'rmin',rmin,...
                  'rmax',rmax);
% QCPSO runs PSO on the QCLRFUNC fitness function. As an
% illustration of usage, we change one of the PSO parameters from its
% default value.
outStruct = qcpso(inParams,struct('maxSteps',2000),nRuns);
% Plots: Not possible to put legends because of the estimates from all the
% runs. Will result in too many legends
figure;
%lgndStr = {};
hold on;
plot(timeVec,dataVec,'.');
%lgndStr = [lgndStr,'Data'];
for lpruns = 1:nRuns
    plot(timeVec,outStruct.allRunsOutput(lpruns).estSig,'Color',[51,255,153]/255,'LineWidth',4.0);
%     lgndStr = [lgndStr,'Runs'];
end
plot(timeVec,outStruct.bestSig,'Color',[76,153,0]/255,'LineWidth',2.0);
% lgndStr = [lgndStr,'Best'];
plot(timeVec,sigVec,'Color',[1,0,0],'LineWidth',2.0);
% lgndStr = [lgndStr,'True'];
% hlgnd = legend(lgndStr);
title(['Analysis data; Estimated SNR=', num2str(estSNR), '; PSO estimed SNR=']);
disp(['Estimated parameters: a1=',num2str(outStruct.bestQcCoefs(1)),...
                             '; a2=',num2str(outStruct.bestQcCoefs(2)),...
                             '; a3=',num2str(outStruct.bestQcCoefs(3))]);
