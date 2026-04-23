A = [-1 -4; 1 -1];

[x1, x2] = meshgrid(linspace(-3, 3, 20));
u = A(1,1)*x1 + A(1,2)*x2;
v = A(2,1)*x1 + A(2,2)*x2;

figure;
quiver(x1,x2,u,v,'k');
hold on;

x_vals = linspace(-3,3,50);

xlabel('x_1')
ylabel('x_2')
title('Trajectory over x1 -> x2 plane')
grid on
axis([-3 3 -3 3])
axis equal
