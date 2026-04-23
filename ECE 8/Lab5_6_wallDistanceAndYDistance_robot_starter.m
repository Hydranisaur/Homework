%% Lab: Wall-Distance and Y distance code for Robot

% This script connects to a Micro:bit via serial, reads sensor & speed data,
% It measures the LiDAR sensor 3 points (p1, p2, p3) and the wheel speed
% (vL, vR). 
% We send:
%   "PWM_L,PWM_R"

% --- Adjust COM port to match your Micro:bit (check Device Manager / ls /dev/tty* on Mac/Linux)
% To list available ports in MATLAB, run:
% ports = serialportlist("available");


clear; clc; close all;

%% ==================== USER SETTINGS ====================
port = "COM14";    % Adjust the port number
baud = 115200;

%% =====================
%  Problem Parameters
%  =====================

dt = 0.05;        % sampling interval (s)
T  = 8;          % total simulation time (s)
N  = round(T/dt); % number of steps

X_ref = 10;   % desired distance to the wall (cm)
Y_ref = 60;   % desired distance forward (in Y) (cm)

%  Robot Physical Parameters
width = 9;      % wheel separation (cm)


u_min = 0;
u_max = 255;       % keep under 255 to be safe for Maqueen


%% ====== TODO ===============
% Change the values that are given in this section.

% Update System ID Motor Model 
a = 0.83392;
b = 0.02700;
d = -0.42788;

K_X = 1.3;      % wall distance proportional gain
K_d = 0.5;      % derivative gain
K_p = 8;        % wheel cruise control gain
K_theta = 0.2;  % Orientation/Angle correction gain
K_Y = 1;      % Y distance control gain

u_star = -d/b;  % Since we want Veq to be 0
alpha = 0.3;

%% ==================== SERIAL SETUP ====================
if exist("s","var")
    if isvalid(s)
        clear s
        pause(0.5)
    end
end
s = serialport(port, baud);
configureTerminator(s, "LF");
flush(s);

stopStr   = sprintf("%d,%d", 0, 0);
cleanupObj = onCleanup(@() safeClose(s, stopStr));

%% ==================== DATA STORAGE ====================
data        = nan(N,5);    % [p1, p2, p3, Speed_L, Speed_R]
timestamps  = zeros(N,1);

X   = zeros(N,1);     % wall distance
Y   = zeros(N,1);     % Y, forward distance. 
theta = zeros(N,1); % measured robot heading

Omega  = zeros(N,1);    % robot actual rotational speed
V_robot= zeros(N,1);    % robot actual forward speed 

U_L_cmd = zeros(N,1);      % Motor left command
U_R_cmd = zeros(N,1);      % Motor right command

vL_meas_hist = zeros(N,1);   % left wheel speed measures
vR_meas_hist = zeros(N,1);   % right wheel speed measures

%% ==================== CONTROL LOOP =====================

