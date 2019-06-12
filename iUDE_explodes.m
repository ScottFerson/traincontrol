function iUDE_explodes()
    ude(800)
    ude(2000)
end

function ude(many)
% x = x 1
% y = x 2
% w = theta 1
% z = theta 2

figure
hold on

dt = 0.001;

x0 = 1.2;
y0 = 1.1;

w = 3;
z = 1;

x = x0;
y = y0;

X = 1:many;
Y = 1:many;

for t = 1:many 
    
    dxdt = w .* x .* (1 - y);
    dydt = z .* x .* y - z .* y;
    
    x = x + dxdt * dt;
    y = y + dydt * dt;
    
    X(t) = x;
    Y(t) = y;
end

plot((1:many)*dt, X, (1:many)*dt, Y)


% do the interval-based calculations

x0 = [1.2, 1.2];
y0 = [1.1, 1.1];

w = [2.99, 3.01];
z = [0.99, 1.01];

x = x0;
y = y0;

X = [1:many; 1:many]';
Y = [1:many; 1:many]';

for t = 1:many 
    
    dxdt = w .* x .* (1 - y(2:-1:1));
    dydt = z .* x .* y - z(2:-1:1) .* y(2:-1:1);
    
    x = x + dxdt * dt;
    y = y + dydt * dt;
    
    X(t,:) = x;
    Y(t,:) = y;
end
t = (1:many)*dt;
plot(t, X(:,1), '-c',  t, Y(:,1), '-m')
plot(t, X(:,2), '-c',  t, Y(:,2), '-m')

end
