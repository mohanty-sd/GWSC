function [sig,lensig] = newtchirp(nSamples, T0, chirptime, phi0, fs, varargin)
%[Y,L] = NEWTCHIRP(N,T0, CHIRPTIME, PHI0, Fs)
%N : number of samples in Y
%T0: Time of arrival (sec)
%CHIRPTIME: chirp time (sec)
%PHI0: Initial phase (degrees)
%Fs : Sampling frequency (Hz)
%
%Y is the signal vector and L is the length of the signal from T0 to the
%time when the signal terminates. Use L in doing correlations.
%
%[Y,L] = NEWTCHIRP(N,T0, CHIRPTIME, PHI0, Fa, Fc)
%can be used to override the default values of the lower and upper cutoff
%frequencies Fa (Hz) and Fc (Hz).


%Soumya D. Mohanty, Oct 2006
%Modified July 2011
%  added optional arguments
%  changed datalength input to number of samples
%Modified Aug 2015
%  Made it a stand alone function stored in the MATLABCODES/signals folder
%  Modernized the handling of optional input arguments

%Handle default values
fa = 40; %Hz; frequency at time of arrival
fc = 700; %Hz; cutoff frequency
nReqArgs = 5;
for lpargs = 1:(nargin-nReqArgs)
    switch lpargs
        case 1
            fa = varargin{lpargs};
        case 2
            fc = varargin{lpargs};
    end
end

datalength = (nSamples-1)/fs;

%Check that the time of arrival is
%within the data time range
if T0 < 0 || T0 > datalength
    error('Time of arrival does not lie within data duration');
end

%output storage
sig = zeros(1,nSamples);

%time samples
tstamps = (0:(nSamples-1))*(1/fs);

%Chirp end time
tc = chirptime*(1 - (fc/fa)^(-8/3));

%Tstamps for waveform
chirptindx = find(tstamps >= T0 & tstamps <= T0+tc);
%Length of the signal
lensig = length(chirptindx);

%amplitude 
a_t = zeros(size(sig));
a_t(chirptindx) = (1  - (tstamps(chirptindx) - T0)/chirptime).^(-1/4);

%Phase
phi_t = zeros(size(sig));
phi_t(chirptindx) = phi0*pi/180 + (8/5)*2*pi*fa*chirptime*(1 - (1 - (tstamps(chirptindx)-T0)/chirptime).^(5/8));

%generate sig
sig(chirptindx) = a_t(chirptindx).*cos(phi_t(chirptindx));

%Normalize: snr 1 in white noise
sig = sig/norm(sig);

