clear; clc; close all;

%% =====================
%  Simulation Parameters
%  =====================
dt = 0.05;        % sampling interval (s)
T  = 10;          % total simulation time (s)
N  = round(T/dt); % number of steps

V_desired = 10;   % desired robot forward speed (cm/s)
X_ref = 10;   % desired distance to the wall (cm)

%  Robot Physical Parameters
width = 9;      % wheel separation (cm)

% Robot initial values
X_0 = 5; % intiial distance in cm
theta_0 = pi/4; % initial robot angle

%% ====== TODO ===============
% Change the values that are given in this section.

% Update System ID Motor Model 
a = 0.83392;
b = 0.02700;
d = -0.42788;

% Find the Controller gains that works.
K_X = 1.2;   % distance proportional gain
K_d = 0.8;   % derivative gain
K_p = 10;     % wheel cruise control gain

u_star = -d/b;

%% =====================
% Storage variables
% =====================
X = zeros(1,N);    % robot x-position
Y = zeros(1,N);    % robot y-position
theta = zeros(1,N);   % robot heading

X(1) = X_0;
theta(1) = theta_0;

v_R = zeros(1,N);   % wheel speed right
v_L = zeros(1,N);   % wheel speed left

DutyR  = zeros(1,N);   % duty commands
DutyL  = zeros(1,N);

Omega = zeros(1,N);
V_robot = zeros(1,N);



%% =====================
% Simulation loop
% =====================
for k = 1:N-1
    %% ========= TODO ============
    % First, compute error
    eX = X(k) - X_ref;
    if k == 1
        eX_dot = 0;
    else
        eX_dot = (X(k) - X(k-1)) / dt;
    end

    % Now for wall-following control
    V_control = V_desired;
    Omega_control = K_X * eX + K_d * eX_dot;

    % Convert control inputs to the desired wheel speeds
    v_R_des = V_control + (width/2) * Omega_control;
    v_L_des = V_control - (width/2) * Omega_control;

    % Compute motor control inputs
    DutyR(k) = K_p * (v_R_des - v_R(k)) + u_star;
    DutyL(k) = K_p * (v_L_des - v_L(k)) + u_star;
    
    % Motor ARX-like dynamics
    v_R(k+1) = a * v_R(k) + b * DutyR(k) + d;
    v_L(k+1) = a * v_L(k) + b * DutyL(k) + d;

    % Convert wheels speeds to the actual robot velocity
    V_robot(k) = 0.5 * (v_R(k) + v_L(k));
    Omega(k) = (v_R(k) - v_L(k)) / width;

    % Finally, update the robot position using our forward Euler discrete
    % time equations
    X(k+1) = X(k) + dt * V_robot(k) * cos(theta(k));
    Y(k+1) = Y(k) + dt * V_robot(k) * sin(theta(k));
    % We need to update theta every iteration as well
    theta(k+1) = theta(k) + dt * Omega(k);
end

%% =====================
% Plot Results
% =====================

figure; hold on; grid on;
plot(X, Y, 'b', 'LineWidth', 2);
xline(0, 'k', 'LineWidth', 2) % the wall at x=0
xline(X_ref, 'k--', 'LineWidth', 2)
xlabel('X (cm)'); ylabel('Y (cm)');
title('Wall Following Robot Trajectory');
legend('Robot path','Wall');
axis equal

figure; 
subplot(4,1,1); plot(X, 'LineWidth',2);
ylabel('X (cm)'); grid on;
hold on;
yline(X_ref, 'k--', 'LineWidth', 1)
subplot(4,1,2); plot(Omega, 'LineWidth',2);
ylabel('\Omega rotational'); grid on;
subplot(4,1,3); plot(V_robot, 'LineWidth',2);
ylabel('V_{robot} (cm/s)'); grid on;


subplot(4,1,4); plot(v_R,'r','LineWidth',2); hold on;
plot(v_L,'b','LineWidth',2);
ylabel('v_{wheel} (cm/s)'); grid on;
legend('v_R','v_L');
xlabel('Time step k');

