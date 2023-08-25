%% Test harness for FORMULAFP and SKYPLOT
%Azimuthal angle
phiVec = 0:0.01:(2*pi);
%Polar angle
thetaVec = 0:0.1:pi;

%Function handle: F+ from formula
fp = @(x,y) formulafp(x,y);

skyplot(phiVec,thetaVec,fp);
axis equal;

%Add detector arms
line([0;1.2],[0;0],[0;0],'Color',[1,0,0]); %X arm
line([0;0],[1.2;0],[0;0],'Color',[0,1,0]); %Y arm
