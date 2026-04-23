%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ECE10, Single Axis Rotation
%  Prof. Dejan Milutinovic
%  UC Santa Cruz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
L=2;
W=0.5;
H=1;
pauseVar=0.1;
x(1)=-L/2;y(1)=-W/2;z(1)=-H/2;
x(2)=L/2;y(2)=-W/2;z(2)=-H/2;
x(3)=L/2;y(3)=W/2;z(3)=-H/2;
x(4)=-L/2;y(4)=W/2;z(4)=-H/2;
x(5)=-L/2;y(5)=-W/2;z(5)=H/2;
x(6)=L/2;y(6)=-W/2;z(6)=H/2;
x(7)=L/2;y(7)=W/2;z(7)=H/2;
x(8)=-L/2;y(8)=W/2;z(8)=H/2;
% Draw box
figure(1);
fill3(x(1:4),y(1:4),z(1:4),'r'), hold on
fill3(x(5:8),y(5:8),z(5:8),'g')
fill3([x(1) x(2) x(6) x(5)],...
      [y(1) y(2) y(6) y(5)],...
      [z(1) z(2) z(6) z(5)],'b');
fill3([x(2) x(3) x(7) x(6)],...
      [y(2) y(3) y(7) y(6)],...
      [z(2) z(3) z(7) z(6)],'y');
fill3([x(3) x(4) x(8) x(7)],...
      [y(3) y(4) y(8) y(7)],...
      [z(3) z(4) z(8) z(7)],'m');
fill3([x(1) x(5) x(8) x(4)],...
      [y(1) y(5) y(8) y(4)],...
      [z(1) z(5) z(8) z(4)],'c');
axis equal
axis([-L L -L L -L L]); 
grid on;
pause(pauseVar);
hold off;
%Rotation
u=[1;1;1]; %fixed axis
iangle=5;
Rot=RotMatrix(u,iangle*pi/180);
for k=1:round(360*6/iangle),
   for i=1:8,
     tmp=Rot*[x(i);y(i);z(i)];  
     x(i)=tmp(1);
     y(i)=tmp(2);
     z(i)=tmp(3);
   end
   % Draw box
   figure(1)
   fill3(x(1:4),y(1:4),z(1:4),'r'), hold on
   fill3(x(5:8),y(5:8),z(5:8),'g')
   fill3(x(5:8),y(5:8),z(5:8),'g')
   fill3([x(1) x(2) x(6) x(5)],...
         [y(1) y(2) y(6) y(5)],...
         [z(1) z(2) z(6) z(5)],'b');
   fill3([x(2) x(3) x(7) x(6)],...
         [y(2) y(3) y(7) y(6)],...
         [z(2) z(3) z(7) z(6)],'y');
   fill3([x(3) x(4) x(8) x(7)],...
         [y(3) y(4) y(8) y(7)],...
         [z(3) z(4) z(8) z(7)],'m');
   fill3([x(1) x(5) x(8) x(4)],...
         [y(1) y(5) y(8) y(4)],...
         [z(1) z(5) z(8) z(4)],'c');
   axis equal
   axis([-L L -L L -L L]); 
   xlabel('x');
   ylabel('y');
   zlabel('z');
   grid on;
   %pause(pauseVar);
   hold off;
end

