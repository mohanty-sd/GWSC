function [fitVal,varargout] = qclrfunc(xVec,params)
%Fitness function for quadratic chirp regression in colored Gaussian noise
%F = QCLRFUNC(X,P) Compute the fitness function (Log-likelihood ratio
%maximized over amplitude) for data containing the quadratic chirp signal.
%X is an M-by-3 matrix containing the location of points in the quadratic
%chirp parameter space (a1, a2, and a3). The fitness values
%corresponding to the locations in X are returned in F.
%
%X is standardized, that is 0<=X(i,j)<=1. The fields P.rmin and P.rmax  are
%used to convert X(i,j) internally before computing the fitness: 
%X(:,j) -> X(:,j)*(rmax(j)-rmin(j))+rmin(j).
%
%The fields P.dataY and P.dataX are used to transport the data and its time
%stamps. The fields P.dataXSq and P.dataXCb contain the timestamps squared
%and cubed respectively.  The field P.psd contains the noise PSD values at
%positive DFT frequencies. The field P.sampFreq contains the sampling
%frequency.
%
%[F,R] = QCLRFUNC(X,P)
%returns the quadratic chirp coefficients corresponding to the rows of X in R. 
%
%[F,R,S] = QCLRFUNC(X,P)
%Returns the quadratic chirp signals corresponding to the rows of X in S.

%Soumya D. Mohanty
%June, 2011
%April 2012: Modified to switch between standardized and real coordinates.

%Shihan Weerathunga
%April 2012: Modified to add the function rastrigin.

%Soumya D. Mohanty
%May 2018: Adapted from rastrigin function.

%Soumya D. Mohanty
%Mar 2019: Adapted from CRCBQCFITFUNC

%Soumya D. Mohanty
%Adapted from QUADCHIRPFITFUNC
%==========================================================================

%rows: points
%columns: coordinates of a point
[nVecs,~]=size(xVec);

%storage for fitness values
fitVal = zeros(nVecs,1);

%Check for out of bound coordinates and flag them
validPts = crcbchkstdsrchrng(xVec);
%Set fitness for invalid points to infty
fitVal(~validPts)=inf;
xVec(validPts,:) = s2rv(xVec(validPts,:),params);

for lpc = 1:nVecs
    if validPts(lpc)
    % Only the body of this block should be replaced for different fitness
    % functions
        x = xVec(lpc,:);
        fitVal(lpc) = ssrqc(x, params);
    end
end

%Return real coordinates if requested
if nargout > 1
    varargout{1}=xVec;
end

%Sum of squared residuals after maximizing over amplitude parameter
function ssrVal = ssrqc(x,params)
%Generate normalized quadratic chirp: We do not use the signal generating
%function CRCBGENQCSIG because it would compute t^2 and t^3 for every call,
%making the whole code slower
phaseVec = x(1)*params.dataX + x(2)*params.dataXSq + x(3)*params.dataXCb;
qc = sin(2*pi*phaseVec);
[qc,~]=normsig4psd(qc,params.sampFreq,params.psd,1);

%Compute fitness
inPrd = innerprodpsd(params.dataY,qc,params.sampFreq,params.psd);
ssrVal = -(inPrd)^2;