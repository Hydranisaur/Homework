% ==================== Lab 5-3: Serial Data Logging ==================== %
% This script connects to a Micro:bit via serial, reads sensor & speed data,
% It measures the LiDAR sensor 3 points (p1, p2, p3) and the wheel speed
% (vL, vR). 


% --- Adjust COM port to match your Micro:bit (check Device Manager / ls /dev/tty* on Mac/Linux)
% To list available ports in MATLAB, run:
% ports = serialportlist("available");

close all

port = "COM13";     
baud = 115200;     % default Micro:bit baudrate

% --- If a serial object 's' already exists, clear it
if exist("s","var")
    if isvalid(s)
        clear s
        pause(0.5)   % small delay so OS releases the port
    end
end

% --- Create serialport object
s = serialport(port, baud);

% --- Configure serial line terminator (Micro:bit sends "\n")
configureTerminator(s, "LF");

% --- Flush any existing data in the buffer
flush(s);

%% ==================== Initialize Arrays ==================== %%
N = 100;                        % Number of samples to read
data = zeros(N,5);               % Preallocate: [L1, M, L2, Speed_L, Speed_R]
timestamps = zeros(N,1);% Store timestamps
angles = zeros(N,1);
distances = zeros(N,1);
% ==================== Data Collection Loop ==================== %%
tic
for i = 1:N
    % Read most recent line from serial
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

    
    % Convert comma-separated string to numeric array
    nums = str2double(split(strtrim(line), ","));
    
    % nums format: [p1_distance, p2_distance, p3_distance, Speed_Left, Speed_Right]
    if length(nums) == 5
        data(i,:) = nums;
        t = toc;
        timestamps(i) = t;
    end
    
    [p1, p2, p3] = getPointCoord(nums(1:3)); % Get p1, p2, p3 coordinates in robot frame
    [theta_k, X_k] = getRobotAngleFromPoints(p1, p1, p3); % Compute theta

    angles(i,1) = theta_k;
    distances(i,1)= X_k;
    
    % Optional: Display received values with timestamp
    fprintf("[%s] laser distance (mm): ", string(t));
    disp(nums');
end

% --- Clean up serial object when done
clear s

%% ==================== Plot Data ==================== %%

% Figure 1: Line sensor data
figure;
subplot(3,1,1)
plot(data(:,1), 'r-', 'DisplayName','P1'); hold on;
plot(data(:,2), 'g-', 'DisplayName','P2');
plot(data(:,3), 'b-', 'DisplayName','P3');
xlabel("Sample Index"); ylabel("Laser Dist. (mm)");
title("LiDAR Measurement");
legend; grid on;

subplot(3,1,2)
plot(angles)
yline(pi/2, '--k')
xlabel("Sample Index"); ylabel("\theta (rad)");

subplot(3,1,3)
plot(distances)
xlabel("Sample Index"); ylabel("X_k (cm)");