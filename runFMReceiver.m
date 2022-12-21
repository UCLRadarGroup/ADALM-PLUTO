function radioTime = runFMReceiver(radioTime, userInput, viewer, doCodegen)
  %runFMReceiver FM receiver
  
  %   Copyright 2017-2021 The MathWorks, Inc.
  
persistent fmRxParam sigSrc fmBroadcastDemod player 
if isempty(fmRxParam)  
  radioConfigStatus(viewer);
  [fmRxParam,sigSrc] = helperFMConfig(userInput);
end
if isempty(fmBroadcastDemod)
    % Create FM Broadcast Demodulator
    fmBroadcastDemod = comm.FMBroadcastDemodulator(...
        'SampleRate', fmRxParam.FrontEndSampleRate, ...
        'FrequencyDeviation', fmRxParam.FrequencyDeviation, ...
        'FilterTimeConstant', fmRxParam.FilterTimeConstant, ...
        'AudioSampleRate', fmRxParam.AudioSampleRate, ...
        'Stereo', false);
    % Create audio player
    player = audioDeviceWriter('SampleRate',fmRxParam.AudioSampleRate);
end

if (userInput.SignalSourceType==ExampleSourceType.PlutoSDRRadio)
    rcv = sigSrc();
    lost = 0;
elseif (userInput.SignalSourceType==ExampleSourceType.RTLSDRRadio)
    [rcv,~,lost,~] = sigSrc();
elseif (userInput.SignalSourceType==ExampleSourceType.USRPRadio)
    rcv = sigSrc();
    lost = 0;
else
    rcv = sigSrc();
    lost = 0;
end

if doCodegen
    updateProgressBarLabel(viewer)
    helperFMDemodulator_mex(double(rcv), fmRxParam);
    radioTime = radioTime + fmRxParam.FrontEndFrameTime + ...
        double(lost)/fmRxParam.FrontEndSampleRate;
else
    updateProgressBarLabel(viewer)
    audioSig = fmBroadcastDemod(rcv);
    player(audioSig);
    radioTime = radioTime + fmRxParam.FrontEndFrameTime + ...
        double(lost)/fmRxParam.FrontEndSampleRate;
end

if nargout < 1
  release(sigSrc);
  release(fmBroadcastDemod);
  release(player);
  clear fmRxParam sigSrc fmBroadcastDemod player   
  clear helperFMDemodulator_mex
end
    
end

% [EOF]
