%% Lab: Simple Cruise Control using P Controller (Maqueen Robot)
% Controller: u = u0 + Kp * (Vd - currentSpeed)
% - includes dead-zone compensation (u0)
% - uses your serial I/O format:  "L,R"  ↔  [L1, M, L2, Speed_L, Speed_R]

clear; clc;

%% ==================== USER SETTINGS ====================
port = "COM9";   %<-- Adjust this
baud = 115200;

dt = 0.05;         % control update period (s)
N = 100;          % number of control iterations (~2.5 s run?)

u_min = 0;      % Min Max value of the input
u_max = 200;

%% ==================== TODO Controller SETTINGS ====================
Xd = 100; %Desired location in (cm)

Kp_pos = 5;             % proportional gain for position
Kp_speed = 10;          % speed gain
distance_gain = 1.08;   % Small correction for real world positon
U0 = 15.8;              % dead zone compensation
Vd = 0;
pos = 0;

useCompensation = true;
surface = "uphill";

switch surface
    case "flat"    % Different parameters for different surfaces
        a = 0.794895;  b = 0.033255;  d = 0.5406375;
    case "uphill"
        a = 0.80813;   b = 0.03182;   d = -1.29309;
    case "downhill"
        a = 0.800585;  b = 0.03264;   d = -0.13414;
end

speedData = zeros(N,2);
pos_log = zeros(N,1);
v_log = zeros(N,1); 
U_log = zeros(N,1);

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
fprintf('Starting cruise control: Vd=%.1f cm/s, Kp=%.2f\n', Vd, Kp_pos);
pause(3)
tic;
loopTime=0;

for k = 1:N
    loopTime = toc;
    tic;

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

    pos = pos + (distance_gain * v_curr * loopTime);
    e_pos = Xd - pos;
    
    V = Kp_pos * e_pos;        % Take the error and multiply by Kp for position
    V = max(min(V, 25), -25); % Limit V to 25 (or -25)

    if (useCompensation == true)
        Ustar = ((1-a)*V - d) / b;
    else
        Ustar = U0;
    end

    U = Ustar + Kp_speed * (V - v_curr);
    % Get the last speed value and adjust the current input accordingly

    U = min(max(U, u_min), u_max);
    % Clamps U to either u_min or u_max if the value is too low/high

    outStr = sprintf("%d,%d", round(U), round(U));  % Rounded to whole number inputs
    writeline(s, outStr);

    if abs(e_pos) < 2
        break
    end
    pause(dt);

    pos_log(k) = pos;
    v_log(k) = v_curr;
    U_log(k) = U;
end

% --- Stop motors
writeline(s, stopStr);

%% ==================== TODO -- PLOTS ============================
% In one figure
% In one subplot, Plot measured velocity with the reference desired
% velocity as a dashed line
% In the other subplot, plot input of each timestep
t = (0:length(pos_log)-1)*dt;
figure('Color','w');
tiledlayout(3,1);
nexttile; plot(t,pos_log); yline(Xd,'r--'); ylabel('Position (cm)');
nexttile; plot(t,v_log); ylabel('Speed (cm/s)');
nexttile; plot(t,U_log); ylabel('PWM'); xlabel('Time (s)');
sgtitle('Part 5 – Travel Distance Control');


