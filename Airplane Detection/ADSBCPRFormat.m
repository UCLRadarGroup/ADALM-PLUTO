classdef ADSBCPRFormat < uint8
  %ADSBCPRFormat ADS-B CPR Format values
  %
  %   See also ADSBExample, adsbRxMsgParser.
  
  %   Copyright 2015 The MathWorks, Inc.
  
  enumeration
    Even           (0)
    Odd            (1)
    CPRFormatUnset (3)
  end
end