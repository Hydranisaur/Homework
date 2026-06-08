clc;
clear;

x(1) = 0;
x(2) = 3;
for n = 1 : 25
    if n > 2
        x(n) = 6*x(n-1) - 9*x(n-2);
    end
    xx(n) = (n-1)*(3^(n-1));
end

figure;
plot(x, LineStyle="--", Color="r");
hold on;
plot(xx, LineStyle="-.",Color="b");