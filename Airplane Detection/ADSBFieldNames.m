classdef ADSBFieldNames < uint8
  %ADSBFieldNames ADS-B message packet field names
  %
  %   See also ADSBExample, adsbViewer.
  
  %   Copyright 2015 The MathWorks, Inc.
  
  enumeration
    Current               (1)
    Message               (2)
    Time                  (3)
    CRC                   (4)
    DF                    (5)
    CA                    (6)
    ICAO24                (7)
    TC                    (8)
    VehicleCategory       (9)
    FlightID              (10)
    Status                (11)
    DiversityAntenna      (12)
    Altitude              (13)
    UTCSynchronized       (14)
    Longitude             (15)
    Latitude              (16)
    Subtype               (17)
    IntentChange          (18)
    IFRCapability         (19)
    VelocityUncertainty   (20)
    Speed                 (21)
    Heading               (22)
    HeadingSymbol         (23)
    VerticalRateSource    (24)
    VerticalRate          (25)
    TurnIndicator         (26)
    GHD                   (27)
  end
end