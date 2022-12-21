function [pkt,pktCnt] = helperAdsbRxPhy(y,radioTime,adsbParam)
%helperAdsbRxPhy  ADS-B receiver physical layer
%   [P,C] = helperAdsbRxPhy(Y,RT,ADSB) demodulates short and extended
%   squitter (ADS-B) packets in the received signal, Y. RT is the relative
%   radio time. ADSB contains the configuration information for the ADS-B
%   receiver. The function outputs a vector of ADS-B physical layer
%   packets, P. C is the number of valid packets in P.
%
%   See also ADSBExample, helperAdsbRxMsgParser.

%   Copyright 2015-2016 The MathWorks, Inc.

%#codegen

persistent packetSync

if isempty(packetSync)
  packetSync = helperAdsbRxPhySync(adsbParam);
end

% Interpolate to get an integer number of samples per chip
z = helperAdsbRxPhyInterpolator(y, adsbParam);

% Convert sample values to energy values
zAbs = abs(z).^2;

% Search for a Mode-S packet and return samples for the found packet
[pktSamples, pktCnt, syncTime] = packetSync(zAbs);

% Extract Mode-S header information and raw data bits
[pkt,pktCnt] = helperAdsbRxPhyBitParser(pktSamples, pktCnt, syncTime, ...
  radioTime, adsbParam);

end
