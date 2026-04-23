clear; clc; close all;

%% ===== TODO =============
% Build your own simulator
%% Lab 5 – Problem 1: Cruise Control Simulator

%% ====================== PARAMETERS ======================
v_ref = 20;    % Vd
Kp = 35;        % Controller gain
N = 150;       % Number of time steps
dt = 0.15;     % OR 0.15 depending on the test

switch dt
    case 0.05    % Different parameters for different dt values
        a = 0.83392;   b = 0.02700;   d = -0.42788;
    case 0.15
        a = 0.68073;   b = 0.05334;   d = -0.89377;
end

% Find u*
u_star = -d/b;

%% ====================== SIMULATION DATA ======================
v = zeros(N,1);     % Velocity data
u = zeros(N,1);     % Motor input data

v(1) = 0;           % Initial velocity is 0

%% ========================= MAIN LOOP =========================
for k = 1:N-1
    % Input calculation for each time step, to use for velocity
    u(k) = Kp*(v_ref - v(k)) + u_star;

    % Velocity dynamics
    v(k+1) = a*v(k) + b*u(k) + d;
end

%% ====================== PLOTS ================================
figure;
subplot(2,1,1);
plot(v,'LineWidth',2);
yline(v_ref,'r--');
title('Velocity Response');
xlabel('Time step');
ylabel('v_k');

subplot(2,1,2);
plot(u,'LineWidth',2);
title('Control Input u_k');
xlabel('Time step');
ylabel('PWM');

sgtitle('Velocity and Control Inputs at Kp = 35')
