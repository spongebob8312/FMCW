%% Create the serial object
clear
clc
delete(instrfindall);
s = serial('/dev/tty.usbmodem1431', 'BaudRate', 115200);
%s = Bluetooth('EE704', 1);
fopen(s);


a = 'b';
while (a ~= 'a')
    a = fread(s, 1, 'uchar');
end
if (a=='a')
    disp('serial read');
end
fprintf(s, '%c', 'a');
disp('Serial Communication setup.');

%% Sampling Config
Fsamp = 500;            % Sampling frequency                    
T = 1/Fsamp;             % Sampling period       
L = 250;             % Length of signal
t = (0:L-1)*T;        % Time vector
signal = eye(1,L);


composedSignal_length = 2000;  
composedSignal = eye(1, composedSignal_length);
segments = composedSignal_length / L;
composedSignalTime = (0:segments*L-1)*T;

%% Setup fig
subplot(2,2,1);
haxes = plot(0 , 0);
pause(1);


while ishandle(haxes)

    % Collect data
    for i=1:L  
       signal(i) = fscanf(s, '%d');
    end
    composedSignal = circshift(composedSignal,-L);
    composedSignal((segments-1)*L+1:segments*L) = signal(1:L);
    
    subplot(2,2,1);
    set(haxes, 'XData', 1000*composedSignalTime(1:composedSignal_length), 'YData', composedSignal(1:composedSignal_length));
    title('Signal')
    xlabel('t (milliseconds)')
    ylabel('signal(t)')
    ylim([140, 180])
    
    
    %obj_distance = (100 * 3 * 10^8 * 0.4675 * 2 * f / (4 * 394 * 10^6)) - 20;
    %disp(['distance = ' num2str(round(obj_distance(loc))) 'cm']);
 
    %txt1 = [num2str(f(loc)) 'Hz\rightarrow'];
    %text(f(loc),LPFSignal(loc),txt1,'HorizontalAlignment','right');
    
    
    pause(0.04); % give it some time to plot 
end
fclose(s);

