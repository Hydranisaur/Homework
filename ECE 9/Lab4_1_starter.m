%% Part 1 — Bench Map (Maqueen on blocks): PWM -> Wheel Speed
% Uses your exact I/O format:
%  - TX:  "L,R" (integers; newline auto-appended by writeline)
%  - RX:  five comma-separated numbers per line:
%         [L1, M, L2, Speed_Left, Speed_Right]

clear; clc; close all;

%% ==================== USER SETTINGS ====================
port = "COM15";      % <-- adjust
baud = 115200;

dt          = 0.05;  % sample period during holds (s)
hold_time   = 1;   % time to hold each command level (s)

%% ==================== SERIAL SETUP =====================
% If a serial object 's' already exists, clear it (your pattern)
if exist("s","var")
    if isvalid(s)
        clear s
        pause(0.5)
    end
end

s = serialport(port, baud);
configureTerminator(s, "LF");  % Micro:bit expects newline
flush(s);

stopStr = sprintf("%d,%d", 0, 0);
cleanupObj = onCleanup(@() safeClose(s, stopStr));

%% ==================== Motor command Example ========
u = 0;
% Send command "L,R"
outStr = sprintf("%d,%d", u, u);
writeline(s, outStr);

%% ==================== Sensor Reading Example ========
%lastLine = "";
%while(s.NumBytesAvailable<1)
%end
%if s.NumBytesAvailable > 0
%    while s.NumBytesAvailable > 0
%        % Read one line at a time
%        lastLine = readline(s);
%    end
%end
%line = lastLine;

% Convert comma-separated string to numeric array
%nums = str2double(split(strtrim(line), ","));

% nums format: [L1, M, R1, Speed_Left, Speed_Right]
%disp('Sensor readings [L1, M, R1, Speed_Left, Speed_Right]')
%disp(nums'); 


%% ==================== TODO  =================
% Sweep the motor input and find the deadzone of the motor
% Sweep input from 0 to 30 with increment of 2. Hold each input for
% 'hold_time' amount. 
% Plot Input vs Speed and point out where is the deadzone (maximum input
% where the motor does not move with non-zero inputs).
% You should collect the sensor reading every dt. 
levels = 0:2:30;
samples = round(hold_time/dt) + 1;
speedData = zeros(length(levels) * samples, 2);
inputs = zeros(length(levels) * samples, 1);
count = 0;

for input = 0:2:30
    for t = 0:dt:hold_time
        
        outStr = sprintf("%d,%d", input, input);
        writeline(s, outStr);

        lastLine = "";
        while(s.NumBytesAvailable<1)
        end
        if s.NumBytesAvailable > 0
            while s.NumBytesAvailable > 0
                % Read one line at a time
                lastLine = readline(s);
            end
        end
        line = lastLine;
        % nums format: [L1, M, R1, Speed_Left, Speed_Right]
        nums = str2double(split(strtrim(line), ","));

        sL = nums(4);
        sR = nums(5);
        count = count + 1;
        speedData(count, :) = [sL, sR];
        inputs(count) = input;
        disp(input)
        pause(dt);

% Puts all of the speed sensor data, the inputs, and the timestamps into
% arrays to plot later, and pauses for dt until the next cycle
    end
end
levels = unique(inputs);  % all distinct PWM inputs
avgLeft  = zeros(size(levels));
avgRight = zeros(size(levels));

for i = 1:length(levels)
    idx = (inputs == levels(i));
    avgLeft(i)  = mean(speedData(idx,1), 'omitnan');
    avgRight(i) = mean(speedData(idx,2), 'omitnan');
end
% This took some time to figure out, but it basically just averages all of
% the data and uses only the unique inputs, since they are repeated many 
% times a cycle

figure;
plot(levels, avgLeft,  '-or', 'LineWidth',1.8, 'DisplayName','Left wheel');
hold on;
plot(levels, avgRight, '-ob', 'LineWidth',1.8, 'DisplayName','Right wheel')
plot(levels, levels,   '--k', 'LineWidth',1.2, 'DisplayName','PWM input');
xlabel('PWM Input');
ylabel('Wheel Speed');
title('Wheel Speeds vs Input');
legend('Location','northwest');
grid on;
% Some nice formatting that puts all the lines together, with labels and
% legend

% From the plot, the deadzone appears to be at around a PWM input of 14,
% where after this value any others that are applied cause the wheels 
% to start to turn.

%% =================== Stop motor
stopStr = sprintf("%d,%d", 0, 0);

% Stop motors at the end
writeline(s, stopStr);




