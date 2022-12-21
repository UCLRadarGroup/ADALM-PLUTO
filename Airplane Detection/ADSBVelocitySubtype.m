classdef ADSBVelocitySubtype < uint8
  %ADSBVelocitySubtype ADS-B velocity subtype values
  %
  %   See also ADSBExample, adsbRxMsgParser.
  
  %   Copyright 2015 The MathWorks, Inc.
  
  enumeration
    VehicleSubtypeReserved  (0)
    CartesianNormal         (1)
    CartesianSupersonic     (2)
    PolarNormal             (3)
    PolarSupersonic         (4)
    VelocitySubtypeUnset    (8)
  end
end