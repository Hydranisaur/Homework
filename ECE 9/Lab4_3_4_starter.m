%% Lab: Simple Cruise Control using P Controller (Maqueen Robot)
% Controller: u = u0 + Kp * (Vd - currentSpeed)
% - includes dead-zone compensation (u0)
% - uses your serial I/O format:  "L,R"  ↔  [L1, M, L2, Speed_L, Speed_R]

clear; clc;

%% ==================== USER SETTINGS ====================
port = "COM13";   %<-- Adjust this
baud = 115200;

dt = 0.15;         % control update period (s)
N = 50;          % number of control iterations (~20 s run)

u_min = 0;      % Min Max value of the input
u_max = 200;

%% ==================== TODO Controller SETTINGS ====================
% Change the following values for the testing


Vd = 25;          % desired speed (cm/s)
Kp = 15;         % proportional gain 
U0 = 15.8;      % Dead zone compensation

useCompensation = true;
surface = "flat";

switch surface
    case "flat"    % Different parameters for different surfaces
        a = 0.68073;   b = 0.05334;   d = -0.89377;
    case "uphill"
        a = 0.80813;   b = 0.03182;   d = -1.29309;
    case "downhill"
        a = 0.800585;  b = 0.03264;   d = -0.13414;
end

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

stopStr = sprintf("%d,%d", 0, 0);
writeline(s, stopStr);


%% ==================== TODO -- CONTROL LOOP =====================
fprintf('Starting cruise control: Vd=%.1f cm/s, Kp=%.2f\n', Vd, Kp);
speedData = zeros(N, 2);
%Your code
% Controller: u = u0 + Kp * (Vd - currentSpeed)
for k = 1:N
    % Read line
    lastLine = "";
    while(s.NumBytesAvailable<1)
    end
    if s.NumBytesAvailable > 0
        while s.NumBytesAvailable > 0
            % Read one line at a time
            lastLine = readline(s);
        end
    end
    
    nums = str2double(split(strtrim(lastLine), ","));

    if numel(nums) >= 5 && all(~isnan(nums(4:5)))
        speedData(k,:) = [nums(4), nums(5)];% As long as nums has some 5 pieces of data in it,
    else                                    % read it into speedData
        % Handle a bad read by copying the last good one
        if k > 1
            speedData(k,:) = speedData(k-1,:);
        else
            speedData(k,:) = [0 0];
        end
    end
    
    if k == 1
        v_curr = 0;  % assume starting speed is 0
    else
        v_curr = mean(speedData(k,:), 'omitnan');  % average of L and R speeds
    end
    
    if (useCompensation == true)
        Ustar = ((1-a)*Vd - d) / b;
    else
        Ustar = U0;
    end

    % Works with compensation term for part 4 or dead zone compensation for
    % part 3
    U = Ustar + Kp * (Vd - v_curr);
    % Get the last speed value and adjust the current input accordingly

    U = min(max(U, u_min), u_max);
    % Clamps U to either u_min or u_max if the value is too low/high

    outStr = sprintf("%d,%d", round(U), round(U));  % Rounded to whole number inputs
    writeline(s, outStr);

    pause(dt);
end

% --- Stop motors
writeline(s, stopStr);

%% ==================== TODO -- PLOTS ============================
% In one figure
% In one subplot, Plot measured velocity with the reference desired
% velocity as a dashed line
% In the other subplot, plot input of each timestep
%% ==================== TODO -- PLOTS ============================

% Compute mean velocity (average of both wheels)
v_mean = mean(speedData, 2);

% Create time vector for x-axis
t = (0:N-1) * dt;

% Open a figure with two stacked plots
figure('Color','w');
tiledlayout(2,1,'Padding','compact','TileSpacing','compact');

% --- Plot 1: Velocity tracking
nexttile;
plot(t, v_mean, 'b', 'LineWidth', 1.5); hold on;
yline(Vd, 'r--', 'LineWidth', 1.2, 'DisplayName', 'Desired speed');
xlabel('Time (s)');
ylabel('Speed (cm/s)');
title('Measured vs Desired Speed');
legend('Measured','Desired','Location','best');
grid on;

% --- Plot 2: Control input over time
nexttile;
plot(t, min(max(U0 + Kp*(Vd - v_mean), u_min), u_max), 'k', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Motor Command (PWM)');
title('Control Input (u)');
grid on;

sgtitle('Part 3: Cruise Control with P Controller | Kp = 5, Vd = 10');



