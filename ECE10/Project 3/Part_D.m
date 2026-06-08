clear;
clc;
close all;

tspan = [0 20];

%IC's
v = 1;
u_t = 0.1;

xC0 = -5;
yC0 = 5;
theta0 = 0;

r0 = sqrt(xC0^2 + yC0^2);
phi0 = atan2(-yC0,-xC0) - theta0;
% Again, make sure its within -pi to pi
phi0 = atan2(sin(phi0), cos(phi0));

IC = [r0;phi0];

[t, sol] = ode45(@(t,y) odepolar(t, y, v, u_t), tspan, IC);

r = sol(:,1);
phi = sol(:,2);

% Make sure phi is within -pi to pi
phi = atan2(sin(phi), cos(phi));

figure;
plot(t, r, 'r');
grid on;
axis equal;
xlabel('Time (s)')
ylabel('Numeric r(t)');
title('Part D Numerically Solved r(t)')

figure;
plot(t, phi, 'black');
grid on;
xlabel('Time (s)');
ylabel('Numeric phi(t) in radians per second');
title('Numerically Solved phi(t)');

function dydt = odepolar(t,y,v,u_t)
r = y(1);
phi = y(2);

rDot = -v*cos(phi);
phiDot = (v/r)*sin(phi) - u_t;

dydt = [rDot; phiDot];
end