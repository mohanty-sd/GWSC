function[] = LISA_animation()
% LISA orbitography animation
%
% Author & support nicolas.douillet (at) free.fr, 2007-2020.


[Phi, E, Sp1path, Sp2path, Sp3path, C_total, Spsup, Spinf,R] = simu_LISA_orbits();

% Computational parameters
step = 5;

% Display parameters
time_lapse = 0.1;
title_text = 'Orbitography of space interferometer project LISA, following Earth in the solar system';
filename = 'LISA_orbitography.gif';
az = -75;
el = 20;

% Display settings
h = figure;
set(h,'Position',get(0,'ScreenSize'));
set(gcf,'Color',[0 0 0]);
axis tight manual;
orbit_bounds = false;
LISA_relative_circular_orbit = false;


for k = 1:step:length(Phi)        
    
    plot3(E(1,:),E(2,:),E(3,:),'Color',[0 0 1],'Linewidth',3), hold on;

    plot3(Sp1path(1,:),Sp1path(2,:),Sp1path(3,:),'Color',[1 1 0],'Linewidth',2), hold on;
    plot3(Sp2path(1,:),Sp2path(2,:),Sp2path(3,:),'Color',[1 0 1],'Linewidth',2), hold on;
    plot3(Sp3path(1,:),Sp3path(2,:),Sp3path(3,:),'Color',[0 1 1],'Linewidth',2), hold on;
    
    if orbit_bounds
        plot3(Spinf(1,:),Spinf(2,:),Spinf(3,:),'Color',[0 1 0]), hold on;
        plot3(Spsup(1,:),Spsup(2,:),Spsup(3,:),'Color',[0 1 0]), hold on;
    end

    plot3(Sp1path(1,k),Sp1path(2,k),Sp1path(3,k),'o','Color',[1 1 0],'Linewidth',3), hold on;
    plot3(Sp2path(1,k),Sp2path(2,k),Sp2path(3,k),'o','Color',[1 0 1],'Linewidth',3), hold on;
    plot3(Sp3path(1,k),Sp3path(2,k),Sp3path(3,k),'o','Color',[0 1 1],'Linewidth',3), hold on;

    Spcft = [Sp1path(1,k) Sp2path(1,k) Sp3path(1,k) Sp1path(1,k);
             Sp1path(2,k) Sp2path(2,k) Sp3path(2,k) Sp1path(2,k);
             Sp1path(3,k) Sp2path(3,k) Sp3path(3,k) Sp1path(3,k)];
    
    plot3(Spcft(1,:),Spcft(2,:),Spcft(3,:),'Color',[1 0 0],'Linewidth',3), hold on;    
    
    if LISA_relative_circular_orbit
        plot3(C_total(1,:,k),C_total(2,:,k),C_total(3,:,k),'Color',[1 1 1]), hold on;
    end
    
    plot3(E(1,k),E(2,k),E(3,k),'o','Color',[0 0 1],'Linewidth',12), hold on;
    plot3(0,0,0,'o','Color',[1 1 0],'Linewidth',28), hold on;   
        
    axis([-(4*R/3) (4*R/3) -(4*R/3) (4*R/3) -(R/3) (R/3)]);
    axis square, axis equal, axis off;
    grid off;
    
    title(title_text,'FontSize',16,'Color',[1 1 1]), hold on;
    view(az,el);
    
    drawnow;
    
    frame = getframe(h);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    
    % Write to the .gif file
    if k == 1
        imwrite(imind,cm,filename,'gif', 'Loopcount',Inf,'DelayTime',time_lapse);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',time_lapse);
    end
    
    clf(h);
    
end


end