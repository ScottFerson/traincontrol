clear
%clc
figure
tic;

load('data.mat');
speed_profile(end,:)=[];

scheduled_journey_time=120;

time_step=0.001; % time resolution: 1ms
control_step=0.1; % control command update resolution: 100ms
eta_accl=50; % control parameter when current speed < reference speed
eta_decl=8000; % % control parameter when current speed > reference speed

F_max=310; %kN
B_max=260; %kN
M_empty=278; %10^3kg
c0_mean=3.9476; % parameters for resistance
c1_mean=3.6*0;
c2_mean=3.6^2*2.2294e-3; 

M=M_empty;
F=0; %initial force applied
s=speed_profile(1,1); % initial location
v=0; %initial speed
v_ref=1;
train_trajectory=[s,v,v_ref];
step_count=control_step/time_step+1;
E=0;
while v_ref>0 | v>0
    c0=c0_mean; 
    c1=c1_mean;
    c2=c2_mean;
    gd_loc=find(gd_table(:,2)<=s & gd_table(:,3)>s);
    if step_count>=control_step/time_step
        if s>speed_profile(end,1) % train going beyond the stop point
            v_ref=-100; % reference speed
        else
            v_loc=find(speed_profile(1:end-1,1)<=s & speed_profile(2:end,1)>s); % train not going beyond the stop point
            v_ref=speed_profile(v_loc,2); % reference speed 
        end
        
        F_r=c0_mean+c1_mean*v+c2_mean*v^2;
        F_g=M*9.80665*gd_table(gd_loc,1);
        
        if v_ref>v
            F=min(F_max, eta_accl*(v_ref-v)+F_r+F_g); % force applied
        else
            F=max(-B_max, eta_decl*(v_ref-v)+F_r+F_g);
        end
              
        step_count=0;
    else
        step_count=step_count+1;
    end
    
    a=(F-(c0+c1*v+c2*v^2))/M-9.80665*gd_table(gd_loc,1); % acceleration 
    v_new=v+a*time_step; % speed
    ds=(v+v_new)/2*time_step; %distance traveled during the latest time step
    s=s+ds; % location
    E=E+max(F,0)*ds; %energy
    v=v_new;
    train_trajectory(end+1,:)=[s,v,v_ref];
    if ~step_count
        clf
        p1=plot(train_trajectory(:,1),train_trajectory(:,2), 'b-');
        hold on;
        p2=plot(train_trajectory(:,1),train_trajectory(:,3),'r-');
        hold on;
        legend('actual speed','reference/advisory speed', 'Location','best');
        xlim([speed_profile(1,1),inf]);
        ylim([0,inf]);
        xlabel('location (metre)');
        ylabel('speed (m/s)');
        pause(0.00001);
    end
end

%clf
p1=plot(train_trajectory(:,1),train_trajectory(:,2), 'b-');
hold on;
p2=plot(train_trajectory(:,1),train_trajectory(:,3),'r-');
hold on;
legend('actual speed','reference/advisory speed', 'Location','best');
xlim([speed_profile(1,1),inf]);
ylim([0,inf]);
xlabel('location (metre)');
ylabel('speed (m/s)');


str=sprintf(' Scheduled journey Time(sec):\t %f sec \n Actual journey Time: \t %f sec \n Station stop error : \t %f metre \n Total energy consumption: \t %f kJ \n', scheduled_journey_time, time_step*size(train_trajectory,1), train_trajectory(end,1)-speed_profile(end,1), E);
disp(str)
toc;
