% ==================== Lab 3-2: Serial Data Sending ==================== %
% This script sends two numbers to the Micro:bit as a comma-separated line.
clear
close all

% --- Adjust COM port to match your Micro:bit (check Device Manager / ls /dev/tty* on Mac/Linux)
% To list available ports in MATLAB, run:
% ports = serialportlist("available");
port = "COM14";     
baud = 115200;

% --- If a serial object 's' already exists, clear it
if exist("s","var")
    if isvalid(s)
        clear s
        pause(0.5)
    end
end

% --- Create serialport object
s = serialport(port, baud);
configureTerminator(s, "LF");  % Micro:bit expects newline

%% TODO change each motor input for experiment
leftMotorInput = 40;    % could represent left motor input
rightMotorInput= 40;    % could represent right motor input


%% TODO Check if your motor input is integer and [0, 255] and Stop Code
if (isscalar(leftMotorInput) && isscalar(rightMotorInput) && ...
        all(isfinite([leftMotorInput, rightMotorInput])) && ...
        all(mod([leftMotorInput, rightMotorInput], 1) == 0) && ...
        all([leftMotorInput, rightMotorInput] >= 0) && ...
        all([leftMotorInput, rightMotorInput] <= 255))
        % then the input is valid, let it pass through
else 
    writeline(s, "0,0");
    warning("Invalid motor inputs, stop command sent. Values must be integers within the range [0, 255]");
    return

end
%================ YOUR INPUT ENDS ===============

outStr = sprintf("%d,%d", leftMotorInput, rightMotorInput);

% --- Send one line (terminator appended automatically)
writeline(s, outStr);
disp("Sent to Micro:bit: " + outStr);


% ==================== Initialize Arrays ==================== %
N = 50;                        % Number of samples to read
%% TODO: Preallocate array to store [L1, M, R1, Speed_L, Speed_R] and timestamp array
lineData = zeros(N, 3);
Speed_L = zeros(N, 1);
Speed_R = zeros(N, 1);
timestamp = zeros(1);

%================ YOUR INPUT ENDS ===============

%% ==================== Data Collection Loop ==================== %%
flush(s);
tic; % Initialize the timer to zero
for i = 1:N
    % Read one line from serial
    t = toc;
    line = readline(s);
    
    % Convert comma-separated string to numeric array
    nums = str2double(split(strtrim(line), ","));
    
    % nums format: [L1, M, R1, Speed_Left, Speed_Right]
    if length(nums) == 5
        %% TODO : store numbers into an array
        lineData(i, :) = nums(1:3);
        Speed_L(i, :) = nums(4);
        Speed_R(i, :) = nums(5);
        timestamp(i) = t;

        %================ YOUR INPUT ENDS ===============

        % Optional: Display received values with timestamp
        fprintf("[%f] Received: ", t);
        disp(nums');        
    end
    
    
end

%% TODO : Plot Two wheels' speed data
hold on
figure(1)
p1 = plot(timestamp, Speed_L, 'b', 'LineWidth', 1.5, 'DisplayName', 'Left Wheel');
p2 = plot(timestamp, Speed_R, 'r', 'LineWidth', 1.5, 'DisplayName', 'Right Wheel');
xlabel('Time (s)')
ylabel("Speed (cm/s)")
legend([p1 p2])
title("Wheel Speeds (Part 2)")
grid
% The dead zone of the motor inputs seems to be an input of around 14 or 
% 15, but this is quite jerky (I think due to the minor inconsistencies of
% the wheel size due to its tread). Friction in the motor and with the
% surface it's on prevent the wheels from moving with inputs lower than
% this. Taking the robot off the table at an input of 15 made the wheel
% speed go from around 0.2 - 0.4 cm/s to a relatively constant 1 cm/s,
% which helps confirm my theory about the friction instability with the
% wheels. The left and right wheel speeds were much more seperated when on
% the table: when I held it in the air the two speeds matched almost
% perfectly.

%================ YOUR INPUT ENDS ===============

%%
stopStr = sprintf("%d,%d", 0, 0); % Stop the wheels

% --- Send one line (terminator appended automatically)
writeline(s, stopStr);
% --- Clean up if done
clear s
