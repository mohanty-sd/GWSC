%% MDC with time-frequency analysis
% We will use the training data to estimate the noise PSD. Then, we will
% use the estimated PSD to design a whitening filter and whiten the
% analysis data. Time-frequency analysis will be applied to the whitened
% data.

%%
% File names.
trDataFile = 'TrainingDataTF';
anlDataFile = 'analysisDataTF.mat';

%% Estimate noise PSD from training data
% The estimated PSD will be smoothed.
load(trDataFile);
%%
% Estimate PSD (2Hz resolution).
[pxx,f]=pwelch(trainData,sampFreq/2,[],[],sampFreq);
semilogy(f,pxx);
%%
% Smooth the PSD estimate
smthOrdr = 10;
b = ones(1,smthOrdr)/smthOrdr;
pxxSmth = filtfilt(b,1,pxx);
hold on;
semilogy(f,pxxSmth);

%% Design whitening filter
whtB = fir2(100,f/(sampFreq/2),1./sqrt(pxxSmth));

%%
% Verify whitening. PSD of whitened data.
whtTrainData = fftfilt(whtB,trainData);
figure;
pwelch(whtTrainData, sampFreq/2, [], [], sampFreq);

%% Whiten the analysis data
load(anlDataFile);
whtAnalysisData = fftfilt(whtB,dataVec);

%% Spectrogram
% Choice of time windows.
winLen = [64, 128, 256, 512];
for lpw = 1:length(winLen)
    %Spectrogram with 75% overlap between windows
    [S,F,T]=spectrogram(whtAnalysisData, winLen(lpw), floor(0.75*winLen(lpw)), [], sampFreq);
    figure;
    imagesc(T,F,abs(S)); axis xy;
    xlabel('Frequency (Hz)');
    ylabel('Time (sec)');
    title(['Window length ',num2str(winLen(lpw))]);
end

%% Wigner-Ville distribution
[Swv,Fwv,Twv] = wvd(whtAnalysisData,sampFreq);
figure;
imagesc(Twv,Fwv,Swv); axis xy