A = [1 -2; 3 -4];

[x1, x2] = meshgrid(linspace(-3, 3, 25));
u = A(1,1)*x1 + A(1,2)*x2;
v = A(2,1)*x1 + A(2,2)*x2;

figure;
quiver(x1,x2,u,v,'k');
hold on;

x_vals = linspace(-3,3,50);

plot(x_vals, 1.5*x_vals, 'r--') %% First eigen vector is [2; 3]
plot(x_vals, x_vals, 'g--')     %% Second eigen vector is [1; 1]

xlabel('x_1')
ylabel('x_2')
title('Trajectory over x1 -> x2 plane')
grid on
axis([-3 3 -3 3])