%% F_+ and F_x calculation
%Polar
theta = 0:0.05:pi;
%Azimuthal
phi = 0:.05:(2*pi);

[A,D] = meshgrid(phi,theta);
X = sin(D).*cos(A);
Y = sin(D).*sin(A);
Z = cos(D);

%Generate function values
fPlus = zeros(length(theta),length(phi));
fCross = zeros(length(theta),length(phi));
for lp1 = 1:length(phi)
    for lp2 = 1:length(theta)
        [fPlus(lp2,lp1),fCross(lp2,lp1)] = detframefpfc(theta(lp2),phi(lp1));
    end
end

%Plot
figure;
surf(X,Y,Z,abs(fPlus));
shading interp;
axis equal;
colorbar;
figure;
surf(X,Y,Z,abs(fCross));
shading interp;
axis equal;
colorbar;