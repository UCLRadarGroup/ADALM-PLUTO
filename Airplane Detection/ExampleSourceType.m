classdef ExampleSourceType < uint8
  %ExampleSourceType CST Example source type values
  %
  %   See also ADSBExample, FMReceiverExample, FRSReceiverExample.
  
  %   Copyright 2016-2022 The MathWorks, Inc.
  
  enumeration
    Simulated     (0)
    Captured      (1)
    RTLSDRRadio	  (2)
    PlutoSDRRadio (3)
    USRPRadio     (4)
  end
end
