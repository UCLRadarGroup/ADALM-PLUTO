clear all
%For the option to change default settings, set |cmdlineInput| to 1.
cmdlineInput = 1;
if cmdlineInput
    % Request user input from the command-line for application parameters
    userInput = helperFMUserInput;
else
    load('defaultinputsFM.mat');
end

%% 



% Calculate FM system parameters based on the user input
[fmRxParams,sigSrc] = helperFMConfig(userInput);

% Create FM broadcast receiver object and configure based on user input
fmBroadcastDemod = comm.FMBroadcastDemodulator(...
    'SampleRate', fmRxParams.FrontEndSampleRate, ...
    'FrequencyDeviation', fmRxParams.FrequencyDeviation, ...
    'FilterTimeConstant', fmRxParams.FilterTimeConstant, ...
    'AudioSampleRate', fmRxParams.AudioSampleRate, ...
    'Stereo', true);

% Create audio player
player = audioDeviceWriter('SampleRate',fmRxParams.AudioSampleRate);

% Initialize radio time
radioTime = 0;


%% 

% Main loop
while radioTime < userInput.Duration
  % Receive baseband samples (Signal Source)
  if fmRxParams.isSourceRadio
      if fmRxParams.isSourcePlutoSDR
          rcv = sigSrc();
          lost = 0;
          late = 1;
      elseif fmRxParams.isSourceUsrpRadio
          rcv= sigSrc();
          lost = 0;
      else
          [rcv,~,lost,late] = sigSrc();
      end
  else
    rcv = sigSrc();
    lost = 0;
    late = 1;
  end

  
  % Demodulate FM broadcast signals and play the decoded audio
  audioSig = fmBroadcastDemod(rcv);
  player(audioSig);

  % Update radio time. If there were lost samples, add those too.
  radioTime = radioTime + fmRxParams.FrontEndFrameTime + ...
    double(lost)/fmRxParams.FrontEndSampleRate;
end

% Release the audio and the signal source
release(sigSrc)
release(fmBroadcastDemod)
release(player)

%%

  
SDR_fs = 228e3;
SDR_T = 1/SDR_fs;
SDR_Length = length(rcv);
time_axis = (0:SDR_Length-1)*SDR_T;

SDR_rx_data = rcv;
SDR_rx_data_fft = fft(SDR_rx_data);
SDR_rx_data_fft_half = SDR_rx_data_fft(1:SDR_Length/2+1);

freq_axis = SDR_fs*(0:(SDR_Length/2))/L;

figure
subplot(2,1,1);plot(time_axis,abs(rcv));title('Time domain signal')
subplot(2,1,2);plot(freq_axis,SDR_rx_data_fft_half);title('Freq Domain signal')

