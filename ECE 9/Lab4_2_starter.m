%% Part 2 — System ID on flat floor (ARX-like fit)
% Model: v_{k+1} = a*v_k + b_u*max(0, u_k - u0) + d
% Uses your I/O:
%  TX: "L,R"
%  RX: [L1, M, L2, Speed_Left, Speed_Right]

clear; 

%% ==================== USER SETTINGS ====================
port = "COM13";     % <-- adjust
baud = 115200;

dt        = 0.15;   % sample period (s)  (10 Hz is plenty)
hold_time = 0.5;    % seconds per step level (random sequence)
n_steps   = 9;    % number of steps in the random sequence

u_levels  = [40 75 110 145 180];  % safe/effective PWM levels
v_units   = "cm/s";               % incoming units of Speed_L/R

%% ==================== SERIAL SETUP ======================
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


%% ==================== INPUT SEQUENCE ====================
% Random multi-step: pick among u_levels, hold each for hold_time
steps_pwm = [];
for i = 1:ceil(n_steps / numel(u_levels))
    steps_pwm = [steps_pwm, u_levels(randperm(numel(u_levels)))];
end
steps_pwm = steps_pwm(1:n_steps);

samples_per_step = max(1, round(hold_time/dt));
N = n_steps * samples_per_step;

U = zeros(N,1);  % commanded PWM (same L & R)
for i = 1:n_steps
    idx = (i-1)*samples_per_step + (1:samples_per_step);
    U(idx) = steps_pwm(i);
end

%% ================ TODO-Experiment and Build V and X =====================

V = zeros(N,1); % From (Eqn 10)
X = ones(N, 3); % From (Eqn 10)
speedData = zeros(N, 2);

% Your code
for k = 1:N
    outStr = sprintf("%d,%d", U(k), U(k));
    writeline(s, outStr);
    
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
        speedData(k,:) = [nums(4), nums(5)];        % As long as nums has some 5 pieces of data in it,
    else                                            % read it into speedData
        % Handle a bad read by copying the last good one
        if k > 1
            speedData(k,:) = speedData(k-1,:);
        else
            speedData(k,:) = [0 0];
        end
    end
    
    % Store values
    speedData(k,:) = [nums(4), nums(5)];
    %V(k, 1) = v;  

    pause(dt);
end

% Stop motors
writeline(s, stopStr);
v_mean = mean(speedData, 2,"omitnan");      % Take the mean of the two wheel speeds, omitting bad reads
% Your code
V = v_mean(2: end);
X = [v_mean(1: end -1), U(1: end - 1), ones(N - 1, 1)];      % Forms the X matrix with each appropriate column

%% ==================== BUILD REGRESSION ==================
% v_{k+1} = a*v_k + b*u + d
% least squares (eqn 12)
theta = X \ V;
a   = theta(1);
b = theta(2);
d   = theta(3);

% one-step predictions and fit quality
V_pred = X * theta;
R2 = 1 - sum((V - V_pred).^2) / sum((V - mean(V)).^2);

%% ==================== REPORT ===========================
fprintf('\n=== ARX-like ID Results (flat) ===\n');
fprintf('a   = %.5f\n', a);
fprintf('b = %.5f  [cm/s per (PWM-u0) per sample]\n', b);
fprintf('d   = %.5f  [cm/s per sample]\n', d);
fprintf('R^2 = %.3f\n', R2);


%% ==================== PLOTS =============================
figure('Color','w');
tiledlayout(2,1,'Padding','compact','TileSpacing','compact');

% 1) Input sequence
nexttile;
plot(U, '-', 'LineWidth', 1.2);
xlabel('Time (s)'); ylabel('PWM u'); title('Random Multi-Step Input'); grid on;

% 2) One-step prediction vs measured (aligned with v_{k+1})
nexttile;
plot(V, '.', 'DisplayName','measured'); hold on;
plot(V_pred, '-', 'DisplayName','predicted','LineWidth',1.1);
xlabel('Discrete Time Step'); ylabel('Speed (cm/s)');
title(sprintf('One-step Prediction (R^2=%.3f)', R2));
legend('Location','best'); grid on;

sgtitle('Part 2: System ID (ARX-like) Downhill');

