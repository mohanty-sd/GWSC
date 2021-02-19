function [Phi, E, Sp1path, Sp2path, Sp3path, C_total, Spsup, Spinf, R] = simu_LISA_orbits()
%
% Author & support nicolas.douillet (at) free.fr, 2007-2020.


R = 15;       % *10^6 km (UA) = distance to the Sun
E = [R;0;0];  % initial Earth position = [x_T(1);y_T(1);z_T(1)]

% Initial position of the 3 LISA spacecrafts
Delta_phi = -pi/6;
L = 5; % inter-spacecraft distance = arms' length in relative unit

% Rotation matrix from (E,x,y,z) to (cdm,x,y,z)
Mr0 = [cos(Delta_phi),-sin(Delta_phi),0;
       sin(Delta_phi),cos(Delta_phi),0;
       0,0,1];

t = (1:360)'; % orbital Earth period
Omega = 2*pi/t(end);
Phi = 0:Omega:2*pi;

% circular path/trajectory modelling
% Earth 
x_E = R.*cos(Phi); % anti-clockwise rotation way
y_E = R.*sin(Phi);
z_E = zeros(1,length(x_E));
E = [x_E;
     y_E;
     z_E];

% Translation vector from (cdm,x-y-z) plan to  (S,x-y-z) plan
t_v = [R;0;0];

% Rotation matrix from LISA plan (cdm,1,2,3) to (cdm,x-y-z) plan
Mr2 = [cos(pi/3),0,-sin(pi/3);
       0,1,0;
       sin(pi/3),0,cos(pi/3)];
 
% Rotation matrix from one LISA spacecraft to its following neighbour
Mr3 = [cos(-2*pi/3),-sin(-2*pi/3),0;
       sin(-2*pi/3),cos(-2*pi/3),0;
       0,0,1];

% Initial spacecraft positions
Sp1 = [L/sqrt(3) % in (E,x,y,z) base % top
       0;
       0];     

% Spacecraft trajectories
for k = 1:length(E)
    Phi_k = Phi(1,k);
    
    % Rotation matrix for points belonging to LISA circle
    Mr5 = [cos(Phi_k),-sin(Phi_k),0
        sin(Phi_k),cos(Phi_k),0
        0,0,1];
    
    % Rotation matrix of LISA triangle during one period
    Mr6 = Mr5.*[1,-1,1;-1,1,1;1,1,1];
    Sp1path(:,k) = Mr0*(E(:,k)+Mr5*Mr2*Mr6*Sp1);
end

Sp2path = Mr3\Sp1path;
Sp3path = Mr3*Sp1path;

% Taking a common origin
Sp2path = [Sp2path(:,2*length(Sp2path)/3+1:end) Sp2path(:,1:2*length(Sp2path)/3)];
Sp3path = [Sp3path(:,length(Sp3path)/3+1:end) Sp3path(:,1:length(Sp3path)/3)];

% Connecting points (resizing normal)
Phi = [Phi 2*pi];

Sp1path = [Sp1path Sp1path(:,1)];
Sp2path = [Sp2path Sp2path(:,1)];
Sp3path = [Sp3path Sp3path(:,1)];

E = [E E(:,1)];

x_E = E(1,:);
y_E = E(2,:);
z_E = E(3,:);

% LISA circle
C = zeros(3,length(Phi));

for k = 1:length(Phi)
    
    Phi_k = Phi(1,k);
    
    % Rotation matrix for points belonging to LISA circle
    Mr5 = [cos(Phi_k),-sin(Phi_k),0
           sin(Phi_k),cos(Phi_k),0
           0,0,1];
       
    % Rotation matrix of LISA triangle during one period
    Mr6 = Mr5.*[1,-1,1;-1,1,1;1,1,1];
    C(:,k) = Mr0*(t_v+Mr2*Mr6*Sp1);
    
end

C_total = zeros(3,length(Phi),length(Phi));
C_total(:,:,1) = C(:,:); % initial circle

for n = 2:length(Phi)
    
    Phi_n = Phi(1,n);
    
    % Rotation matrix for points belonging to LISA circle
    Mr5 = [cos(Phi_n),-sin(Phi_n),0
           sin(Phi_n),cos(Phi_n),0
           0,0,1];
       
    C_total(:,:,n) = Mr5*C_total(:,:,1);
    
end

% Spinf & Spsup circle; LISA orbit path limits
x_Spsup = x_E+(L*cos(pi/3)/sqrt(3))*cos(Phi);
y_Spsup = y_E+(L*cos(pi/3)/sqrt(3))*sin(Phi);
z_Spsup = z_E+L*sin(pi/3)/sqrt(3);
Spsup = [x_Spsup;y_Spsup;z_Spsup];
Spsup = Mr0*Spsup;

x_Spinf = x_E-(L*cos(pi/3)/sqrt(3))*cos(Phi);
y_Spinf = y_E-(L*cos(pi/3)/sqrt(3))*sin(Phi);
z_Spinf = z_E-L*sin(pi/3)/sqrt(3);
Spinf = [x_Spinf;y_Spinf;z_Spinf];
Spinf = Mr0*Spinf;


end