function cVec = vcrossprod(aVec,bVec)
%Cross product of vectors
%C = VCROSSPROD(A,B)
% C = A X B
%If A and B are N-by-3 matrices, C is computed for each row of A and B.

%Soumya D. Mohanty, June 2018

[nVecs,~] =size(aVec); 
cVec = zeros(nVecs,3);
cVec(:,1) = aVec(:,2).*bVec(:,3) - aVec(:,3).*bVec(:,2);
cVec(:,2) = aVec(:,3).*bVec(:,1) - aVec(:,1).*bVec(:,3);
cVec(:,3) = aVec(:,1).*bVec(:,2) - aVec(:,2).*bVec(:,1);