function pkt = helperAdsbPhyPacket(adsbParam)
%helperAdsbPhyPacket ADS-B physical layer packet structure
%   P = helperAdsbPhyPacket returns ADS-B physical layer packet structure
%   with the following fields:
%
%   RawBits           : Raw message in bits
%   CRCError          : CRC checksum (1: error, 0: no error)
%   Time              : Packet reception time
%   DF                : Downlink format
%   CA                : Capability
%
%   See also ADSBExample, helperAdsbRxPhy.

%   Copyright 2015-2016 The MathWorks, Inc.

%#codegen

pkt.RawBits = coder.nullcopy(zeros(112,1,'uint8'));   
%pkt.RawBits = coder.nullcopy(zeros(adsbParam.LongPacketNumBits,1,'uint8'));   
                                    % Raw message
pkt.CRCError = true;                % CRC checksum (1: error, 0: no error)
pkt.Time = 0;                       % Packet reception time
pkt.DF = uint8(0);                  % Downlink format
pkt.CA = uint8(0);                  % Capability
end
