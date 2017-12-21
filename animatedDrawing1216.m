%% Create the serial object
clear
clc
delete(instrfindall);
%s = serial('/dev/tty.usbmodem1431', 'BaudRate', 115200);
s = Bluetooth('EE704', 1);
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
Order = 15;

composedSignal_length = 2000;  
composedSignal = eye(1, composedSignal_length);
segments = composedSignal_length / L;
composedSignalTime = (0:segments*L-1)*T;
%% Setup fig
subplot(2,2,1);
haxes = plot(0 , 0);
pause(1);

while ishandle(haxes)

    %% Collect data
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
    
    subplot(2,2,3);
    [LPFSignal, f] = freq(Fsamp, detrend(composedSignal, 'constant'), composedSignal_length);
    plot(f,LPFSignal) 
    title('Single-Sided Amplitude Spectrum')
    xlabel('f (Hz)')
    ylabel('|P1(f)|')
    xlim([0, 30])
    [M, loc] = max(LPFSignal);
    fixed_obj = 3 * 10^8 * 0.4675 * 2 * f(loc) / (4 * 394 * 10^6);
    %disp(['distance = ' num2str(fixed_obj) 'm']);
    
    subplot(2,2,2);
    [LPFSignal, f] = freq(Fsamp, hipassfilt(Order,detrend(composedSignal, 'constant')), composedSignal_length);
    plot(f,LPFSignal) 
    title('Single-Sided Amplitude Spectrum')
    xlabel('f (Hz)')
    ylabel('|P(f)|')
    xlim([0, 30])
    %ylim([-70, 0])
    
    [M, loc] = max(LPFSignal);
    obj_distance = (100 * 3 * 10^8 * 0.4675 * 2 * f / (4 * 394 * 10^6)) - 20;
    disp(['distance = ' num2str(round(obj_distance(loc))) 'cm']);
 
    txt1 = [num2str(f(loc)) 'Hz\rightarrow'];
    text(f(loc),LPFSignal(loc),txt1,'HorizontalAlignment','right');
    
    subplot(2,2,4);
   
    plot(obj_distance,LPFSignal);
    title('freq & distance')
    xlabel('distance(cm)')
    ylabel('|P(f)|')
    xlim([-20, 514])
    %ylim([-70, 0])
    
    txt2 = ['Distance = ' num2str(round(obj_distance(loc))) 'cm\rightarrow'];
    text(obj_distance(loc),LPFSignal(loc),txt2,'HorizontalAlignment','right');
    
    pause(0.04); % give it some time to plot 
end
fclose(s);





%% FFT & LPF FUNC
function [dataOut, f] = freq(Fsamp, dataIn, dataLength)
NFFT = 2^nextpow2(dataLength);
YYY = fft(dataIn, NFFT);
P222 = abs(YYY/NFFT);
P111 = P222(1:NFFT/2+1);
P111(2:end-1) = 2*P111(2:end-1);
dataOut = P111;
f = Fsamp *(0:(NFFT/2))/NFFT;
end


function dataOut = hipassfilt(N,dataIn)
%hpFilter = designfilt('highpassiir','FilterOrder',N);
bpFilt = designfilt('bandpassiir','FilterOrder',20, ...
         'HalfPowerFrequency1',4,'HalfPowerFrequency2',40, ...
         'SampleRate',500);
     
df = designfilt('highpassfir','PassbandFrequency',4,...
'StopbandFrequency',3,'PassbandRipple',0.5,...
'StopbandAttenuation',95,'SampleRate',500);
dataOut = filter(bpFilt,dataIn);
end
