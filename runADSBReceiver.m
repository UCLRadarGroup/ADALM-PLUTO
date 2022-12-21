function radioTime = runADSBReceiver(radioTime, userInput, viewer, doCodegen)
%

%   Copyright 2018-2020 The MathWorks, Inc.

persistent adsbParam sigSrc sigSrcType mapFlag logFlag msgParser

if isempty(logFlag)
    logFlag = 1;
    if (userInput.LogData)
        viewer.LogFileName = userInput.LogFilename;
        startDataLog(viewer);
    end
end

if isempty(mapFlag)
    mapFlag = 1;
    if (userInput.LaunchMap)
        startMapUpdate(viewer);
    end
end

fname1 = '';
fname2 = '';

if ~isempty(sigSrcType) && sigSrcType == ExampleSourceType.Captured 
  [~, fname1] = fileparts(userInput.SignalFilename);
  [~, fname2] = fileparts(sigSrc.Filename);
end

fileNameChanged = ~strcmp(fname1, fname2);

% (re)create objects:
if isempty(adsbParam) || ...
    userInput.SignalSourceType ~= sigSrcType|| ...
    ( userInput.SignalSourceType == ExampleSourceType.Captured && fileNameChanged )
    [adsbParam, sigSrc] = helperAdsbConfig(userInput);
    sigSrcType = userInput.SignalSourceType;
    msgParser = helperAdsbRxMsgParser(adsbParam);
end

if radioTime <= userInput.Duration
 
     if adsbParam.isSourceRadio
        if adsbParam.isSourcePlutoSDR
            [rcv,~,lostFlag] = sigSrc();
        else
            [rcv,~,lost] = sigSrc();
              lostFlag = logical(lost);
        end
    else
        rcv = sigSrc();
        lostFlag = false;
     end
    if doCodegen
        fields = {'isSourceRadio', 'isSourcePlutoSDR'};
        adsbParamPhy = rmfield(adsbParam, fields);
        [pkt,pktCnt] = helperAdsbRxPhy_mex(rcv, radioTime, adsbParamPhy);
        [msg,msgCnt] = msgParser(pkt,pktCnt);
    else
        [pkt,pktCnt] = helperAdsbRxPhy(rcv, radioTime, adsbParam);
        [msg,msgCnt] = msgParser(pkt,pktCnt);
    end

    % View results packet contents (Data Viewer)
    update(viewer, msg, msgCnt, lostFlag);
    radioTime = radioTime + adsbParam.FrameDuration;

else

    if nargout < 1
        release(sigSrc);
        clear logFlag mapFlag;
    end
end
end
% [EOF]
