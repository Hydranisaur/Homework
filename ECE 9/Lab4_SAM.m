%% Part 1 — Bench Map (Maqueen on blocks): PWM -> Wheel Speed
% Uses your exact I/O format:
%  - TX:  "L,R" (integers; newline auto-appended by writeline)
%  - RX:  five comma-separated numbers per line:
%         [L1, M, L2, Speed_Left, Speed_Right]

clear; clc; close all;

%% ==================== USER SETTINGS ====================
port = "COM13";      % <-- adjust
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
u_levels = 0:2:30;
samples_per_level = round(hold_time/dt) + 1;
speedData = zeros(length(u_levels) * samples_per_level, 2);
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
        disp(input)
        pause(dt);
    end
end


%% =================== Stop motor
stopStr = sprintf("%d,%d", 0, 0);

% Stop motors at the end
writeline(s, stopStr);