%% Test noise generation code
nSamples = 204800;
sampFreq = 2048;
[noiseVec,psdVec] = gengwnoise(nSamples,300,sampFreq,40,700,'iLigo');

kNyq = floor(nSamples/2)+1;
posFreq = (0:(kNyq-1))*sampFreq/nSamples;

figure;
semilogy(posFreq,psdVec);
hold on;
[pxx,f] = pwelch(noiseVec,512,[],[],sampFreq);
%Convert from one-sided PSD returned by pwelch to 2-sided
semilogy(f,pxx/2);
 xlabel('Frequency (Hz)');
 ylabel('Power Spectral Density (1/Hz)');
 
 figure;
 timeVec = (0:(nSamples-1))*(1/sampFreq);
 plot(timeVec,noiseVec);