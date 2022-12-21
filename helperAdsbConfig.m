function [adsbParam,sigSrc] = helperAdsbConfig(varargin)
%helperAdsbConfig ADS-B system parameters
%   P = helperAdsbConfig(UIN) returns ADS-B system parameters, P. UIN is
%   the user input structure returned by the helperAdsbUserInput function.
%
%   See also ADSBExample.

%   Copyright 2015-2018 The MathWorks, Inc.

% References: [1] Technical Provisions for Mode S Services and Extended
% Squitter, ICAO, Doc 9871, AN/464, First Edition, 2008.


symbolDuration       = 1e-6;             % seconds
chipsPerSymbol       = 2;
longPacketDuration   = 112e-6;           % seconds
shortPacketDuration  = 56e-6;            % seconds
preambleDuration     = 8e-6;             % seconds

if nargin == 0
  userInput.Duration = 10;
  userInput.FrontEndSampleRate = 2.4e6;
  userInput.RadioAddress = '0';
  userInput.SignalSourceType = ExampleSourceType.Captured;
  userInput.SignalFilename = 'adsb_capture_01.bb';
  userInput.launchMap = 0;
  userInput.logData = 0;
else
  tmp = varargin{1};
  if isstruct(tmp) || isa(tmp, 'ExampleController')
    userInput = varargin{1};
  else
    userInput.Duration = 10;
    userInput.FrontEndSampleRate = tmp;
    userInput.RadioAddress = '0';
    userInput.SignalSourceType = ExampleSourceType.Captured;
    userInput.SignalFilename = 'adsb_capture_01.bb';
    userInput.launchMap = 0;
    userInput.logData = 0;
  end
end

% Create signal source
switch userInput.SignalSourceType
  case ExampleSourceType.Captured
    bbFileName = userInput.SignalFilename;
    sigSrc = comm.BasebandFileReader(bbFileName, 'CyclicRepetition', true);
    frontEndSampleRate = sigSrc.SampleRate;
    adsbParam.isSourceRadio = false;
    adsbParam.isSourcePlutoSDR = false;
  case ExampleSourceType.RTLSDRRadio
    frontEndSampleRate = 2.4e6;
    sigSrc = comm.SDRRTLReceiver(userInput.RadioAddress,...
      'CenterFrequency',1090e6,...
      'EnableTunerAGC',false,...
      'TunerGain',60,...
      'SampleRate',frontEndSampleRate,...
      'OutputDataType','single',...
      'FrequencyCorrection',0);
    adsbParam.isSourceRadio = true;
    adsbParam.isSourcePlutoSDR = false;
  case ExampleSourceType.PlutoSDRRadio
      frontEndSampleRate = 12e6;
      sigSrc = sdrrx('Pluto', ...
      'CenterFrequency',1090e6, ...
      'GainSource', 'Manual', ...
      'Gain', 60, ...
      'BasebandSampleRate', frontEndSampleRate,...
      'OutputDataType','single');
      adsbParam.isSourceRadio = true;
      adsbParam.isSourcePlutoSDR = true;
  otherwise
    error('comm:examples:Exit', 'Aborted.');
end

adsbParam.FrontEndSampleRate = frontEndSampleRate;
% We need a sample rate of n*chipRate, where n > 2
chipRate = chipsPerSymbol/symbolDuration;
[n,d]=rat(frontEndSampleRate/chipRate);
if d>2
  interpRate = d;
else
  if n <= 1
    interpRate = 2*d;
  else
    interpRate = d;
  end
end  

adsbParam.InterpolationFactor  = interpRate;
sampleRate = frontEndSampleRate * interpRate;
adsbParam.SampleRate = sampleRate;

adsbParam.SamplesPerSymbol = int32(sampleRate * symbolDuration);
adsbParam.SamplesPerChip = adsbParam.SamplesPerSymbol / chipsPerSymbol;
adsbParam.MaxPacketLength = ...
  int32((preambleDuration+longPacketDuration) ...
  * sampleRate);

% Calculate actual samples per frame based on the target number
maxNumLongPacketsInFrame  = 180;
maxPacketDuration = (preambleDuration+longPacketDuration);
maxPacketLength = maxPacketDuration*frontEndSampleRate;
adsbParam.SamplesPerFrame = maxNumLongPacketsInFrame * maxPacketLength;

% Estimate the number of packets we may receive in a frame. If the packets
% are received without any space in between them, we would get 
% adsbParam.SamplesPerFrame/maxPacketLength number of packets, which is
% the absolute maximum. We will scale it by four.
adsbParam.MaxNumPacketsInFrame = floor(adsbParam.SamplesPerFrame ...
  / maxPacketLength / 4);

adsbParam.FrameDuration = adsbParam.SamplesPerFrame ...
  / frontEndSampleRate;

% Convert seconds to samples
adsbParam.LongPacketLength = ...
  int32(longPacketDuration*sampleRate);
adsbParam.PreambleLength = ...
  int32(preambleDuration*sampleRate);

% Convert seconds to bits
adsbParam.LongPacketNumBits  = ...
  int32(longPacketDuration / symbolDuration);
adsbParam.ShortPacketNumBits = ...
  int32(shortPacketDuration / symbolDuration);

b = rcosdesign(0.5, 3, double(adsbParam.SamplesPerChip));
adsbParam.InterpolationFilterCoefficients = single(b);

adsbParam.SyncSequence = [1 0 1 0 0 0 0 1 0 1 0 0 0 0 0 0];
adsbParam.SyncSequenceLength = length(adsbParam.SyncSequence);
adsbParam.SyncSequenceHighIndices = find(adsbParam.SyncSequence);
adsbParam.SyncSequenceNumHighValues = length(adsbParam.SyncSequenceHighIndices);
adsbParam.SyncSequenceLowIndices = find(~adsbParam.SyncSequence);
adsbParam.SyncSequenceNumLowValues = length(adsbParam.SyncSequenceLowIndices);
syncSignal = reshape(ones(adsbParam.SamplesPerSymbol/2,1)...
  *adsbParam.SyncSequence, 16*adsbParam.SamplesPerSymbol/2, 1);
adsbParam.SyncDownsampleFactor = 2;
adsbParam.SyncFilter = single(flipud(2*syncSignal(1:adsbParam.SyncDownsampleFactor:end)-1));

sigSrc.SamplesPerFrame = adsbParam.SamplesPerFrame;

end