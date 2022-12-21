classdef ADSBVehicleCategory < uint8
  %ADSBVehicleCategory ADS-B velocity category values
  %
  %   See also ADSBExample, adsbRxMsgParser.
  
  %   Copyright 2015 The MathWorks, Inc.
  
  enumeration
    NoData                    (0)
    Light                     (1)
    Medium                    (2)
    Heavy                     (3)
    HighVortex                (4)
    VeryHeavy                 (5)
    HighPerformanceHighSpeed  (6)
    Rotorcraft                (7)
    Glider                    (8)
    LighterThanAir            (9)
    Parachute                 (10)
    HangGlider                (11)
    UAV                       (12)
    Spacecraft                (13)
    EmergencyVehicle          (14)
    ServiceVehicle            (15)
    FixedTetheredObstruction  (16)
    ClusterObstacle           (17)
    LineObstacle              (18)
    VehicleCategoryReserved   (19)
    VehicleCategoryUnset      (20)
  end
end