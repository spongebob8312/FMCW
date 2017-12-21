load('fourSecsSignal.mat')
signal = detrend(signal);
Fsamp = 500;            % Sampling frequency                    
T = 1/Fsamp;             % Sampling period       
L = 2000;             % Length of signal
t = (0:L-1)*T;        % Time vector


subplot(2,2,1)
[signalInFreqDomain, f] = freqDomain(Fsamp, signal, L);
plot(f, signalInFreqDomain);
xlim([0 20]);
title('FFT');
ylabel('|P|');
xlabel('Freq(Hz)');

subplot(2,2,2)
IIR = filter(IIRButterworthHighPass, signal);
[IIRSig, f] = freqDomain(Fsamp, IIR, L);
plot(f, IIRSig);
xlim([0 20]);
title('IIR');
ylabel('|P|');
xlabel('Freq(Hz)');

subplot(2,2,3)
FIR = filter(FIRChebysevHP, signal);
[FIRSig, f] = freqDomain(Fsamp, FIR, L);
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