tic;
lastToc = -1;
for k = 1:N
    dt_real = toc-lastToc; % You may use this measured dt 
    lastToc = toc;
    
    %% --- Read latest line from Micro:bit ---
    lastLine = "";
    while s.NumBytesAvailable < 1
        % wait for data
    end
    if s.NumBytesAvailable > 0
        while s.NumBytesAvailable > 0
            lastLine = readline(s);   % keep the last complete line
        end
    end
    line = lastLine;

    nums = str2double(split(strtrim(line), ","));
    t = toc;
    timestamps(k) = t;

    if numel(nums) == 5 && all(~isnan(nums))
        data(k,:) = nums;
        LiDAR_meas = nums(1:3);
        vL_meas = nums(4);
        vR_meas = nums(5);
    else
        warning("Malformed line %d: %s", k, line);
        continue;
    end
    
    vL_meas_hist(k) = vL_meas;
    vR_meas_hist(k) = vR_meas;

    V_robot(k)    = 1/2*(vL_meas + vR_meas);
    Omega(k)      = (vR_meas-vL_meas)/width;

    %% --- Compute wall distance & derivative ---
    % TODO: 
    [p1, p2, p3] = getPointCoord(LiDAR_meas);
    [theta_k, X_k] = getRobotAngleFromPoints(p1, p2, p3);

    theta(k) = theta_k;
    X(k) = X_k;

    %% ================ TODO ========================
    %Update the command to to each wheel using your controller.     
    uR_cmd_k = 0; % Current Right Motor cmd
    uL_cmd_k = 0; % Current Left Motor cmd

    if k ==1
        X_filt_prev = X_k;
        Omega_prev = 0;
        Y(1) = 0;
        theta_odo = theta_k;
    end

    X_filt = 0.7 * X_k + 0.3 * X_filt_prev;

    % Error computation
    eX = X_filt - X_ref;
    if k == 1
        eX_dot = 0;
    else
        eX_dot = (X_filt - X_filt_prev) / dt;
    end

    % Compute forward motion
    V_robot_now = 0.5*(vL_meas + vR_meas);
    Omega_now   = (vR_meas - vL_meas) / width;
    
    % Forward integrate Y position
    if k > 1
        % Update the odometer heading
        theta_odo = theta_odo + dt * Omega_now;
        %Integrate forward distance in the Y direction
        Y(k) = Y(k-1) + 1.2 * dt * V_robot_now * sin(theta_odo);
    else
        Y(k) = 0;
    end

    % Compute Y_k error (total Y distance)
    eY = Y_ref - Y(k);

    V_control = K_Y * eY;

    % Clamp velocity output
    V_control = max(min(V_control, 12), -12);

    % Now for wall-following control (same as Problem 5)
    Omega_raw = K_X * eX + K_d * eX_dot - K_theta * theta_k;
    
    % Clamp Omega values:
    Omega_control = alpha * Omega_raw + (1-alpha) * Omega_prev;
    Omega_control = max(min(Omega_control, 0.8), -0.8);

    % Convert control inputs to the desired wheel speeds
    v_R_des = V_control + (width/2) * Omega_control;
    v_L_des = V_control - (width/2) * Omega_control;

    % Compute motor control inputs
    uR_cmd_k = K_p * (v_R_des - vR_meas) + u_star;
    uL_cmd_k = K_p * (v_L_des - vL_meas) + u_star;

    % Clamp inputs to u_min and u_max
    uR_cmd_k = min(max(round(uR_cmd_k), u_min), u_max);
    uL_cmd_k = min(max(round(uL_cmd_k), u_min), u_max);
    
    % Store for next iteration
    Omega_prev = Omega_control;
    X_filt_prev = X_filt;

    %% --- Send command to both wheels ---
    outStr = sprintf("%d,%d", uL_cmd_k, uR_cmd_k);
    writeline(s, outStr);

    U_R_cmd(k) = uR_cmd_k;
    U_L_cmd(k) = uL_cmd_k;


    %% --- Console log (brief) ---
    fprintf('[%5.2f s] dist=%.2f  vL=%.1f vR=%.1f  -> uL=%d uR=%d\n', ...
            t, X_k, vL_meas, vR_meas, uL_cmd_k, uR_cmd_k);

    pause(dt);
end

% --- Stop motors at the end ---
writeline(s, stopStr);

%% ==================== PLOTS ============================
t = timestamps - timestamps(1);

figure('Color','w');

subplot(4,1,1);
plot(t, X(1:N), 'b.-'); hold on;
plot(t, Y(1:N), 'r.-');
yline(X_ref, 'b--', 'X_{ref}');
yline(Y_ref, 'r--', 'Y_{ref}');
xlabel('Time (s)'); ylabel('X,Y (cm)');
grid on;

subplot(4,1,2);
plot(t, theta, 'm.-');
hold on; 
yline(pi/2, 'm--');
xlabel('Time (s)'); ylabel('\theta (rad)');
grid on;

subplot(4,1,3);
plot(t, Omega, 'm.-');
xlabel('Time (s)'); ylabel('\Omega_{robot} (rad/s )');
grid on;

subplot(4,1,4);
plot(t, vL_meas_hist, 'b.-' ); hold on;
plot(t, vR_meas_hist, 'r.-');
legend('v_L', 'v_R')
xlabel('Time (s)'); ylabel('v_{L,R} (cm/s)');
grid on;


%% ==================== LOCAL FUNCTION ====================
function safeClose(s, stopStr)
    try
        if ~isempty(s) && isvalid(s)
            writeline(s, stopStr);
        end
    catch
    end
    try, clear s; catch, end
end
