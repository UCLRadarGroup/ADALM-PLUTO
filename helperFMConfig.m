function [fmRxParams,sigSrc] = helperFMConfig(varargin)
%helperFMConfig FM broadcast receiver system parameters
%   P = helperFMConfig(UIN) returns FM broadcast receiver system
%   parameters, P. UIN is the user input structure returned by the
%   helperFMUserInput function.
%
%   See also FMReceiverExample.

%   Copyright 2015-2021 The MathWorks, Inc.

if nargin == 0
    % Set defaults
    userInput.Duration = 10.8;
    userInput.SignalSourceType = ExampleSourceType.Captured;
    userInput.SignalFilename = 'rbds_capture.bb';
    userInput.RadioAddress = '0';
    userInput.CenterFrequency = 102.5e6;
else
    tmp = varargin{1};
    if isstruct(tmp)
        userInput = varargin{1};
    else
        % Set defaults
        userInput.Duration = 10.8;
        userInput.SignalSourceType = ExampleSourceType.Captured;
        userInput.SignalFilename = 'rbds_capture.bb';
        userInput.RadioAddress = '0';
        userInput.CenterFrequency = 102.5e6;
    end
end

% Parameters specific to USRP Radio
fmRxParams.MasterClockRate = 100e6; 
fmRxParams.DecimationFactor = 500;
fmRxParams.Gain = 31;

% Create signal source
switch userInput.SignalSourceType
    case ExampleSourceType.Captured
        sigSrc = comm.BasebandFileReader(userInput.SignalFilename, 'CyclicRepetition', true);
        frontEndSampleRate = sigSrc.SampleRate;
        fmRxParams.isSourceRadio = false;
    case ExampleSourceType.RTLSDRRadio
        frontEndSampleRate = 228e3;
        sigSrc = comm.SDRRTLReceiver(userInput.RadioAddress,...
            'CenterFrequency',userInput.CenterFrequency,...
            'EnableTunerAGC',true,...
            'SampleRate',frontEndSampleRate,...
            'OutputDataType','single',...
            'FrequencyCorrection',0);
        fmRxParams.isSourceRadio = true;
        fmRxParams.isSourcePlutoSDR = false;
        fmRxParams.isSourceUsrpRadio = false;
    case ExampleSourceType.PlutoSDRRadio
        frontEndSampleRate = 228e3;
        sigSrc = sdrrx('Pluto', ...
            'CenterFrequency', userInput.CenterFrequency, ...
            'GainSource', 'AGC Slow Attack', ...
            'BasebandSampleRate', frontEndSampleRate,...
            'OutputDataType','single');
        fmRxParams.isSourceRadio = true;
        fmRxParams.isSourcePlutoSDR = true;
        fmRxParams.isSourceUsrpRadio = false;
    case ExampleSourceType.USRPRadio
        frontEndSampleRate = 200e3;
        connectedRadios = findsdru(userInput.RadioAddress);
        if strncmp(connectedRadios(1).Status, 'Success', 7)
            platform = connectedRadios(1).Platform;
            switch connectedRadios(1).Platform
                case {'B200','B210'}
                    address = connectedRadios(1).SerialNum;
                case {'N200/N210/USRP2','X300','X310','N300','N310','N320/N321'}
                    address = connectedRadios(1).IPAddress;
            end
        else
            address = '192.168.10.2';
            platform = 'N200/N210/USRP2';
        end
        switch platform
            case {'B200','B210'}
                sigSrc = comm.SDRuReceiver(...
                    'Platform', platform, ...
                    'SerialNum', address, ...
                    'MasterClockRate', 20e6);
            case {'X300','X310','N320/N321'}
                sigSrc = comm.SDRuReceiver(...
                    'Platform', platform, ...
                    'IPAddress', address, ...
                    'MasterClockRate', 200e6);
            case {'N300','N310'}
                sigSrc = comm.SDRuReceiver(...
                    'Platform', platform, ...
                    'IPAddress', address, ...
                    'MasterClockRate', 153.6e6);
            case {'N200/N210/USRP2'}
                sigSrc = comm.SDRuReceiver(...
                    'Platform', platform, ...
                    'IPAddress', address, ...
                    'MasterClockRate', 100e6);
        end
        sigSrc.DecimationFactor = sigSrc.MasterClockRate/frontEndSampleRate;
        sigSrc.Gain = 31;
        sigSrc.CenterFrequency = userInput.CenterFrequency;
        sigSrc.OutputDataType = 'single';
        fmRxParams.MasterClockRate = sigSrc.MasterClockRate;
        fmRxParams.DecimationFactor = sigSrc.DecimationFactor;
        fmRxParams.Gain = sigSrc.Gain;
        fmRxParams.isSourceRadio = true;
        fmRxParams.isSourcePlutoSDR = false;
        fmRxParams.isSourceUsrpRadio = true;
    otherwise
        error('comm_demos:common:Exit', 'Aborted.');
end

fmRxParams.FrequencyDeviation = 75e3; % Hz
fmRxParams.FilterTimeConstant = 75e-6; % Seconds
fmRxParams.AudioSampleRate = frontEndSampleRate/5; % Hz, make sure rate is friendly with default BB
fmRxParams.SignalFilename = userInput.SignalFilename;

fmDemod = comm.FMBroadcastDemodulator(...
    'SampleRate', frontEndSampleRate, ...
    'FrequencyDeviation', fmRxParams.FrequencyDeviation, ...
    'FilterTimeConstant', fmRxParams.FilterTimeConstant);
fmInfo = info(fmDemod);

% Frame length of SDRr Receiver and buffer size of FM Broadcast Demodulator
% Frame length must be an integer multiple of FM DecimationFactor
N = 3840;
frontEndSamplesPerFrame = ...
    N*fmInfo.AudioDecimationFactor;
fmRxParams.BufferSize = frontEndSamplesPerFrame;

fmRxParams.FrontEndFrameTime = ...
    frontEndSamplesPerFrame / frontEndSampleRate;

sigSrc.SamplesPerFrame = frontEndSamplesPerFrame;

fmRxParams.FrontEndSampleRate = frontEndSampleRate;
fmRxParams.FrontEndSamplesPerFrame = frontEndSamplesPerFrame;
