function [theta_k, X_k] = getRobotAngleFromPoints(p1, p2, p3)
%GETROBOTLANGLEFROMPOINTS  Estimate wall angle and distance relative to robot body.
%
%   [robotAngle, lateralDistance] = GETROBOTLANGLEFROMPOINTS(p1, p2, p3)
%
%   INPUT:
%       p1, p2, p3 : 3×1 vectors, 3D points [x; y; z] in robot body frame
%                    (x: right, y: forward, z: up). These are usually
%                    obtained from GETPOINTCOORD. Units are cm.
%
%   OUTPUT:
%       theta      : Theta_k in the diagram. Unit is Radian
%
%       X          : X_k in the diagram. Unit is cm

    theta_k = 0.0;
    X_k = 0.0;

    %% ==========TODO ================

X = [p1(1); p2(1); p3(1)];
Y = [p1(2); p2(2); p3(2)];

A = [Y, ones(3,1)];
coeff = A \ X;        % Use least squares to fit a line (y = mx + b)through all three points
m = coeff(1);
b = coeff(2);

% Compute wall angle using line of best fit
wallAngle = atan2(1, -m);
robotAngle = wallAngle;   % To account for the x axis being perpendicular to the wall

theta_k = atan2(sin(robotAngle), cos(robotAngle));
% Some fancy matlab math to normalize the angle into [-pi, pi] terms

X_k = abs(b) / sqrt(m^2 + 1);
% This originates from the point-to-line distance formula, which I 
% looked up and solved for with my line of best fit










end
