clear;
clc;

vC = [-390; 0; 0];
Rrolling = 11;          % 22 / 2
Rpoints = 9;            % 22 - 2 - 2 / 2

omega = 390/11;
w = [0; 0; omega];

theta = linspace(0, 2*pi, 17);      % Split a full circle with theta = 2pi into 16 partitions to get each theta value
theta(end) = [];                    % Make the last theta value empty, the same as the begining, to create 16 theta values

r = [Rpoints * cos(theta); Rpoints * sin(theta); zeros(1,16)];

v = zeros(3, 16);

for i = 1:16
    v(:,i) = vC + cross(w, r(:,i));
end

disp(v.');