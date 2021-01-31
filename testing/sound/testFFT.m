clc
clear
close all
[signal,fs] = audioread('test.mp3');
duration = length(signal)/fs;
t=1/fs:1/fs:duration; %Time 
x=signal(:,1)';
plot(t,x) %Plotting the time domain signal
xlabel('t');
ylabel('x(t)');
title('Time domain Signal')
N=length(x);
N1=2^nextpow2(N);
X=fft(x,N1);
X=X(1:N1/2);%Discard Half of Points
X_mag=abs(X); %Magnitude Spectrum
X_phase=angle(X); %Phase Spectrum
f=fs*(0:N1/2-1)/N1; %Frequency axis
figure
plot(f,(X_mag/N1)); %Plotting the Magnitude Spectrum after Normalization
xlabel('Frequency (Hz)');
ylabel('Magnitude Spectrum');
title('Magnitude Spectrum vs f')
figure
plot(f,X_phase); %Plotting the frequency domain
xlabel('Frequency (Hz)');
ylabel('Phase Spectrum');
title('Phase Spectrum vs f')
