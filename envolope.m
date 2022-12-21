%% generateComplexEnvelope_APT.m
%   Generates a complex envelope for broadcasting with Ettus B200 USRP.
%   This version generates a DSB-LC waveform and a DSB-SC waveform with
%   sinusoidal modulating signals.
%   The DSB-LC and DSB-SC carrier signals are separated by 30kHz.
%
%   Cory J. Prust, Ph.D.
%   Last Modified:  7/11/2018

%%  USRP Configuration
%   The script generates the complex envelope sampled at 240kHz
%   So, the B200 must be configured for MasterClockRate/Interpolation = 240000.
%    e.g., MasterClockRate = 9600000 and Interpolation = 40 
clear all
close all

% sample rate
fs = 240e3;
T = 1; % will generate T second duration waveforms
t = 0:(1/fs):(T-1/fs);
N = length(t);

% Generate message signals
fm_DSBLC = 1800; %Hz
fm_DSBSC = 1200; %Hz
m_DSBLC = sin(2*pi*fm_DSBLC*t);
A = 2.2;
m_DSBSC = sin(2*pi*fm_DSBSC*t);

% generate complex envelope
fi_DSBLC = 20e3;
fi_DSBSC = 50e3;
z = (A + m_DSBLC).*exp(j*2*pi*fi_DSBLC*t) + m_DSBSC.*exp(j*2*pi*fi_DSBSC*t);

% normalize complex envelope
z = z/max(abs(z)) * 0.8;  % ensure magnitude < 1 to prevent saturation in USRP

% time-domain plots
figure
hold on
plot(t,real(z))
plot(t,imag(z))
plot(t,abs(z))
plot(t,angle(z))
legend('real','imag','abs','angle')

% frequency-domain plot
f = -fs/2:(fs/N):(fs/2 - fs/N);
figure
plot(f,20*log10(abs(fftshift(fft(z)))));

% %% load .wav file
% %filename1 = 'I Heard It Through The Grapevine - Excerpt.wav';  % filename for audio signal
% filename1 = 'Beatles_blackbird.ogg';
% filename2 = 'speech1.wav';  % filename for audio signal
% [x1,fs1] = audioread(filename1); % load audio signal (can be either mono or stereo)
% [x2,fs2] = audioread(filename2); % load audio signal (can be either mono or stereo)
% if fs1 ~= fs2,
%     error('wave files must have same sampling rate')
% end
% 
% % make them equal length
% x2 = [x2; x2 ; x2];
% x2(length(x1)) = 0; % pad with zeros
% 
% % generate AM signal
% x1 = resample(x1,fs,fs1);    % increase sampling rate
% b = fir1(250,10000/(fs/2));  % clean up source
% x1 = filter(b,1,x1);  % clean up source
% 
% % AM modulation (calculate the complex envelope of the AM signal)
% % see p. 235 Couch 3rd edition.
% %z1 = (x1+1);   % Add D.C. offset (DSB-LC)
% z1 = (x1(:,2) + 1);
% z1 = z1/max(abs(z1));  % rescale amplitude for -1 to 1
% 
% % generate signal for second station
% x2 = resample(x2,fs,fs2);    % increase sampling rate
% b = fir1(250,5000/(fs/2));  % clean up source
% x2 = filter(b,1,x2);  % clean up source
% 
% % SSB modulation (calculate the complex envelope of the SSB signal)
% % see p. 235 Couch 3rd edition.
% % The signal is shifted up by 30 kHz with respect to the AM signal
% z2 = hilbert(x2);
% z2 = z2.*exp(j*2*pi*(-30000)/fs*(1:length(z2)))';
% z2 = z2/max(abs(z2));  % rescale amplitude for -1 to 1
% 
% z = z1 + z2;
% z = z/max(abs(z));
% 
% % apply digital gain < 1 to prevent saturation in USRP
% z = 0.9*z; 


