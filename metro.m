function [E,t] = metro() 
% A train controlled to match a specified speed profile vtilde along a 
% metro rail line.  Positions on the line are indexed by x = 1:1001, where
% 1 marks the beginning and 1001 marks the end. We compute tfinal, the time
% to reach the destination, and E, the total energy required for the trip,
% as a function of M, the mass of the train, and alpha, beta and gamma, 
% which are coefficients describing the resistance from the track and air.
close all;
tic;

start = 1;
stop = 1001;
horizon = 200.000;
maxforce = 5;  
eta = 100;
M = 1e2;            % mass of train plus passengers, constant for each trip

X = start:stop;               % space of possible positions along the track
vtilde=[20*l(200),16*l(99),19*l(99),10*l(200),20*l(99),12*l(99),3*l(99),2*l(106)]; 
G = 0.01 * tanh(X/100-5);                % incline slope as a function of x

figure;  plot(X,vtilde,'-r');
ann('Prescribed velocity','Location along track (m)','velocity (m/s)');
figure;  plot(X,G,'-g');
ann('Slope of incline', 'Location along track (m)', 'Gradient (%)');

FF = [];
x = 1;   xx = [];
v = 0;   vv = [];  vvv = [];
a = 0;
E = 0;
deltat = 1e-3;  % one millisecond
t = 0;
while ((x < stop) && (t < horizon))
  alpha = 1;  
  beta = 1;   
  gamma = 1;  
  vvv = [vvv , vtilde(floor(x))];
  R = alpha * v^2 + beta * v + gamma;
  FF = [FF , min(maxforce, (vtilde(floor(x)) - v))];  
  %F = eta * min(maxforce, (vtilde(floor(x)) - v)) ;
  F = eta * min(maxforce, (vtilde(floor(x)) - v)) +  R + G(floor(x));
  a = (1/M) * (F - R - G(floor(x)));
  deltax = v * deltat + a * deltat^2 / 2;
  x = x + deltax;
  xx = [xx , x];
  v = v + a * deltat;   
  vv = [vv , v];
  E = E + max(F,0) * deltax;  
  if (floor(x)==stop) tfinal = t;               
    end 
  t = t + deltat;
  end
  
figure;  plot(xx);
ann(['Total time ',num2str(t),' s'], 'Time (milliseconds)','Position (m)');
figure;  plot(vv); hold on;  plot(vvv); 
ann('Train velocity', 'Time (milliseconds)', 'Velocity (m/s)');
figure;  plot(FF); 
ann(['Total energy ',num2str(E)],'Time (milliseconds)','Motive force (N)');
toc;
end

function ann(ti, xl, yl)
title(ti); xlabel(xl); ylabel(yl);
end

function ii = l(i)
ii = ones(1,i);
end
