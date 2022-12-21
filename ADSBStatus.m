classdef ADSBStatus < uint8
  %ADSBStatus ADS-B vehicle status values
  %
  %   See also ADSBExample, adsbRxMsgParser.
  
  %   Copyright 2015 The MathWorks, Inc.
  
  enumeration
    NoEmergency    (0)
    PermanentAlert (1)
    TemporaryAlert (2)
    SPI            (3)
    StatusUnset    (4)
  end
end