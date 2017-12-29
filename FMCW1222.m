%% Create serial object
clear
clc
delete(instrfindall);
s = serial('/dev/cu.usbmodem1461', 'BaudRate', 115200);
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
L = 500;             % Length of signal
t = (0:L-1)*T;        % Time vector
signal = eye(1,L);
    
composedSignal_length = 2000;  
composedSignal = eye(1, composedSignal_length);
composedSignal_detrended = composedSignal;
segments = composedSignal_length / L;
composedSignalTime = (0:segments*L-1)*T;
    

%% Setup fig
subplot(2,2,1);
haxes = plot(0 , 0);
pause(1);
%% plot
while ishandle(haxes)
    
    % retrive signal
    for i=1:L  
        signal(i) = fscanf(s, '%d');
    end
    
    composedSignal = circshift(composedSignal,-L);
    composedSignal((segments-1)*L+1:segments*L) = signal(1:L);
    composedSignal_detrended = detrend(composedSignal);
    % plot 4 secs signal
    subplot(2,2,1);
    set(haxes, 'XData', composedSignalTime, 'YData', composedSignal);
    title('Signal')
    xlabel('t (seconds)')
    ylabel('signal(t)')

    subplot(2,2,2)
    IIR = filter(IIRButterworthHighPass, composedSignal_detrended);
    [IIRSig, f] = freqDomain(Fsamp, IIR, composedSignal_length);
    plot(f, IIRSig);
    xlim([0 20]);
    title('IIR');
    ylabel('|P|');
    xlabel('Freq(Hz)');

    subplot(2,2,3)
    FIR = filter(FIRChebysevHP, composedSignal_detrended);
    [FIRSig, f] = freqDomain(Fsamp, FIR, composedSignal_length);
    plot(f, FIRSig);
    xlim([0 20]);
    title('FIR');
    ylabel('|P|');
    xlabel('Freq(Hz)');

    subplot(2,2,4)
    plot(f, IIRSig, f, FIRSig);
    legend('IIR','FIR')
    xlim([0 20]);
    title('FIR & IIR Comparison');
    ylabel('|P|');
    xlabel('Freq(Hz)');

    [M, loc] = max(IIRSig);
    obj_distance = (100 * 3 * 10^8 * 0.4675 * 2 * f / (4 * 394 * 10^6)) - 20;
    disp(['distance = ' num2str(round(obj_distance(loc))) 'cm']);
 
    txt1 = [num2str(f(loc)) 'Hz\rightarrow'];
    text(f(loc),IIRSig(loc),txt1,'HorizontalAlignment','right');
    

    pause(0.5); %give it some time to plot
    
 
end
fclose(s);
 
