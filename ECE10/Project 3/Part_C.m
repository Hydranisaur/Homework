clear;
clc;
close all;

tspan = [0 20];

%IC's
v = 1;
u_t = 0.1;

IC = [-5; 5; 0];

[t, sol] = ode45(@(t,y) odefun(t,y,v,u_t), tspan, IC);

xC = sol(:,1);
yC = sol(:,2);
theta = sol(:,3);

% Point P
r = sqrt(xC.^2 + yC.^2);

% Phi
phi = atan2(-yC,-xC) - theta;

% Make sure phi is within -pi to pi
phi = atan2(sin(phi), cos(phi));

figure;
plot(t, r, 'g');
grid on;
xlabel('Time (s)')
ylabel('Distance to point "P" (m)');
title('Distance From Robot Center to "P" Over Time')

figure;
plot(t, phi, 'bl');
grid on;
xlabel('Time (s)');
ylabel('Bearing Angle, relative to "P"');
title('Bearing Angle Over Time');

function dydt = odefun(t,y,v,u_t)
xC = y(1);
yC = y(2);
theta = y(3);

dxC = v*cos(theta);
dyC = v*sin(theta);
dtheta = u_t;

dydt = [dxC; dyC; dtheta];
end