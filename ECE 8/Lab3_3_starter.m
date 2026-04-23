% ==================== Lab 3-3: Line Tracing (Solution) ==================== %
% Uses three line sensors (L1, M, L2). Sensor = 1 when over black line.
close all

% --- Adjust COM port to match your Micro:bit (check Device Manager / ls /dev/tty* on Mac/Linux)
% To list available ports in MATLAB, run:
% ports = serialportlist("available");
port = "COM9";
baud = 115200;

if exist("s","var")
    if isvalid(s)
        clear s
        pause(0.5)
    end
end
s = serialport(port, baud);
configureTerminator(s, "LF");
flush(s);

% --- Controller parameters (tune as needed; 0-255 range)
N         = 200;  % number of control iterations
Ts        = 0.01;  % loop period (s)

% --- Logging arrays
logSensors = zeros(N,3);   % [L1 M R1]
logSpeed   = zeros(N,2);   % [Speed_L Speed_R] from Micro:bit (if provided)
logCmd     = zeros(N,2);   % [uL uR] sent
logTime    = zeros(N,1);

% --- Ensure robot starts from stop
writeline(s, sprintf("%d,%d", 0, 0));


%% TODO: Any setting that you need to run for loop.


%================ YOUR INPUT ENDS ===============
tic; % Initialize the timer to zero
for i = 1:N
    %Read the last line in communication buffer
    lastLine = "";
    while(s.NumBytesAvailable<1) % Wait until buffer has some line.       
    end
    if s.NumBytesAvailable > 0        
        while s.NumBytesAvailable > 0
            % Read one line at a time
            lastLine = readline(s);
        end        
    end
    line = lastLine;
    t = toc;

    nums = str2double(split(strtrim(line), ",")); %[L1,M,R2,SpeedL,SpeedR]
    
    if numel(nums) < 5 || any(isnan(nums(1:5)))
        % If malformed, keep last command and continue
        fprintf("[%f] Malformed: %s\n", t, line);
        pause(Ts); 
        continue; % This skips the lines below and iterate.
    end

    % Initialize the current sensor readings variable to NaN=Not-a-Number
    L1 = NaN; %L1 sensor value
    M  = NaN; %M sensor value
    R1 = NaN; %R1 sensor value
    sL = NaN; %speed of Left wheel value
    sR = NaN; %speed of Right wheel value
    
    %% TODO: Update L1, M, R1, sL, sR with the current 
    L1 = nums(1);
    M = nums(2);
    R1 = nums(3);
    sL = nums(4);
    sR = nums(5);

    %============== YOUR INPUT ENDS===============

    logSensors(i,:) = [L1 M R1];
    logSpeed(i,:)   = [sL sR];
    logTime(i,:) = t;

    % ------------------ Line-following logic ------------------ %
    uL = 0; % control input to left motor, integer [0, 255]
    uR = 0; % control input to right motor, integer [0, 255]
    
    %% TODO: Update uL, uR using your logic to trace the line track
    % CCW First
    

    if (L1 == 1)     % Left Sensor detection
        uL = 40;
        uR = 130;

    elseif (R1 == 1) % Right Sensor detection     
        uL = 130;
        uR = 40;

    else             % Go straight
        uL = 70;
        uR = 70;
    end

    % My control idea is essentially to just go straight unless the left or
    % right line sensor gets triggered. If the left gets triggered, the
    % robot needs to turn to the left to stay on the track so it drives
    % the right wheel faster than the left. And conversely for the right
    % sensor, the robot needs to turn right so I drive the left wheel faster
    % than the right until the sensor stops getting triggered. It handled
    % straight sections great, and usualy only has to correct a little at
    % the end of every turn. This code is nice because it doesn't depend on
    % any sensors being active to go forwards. This means loss of the line
    % isn't fatal unless the line isn't in between the sensors.
    %============== YOUR INPUT ENDS===============

    % Send motor command
    cmd = sprintf("%d,%d", uL, uR);
    writeline(s, cmd);
    logCmd(i,:) = [uL uR];

    % Optional console log
    fprintf("[%s] L1 M R2 = [%d %d %d]  Speeds=[%.1f %.1f]  Cmd=%s\n", ...
        string(t), L1, M, R1, sL, sR, cmd);


    pause(Ts); %control loop pause
end

% --- Stop and cleanup
writeline(s, sprintf("%d,%d", 0, 0));
clear s

%% TODO : Plot L1, M, R1 sensor data
figure(1)
plot(logTime, logSensors, 'LineWidth', 2)
xlabel("Time (s)")
ylabel("Sensor Data")
legend({"L1", "M", "R1"})
title("Line Sensor Data (Part 3)")
grid

% You can infer which direction the robot is going around the track by
% which sensor activates most oftne (Left or Right). If the left sensor is
% triggered more often, the robot is probably going counter-clockwise
% because it is turning to the left, and vice versa. ALso, if the robot is
% going CW then the right wheel is usually turning slower, and vice versa.
%================ YOUR INPUT ENDS ===============

%% TODO : Plot Two wheels' speed data
figure(2)
plot(logTime, logSpeed, 'LineWidth', 2)
xlabel("Time (s)")
ylabel("Speed Data")
legend({"Left Speed", "Right Speed"})
title("Speed Sensor Data (Part 3)")
grid

% Increasing the loop period makes my robot less accurate in following the
% line. I imagine this is because the robot misses valuable input time
% where one of the line sensors triggers, but the robot has to wait to
% react to the sensor data until the next time cycle, which in some cases
% results in the robot going off the track completely (especially at the
% start of turns).
%================ YOUR INPUT ENDS ===============