function [p1, p2, p3] = getPointCoord(distanceArray)
%GETPOINTCOORD  Convert selected 8×8 Maqueen LiDAR distances into 3D ray coordinates.
%
%   [p1, p2, p3] = GETPOINTCOORD(distanceArray)
%
%   INPUT:
%       distanceArray : 3×1 or 1x3 vector containing LiDAR distances (in mm ).
%                       These correspond to the 3 selected LiDAR pixels
%                       defined in x_y_IDList below.
%
%   OUTPUT:
%       p1, p2, p3 : 3×1 vectors, each is a 3D point [x; y; z] expressed in
%                    the robot body frame:
%                       x : right
%                       y : forward
%                       z : up
%               Units are in cm.
%
%   DESCRIPTION:
%       The Maqueen 8×8 LiDAR has a 60° × 60° field of view. Columns and rows
%       correspond to equally spaced angular steps (60°/7). 
%
%       For each selected pixel (xID, yID), this function:
%           1. Computes the horizontal (XY-plane) viewing angle.
%           2. Computes the vertical (YZ-plane) viewing angle.
%           3. Constructs a ray direction vector.
%           4. Normalizes it.
%           5. Scales by the corresponding distance measurement.
%
%       The output gives the 3D coordinates of each LiDAR hit point.
%
%   NOTE:
%       This function uses three pixels defined in x_y_IDList below, chosen
%       for left-wall angle estimation (two left-leaning rays + one forward ray).
%

    % -------------------------- Input Validation ------------------------------
    if ~isvector(distanceArray) || length(distanceArray) ~= 3
        error('distanceArray must be a 3×1 vector of three LiDAR distances.');
    end
    distanceArray = distanceArray(:);   % ensure column vector

    % ---------------------- LiDAR Pixel Selection ------------------------------
    % (xID, yID) index pairs for three rays.
    % xID = column index 0–7  (left → right)
    % yID = row index    0–7  (near top → near bottom)
    x_y_IDList = [
        0, 4   % leftmost column, middle row
        3, 4   % leftmost column, slightly lower row
        7, 4   % slightly forward-left ray
    ];

    % -------------------------- Constants --------------------------------------
    viewAngleIncrement = 60/7;   % degrees per pixel
    numPoints = 3;
    points = nan(3, numPoints);
    mm2cm = 1/10; %Constant to convert mm to cm

    % ------------------------- Main Loop ---------------------------------------
    for i = 1:numPoints
        xID = x_y_IDList(i, 1);
        yID = x_y_IDList(i, 2);

        % ---- Horizontal angle (XY-plane) ----
        % LiDAR scans ±30° horizontally
        % Define 0° as forward (y-axis), +90° as right (x-axis)
        xyAngle = 180 + 30 - viewAngleIncrement * xID;   % degrees
        v_xy = [cosd(xyAngle), sind(xyAngle), 0];

        % ---- Vertical angle (YZ-plane) ----
        % Positive is downward in sensor coords → map to z correctly
        xzAngle = 180-(30 - viewAngleIncrement * yID);        % degrees
        v_xz = [cosd(xzAngle),0, sind(xzAngle)];

        % ---- Combine into a 3D ray vector ----
        ray = [ 1;
                v_xy(2) / v_xy(1);
                v_xz(3) / v_xz(1) ];

        ray = ray ./ norm(ray);  % normalize ray direction

        % ---- Convert to 3D point ----
        points(:, i) = distanceArray(i) * ray * mm2cm;
    end

    % -------------------------- Outputs -----------------------------------
    p1 = points(:, 1);
    p2 = points(:, 2);
    p3 = points(:, 3);

end
