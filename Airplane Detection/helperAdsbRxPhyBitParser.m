function [pkt,packetCnt] = helperAdsbRxPhyBitParser(packetSamples,...
  packetCnt, syncTimeVec,radioTime,adsbParam)
%helperAdsbRxPhyBitParser ADS-B physical layer bit parser
%   [PKT,C] = helperAdsbRxPhyBitParser(X,C,ST,RT,ADSB) demodulates the
%   synchronized Mode-S packets found in input, X. The first C columns of X
%   contains valid packet samples. ST is a vector of start times of the
%   Mode-S packets for each column of X. RT is the radio time and used to
%   calculate the reception time for packet. ADSB is a structure that
%   contains the configuration information for the ADS-B receiver.
%
%   See also ADSBExample, helperAdsbRxPhy.

% Copyright 2015-2016 The MathWorks, Inc.

%#codegen

% Create an empty packet vector
pkt = repmat(helperAdsbPhyPacket(adsbParam),adsbParam.MaxNumPacketsInFrame,1);

for p=1:packetCnt
  % Demodulated samples into data bits
  xLong = adsbDemod(packetSamples(:,p), adsbParam);
  
  % Start parsing the packet
  pkt(p,1) = parseHeader(xLong, adsbParam);
  
  % Check CRC
  err = adsbCRC(xLong, pkt(p,1).DF, adsbParam);
  
  % Add time stamp and CRC check value (0: correct packet, 1: failed
  % CRC). Add the packet to the packet buffer and increment packet count.
  pkt(p,1).Time = radioTime + double(syncTimeVec(p,1))/adsbParam.SampleRate;
  pkt(p,1).CRCError = err;
end
end

%===============  Helper Functions=============
function z = adsbDemod(y, adsbParam)
%helperAdsbDemod PPM demodulator for Mode-S packets
%   Z=helperAdsbDemod(Y,ADSB) demodulates pulse position modulation (PPM)
%   modulated symbols, Y, and returns the result in a binary-valued column
%   vector, Z. Y must be a numeric column vector. ADSB contains the
%   configuration information for the ADS-B receiver.

sps = adsbParam.SamplesPerSymbol;
spc = adsbParam.SamplesPerChip;

bit1 = [ones(spc,1); -ones(spc,1)];

numBits = size(y,1) / sps;

yTemp = reshape(y, sps, numBits)';

ySoft = yTemp*bit1;
z = uint8(ySoft > 0);
end

function pkt = parseHeader(d, adsbParam)
%helperAdsbParseHeader Parse physical layer header packet
%   PKT = helperAdsbParseHeader(D,ADSB) parses the physical layer header
%   packet samples, D, and returns a header packet, PKT. Raw bits are
%   stored in RawBits field. Parsed fields are
%
%   DF: data format (bits 1-5)
%   CA: Capability (bits 6-8)

pkt = helperAdsbPhyPacket(adsbParam);

pkt.RawBits(:,1) = d;
% Note the implicit type cast through indexing in the following
pkt.DF(1) = sum(uint8([16;8;4;2;1]).*d(1:5,1),'native');  % Downlink format
pkt.CA(1) = sum(uint8([4;2;1]).*d(6:8,1),'native');       % Capability
end

function err = adsbCRC(xLong, DF, adsbParam)
%helperAdsbCRC  CRC check for ADS-B packets
%   [Y,E]=helperAdsbCRC(X) checks the CRC for binary-valued numeric column
%   vector X. Y is the data without the parity bits. When CRC check fails,
%   E is set to 1. When CRC check passes, E is set to 0.

persistent crcDet
if isempty(crcDet)
  crcDet = comm.CRCDetector(...
    [1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 1]);
end

% First check if this is a downlink format (DF) type 17, i.e. ADS-B
% packet or type 11 acquisition squitter. Otherwise, discard the
% packet.
if DF == 11
  xShort = logical(xLong(1:adsbParam.ShortPacketNumBits));
  reset(crcDet);
  [~,err] = crcDet(xShort);
elseif DF == 17
  reset(crcDet);
  [~,err] = crcDet(logical(xLong));
else
  err = true;
end
end