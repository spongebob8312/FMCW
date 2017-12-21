function [dataOut, f] = freqDomain(Fsamp, dataIn, dataLength)
%freqDomain Returns fft signal and freq.

% All frequency values are in Hz.
NFFT = 2^nextpow2(dataLength);
YYY = fft(dataIn, NFFT);
P222 = abs(YYY/NFFT);
P111 = P222(1:NFFT/2+1);
P111(2:end-1) = 2*P111(2:end-1);
dataOut = P111;
f = Fsamp *(0:(NFFT/2))/NFFT;
end
