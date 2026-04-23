% ==================== Lab 3-1: Serial Data Logging ==================== %
% This script connects to a Micro:bit via serial, reads sensor & speed data,
% saves them into arrays, and then plots the results.

% --- Adjust COM port to match your Micro:bit (check Device Manager / ls /dev/tty* on Mac/Linux)
% To list available ports in MATLAB, run:
% ports = serialportlist("available");
close all
clc

port = "COM9";     
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

% ==================== Initialize Arrays ==================== %
N = 100;                         % Number of samples to read

%% TODO: Preallocate array to store [L1, M, R1, Speed_L, Speed_R] and timestamp array
lineData = zeros(N, 3);
speedData = zeros(N, 2);
timestamp = zeros(N, 1);

%================ YOUR INPUT ENDS ===============

% ==================== Data Collection Loop ==================== %
tic; % Initialize the timer to zero
for i = 1:N
    % Read one line from serial
    line = readline(s);
    
    % Convert comma-separated string to numeric array
    nums = str2double(split(strtrim(line), ","));
    
    % nums format: [L1, M, R1, Speed_Left, Speed_Right]
    if length(nums) == 5
        t = toc; %Time from 'tic' command in seconds. 

        %% TODO: Save nums and timestamp into array
    L1 = nums(1);
    M = nums(2);
    R1 = nums(3);
    sL = nums(4);
    sR = nums(5);
    timestamp(i) = t;
    lineData(i, :) = [L1, M, R1];
    speedData(i, :) = [sL, sR];
        %================ YOUR INPUT ENDS ===============

        % Optional: Display received values with timestamp
        fprintf("[%f] Received: ", t);
        disp(nums');
    end
    

end

% --- Clean up serial object when done
clear s

%% ==================== Plot Data ==================== %%
%% TODO: Plot L1, M, R1 with legend and labels
% Figure 1: Line sensor data
figure(1)
plot(timestamp, lineData, 'LineWidth', 2)
xlabel("Time From Start")
ylabel("Line Sensor Data")
title("Line Data (Part 1)")
legend({"L1", "M", "R1"})
grid

%================ YOUR INPUT ENDS ===============

%% TODO: Plot Left and Right wheel speeds with legend and labels
% Figure 2: Wheel speeds
figure(2)
plot(timestamp, speedData, 'LineWidth', 2)
xlabel("Time From Start")
ylabel("Speed Sensor Data")
title("Speed Data (Part 1)")
legend({"Left Wheel", "Right Wheel"})
grid
% The indexing above for putting nums into my lineData and speedData took a
% minute to figure out, but once I got it the plotting was straightforward
% and the data looks good. It makes sense, but the graph shows the binary
% output of the line sensors quite well, with no transition between the 0
% or 1 return values. The speed sensors on the other hand are still a bit
% blocky, but definitely showed more of what I expected in regards to
% ramping up and down when I was pushing it along.

%================ YOUR INPUT ENDS ===============