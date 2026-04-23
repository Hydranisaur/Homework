clear; clc; close all;

%% =====================
%  Simulation Parameters
%  =====================
dt = 0.05;        % sampling interval (s)
T  = 8;          % total simulation time (s)
N  = round(T/dt); % number of steps

X_ref = 10;   % desired distance to the wall (cm)
Y_ref = 60;   % desired distance to the wall (cm)

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

% Define Your Controller
K_X = 0.5;      % wall distance proportional gain
K_d = 0.4;      % derivative gain
K_p = 10;       % wheel cruise control gain
K_theta = 0.5;  % orientation control gain
K_Y = 0.8;      % Y-distance proportional gain

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
    % First, compute errors (X first)
    eX = X(k) - X_ref;
    if k == 1
        eX_dot = 0;
    else
        eX_dot = (X(k) - X(k-1)) / dt;
    end

    % Now the Y error
    eY = Y_ref - Y(k);      % Flipped from X error because we want positive
    if k == 1               % error if we are too short in distance
        eY_dot = 0;
    else
        eY_dot = (Y(k) - Y(k-1)) / dt;
    end
    
    theta_Error = (pi/2) - theta(k);
    
    % Now for our controllers
    Omega_X = K_X * eX + K_d * eX_dot;

    Omega_theta = K_theta * theta_Error;
    
    % Add the two omegas together to get our control value
    Omega_control = Omega_X + Omega_theta;

    V_control = K_Y * eY;

    % Conversions
    v_R_des = V_control + (width/2) * Omega_control;
    v_L_des = V_control - (width/2) * Omega_control;

    % Comput motor control inputs
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
ylim([0, Y_ref*1.1]);

figure; 
subplot(4,1,1); 
plot(X, 'LineWidth',2);hold on;
plot(Y, 'LineWidth',2);
yline(X_ref, 'b--', 'LineWidth', 1)
yline(Y_ref, 'r--', 'LineWidth', 1)

ylabel('X, Y (cm)'); grid on;
legend('X','Y');
subplot(4,1,2); plot(Omega, 'LineWidth',2);
ylabel('\Omega rotational'); grid on;
subplot(4,1,3); plot(V_robot, 'LineWidth',2);
ylabel('V_{robot} (cm/s)'); grid on;


subplot(4,1,4); plot(v_R,'r','LineWidth',2); hold on;
plot(v_L,'b','LineWidth',2);
ylabel('v_{wheel} (cm/s)'); grid on;
legend('v_R','v_L');
xlabel('Time step k');


