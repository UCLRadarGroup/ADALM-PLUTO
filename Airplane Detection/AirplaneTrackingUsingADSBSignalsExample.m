%% Airplane Tracking Using ADS-B Signals
% This example shows you how to track planes by processing Automatic
% Dependent Surveillance-Broadcast (ADS-B) signals using MATLAB(R) and
% Communications Toolbox(TM). You can either use captured signals or
% receive signals in real time using the RTL-SDR Radio or ADALM-PLUTO
% Radio. The example can show the tracked planes on a map, if you have the
% Mapping Toolbox(TM).

% Copyright 2015-2018 The MathWorks, Inc.

%% Required Hardware and Software
% To run this example using captured signals, you need the following
% software:
%
% * Communications Toolbox(TM)
%
% To receive signals in real time, you also need one of the following SDR
% devices and the corresponding support package Add-On:
%
% * RTL-SDR radio and the corresponding Communications Toolbox Support
% Package for RTL-SDR Radio software Add-On
%
% * ADALM-PLUTO radio and the corresponding Communications Toolbox Support
% Package for Analog Devices® ADALM-PLUTO Radio software Add-On
%
%
% For a full list of Communications Toolbox supported SDR platforms, refer
% to Supported Hardware section of
% <https://www.mathworks.com/discovery/sdr.html _Software Defined Radio
% (SDR) discovery page_>.

%% Background
% ADS-B is a cooperative surveillance technology for tracking aircraft.
% This technology enables an aircraft to periodically broadcast its
% position information (altitude, GPS coordinates, heading, etc.) using the
% Mode-S signaling scheme.
%
% Mode-S is a type of aviation transponder interrogation mode. When an
% aircraft receives an interrogation request, it sends back the
% <https://www.vatsim.net/pilot-resource-centre/general-lessons/transponder-and-squawk-codes
% _squawk code_> of the transponder. This is referred to as Mode 3A. Mode-S
% (Select) is another type of interrogation mode that is designed to help
% avoid interrogating the transponder too often. More details about Mode-S
% can be found in [ <#10 1> ]. This mode is widely adopted in Europe and is
% being phased in for North America.
%
% Mode-S signaling scheme uses squitter messages, which are defined as a
% non-solicited messages used in aviation radio systems. Mode-S has the
% following properties:
%
% * Transmit Frequency: 1090 MHz
% * Modulation: Pulse Position Modulation
% * Data Rate: 1 Mbit/s
% * Short Squitter Length: 56 microseconds
% * Extended Squitter Length: 112 microseconds
%
% Short squitter messages contain the following information:
%
% * Downlink Format (DF)
% * Capability (CA)
% * Aircraft ID (Unique 24-bit sequence)
% * CRC Checksum
%
% Extended squitter (ADS-B) messages contain all the information in a short
% squitter and one of these:
%
% * Altitude
% * Position
% * Heading
% * Horizontal and Vertical Velocity
%
% The signal format of Mode-S has a sync pulse that is 8 microseconds long
% followed by either 56 or 112 microseconds of data as illustrated in the
% following figure.
%
% <<../sdrrModeSSignalFormat.png>>

%% Run the Example
% The default configuration runs using captured data. Later in the example,
% you can set |cmdlineInput| to |1|, then run the example to optionally
% change these configuration settings:
%
% # Reception duration in seconds,
% # Signal source (captured data or RTL-SDR radio or ADALM-PLUTO radio),
% # Optional output methods (map and/or text file).
%
% The example shows the information on the detected airplanes in a tabular
% form as shown in the following figure.
%
% <<../sdrrTrackedFlightsOnApp.png>>
%
% You can also observe the airplanes on a map, if you have a valid license
% for the Mapping Toolbox.
%
% <<../sdrrFlightsOnMap.png>>

%% Receiver Structure
% The following block diagram summarizes the receiver code structure. The
% processing has four main parts: Signal Source, Physical Layer, Message
% Parser, and Data Viewer.
%
% <<../ADSBFlowDiagram.png>>

%%
% *Signal Source*
%
% This example can use three signal sources:
%
% # ''Captured Signal'': Over-the-air signals written to a file and sourced
% from a Baseband File Reader object at 2.4 Msps
% # ''RTL-SDR Radio'': RTL-SDR radio at 2.4 Msps
% # ''ADALM-PLUTO Radio'': ADALM-PLUTO radio at 12 Msps
%
% If you assign ''RTL-SDR'' or ''ADALM-PLUTO'' as the signal source, the
% example searches your computer for the radio you specified, either an
% RTL-SDR radio at radio address '0' or an ADALM-PLUTO radio at radio
% address 'usb:0' and uses it as the signal source.
%
% Here the extended squitter message is 120 micro seconds long, so the
% signal source is configured to process enough samples to contain 180
% extended squitter messages at once, and set |SamplesPerFrame| of the
% signal property accordingly. The rest of the algorithm searches for
% Mode-S packets in this frame of data and outputs all correctly identified
% packets. This type of processing is defined as batch processing. An
% alternative approach is to process one extended squitter message at a
% time. This single packet processing approach incurs 180 times more
% overhead than the batch processing, while it has 180 times less delay.
% Since the ADS-B receiver is delay tolerant, batch processing was used.

%%
% *Physical Layer*
%
% The baseband samples received from the signal source are processed by the
% physical (PHY) layer to produce packets that contain the PHY layer header
% information and raw message bits. The following diagram shows the
% physical layer structure.
%
% <<../ADSB_PHY.png>>
%
% The RTL-SDR radio is capable of using a sampling rate in the range
% [200e3, 2.8e6] Hz. When RTL-SDR radio is the source, the example uses a
% sampling rate of 2.4e6 Hz and interpolates by a factor of 5 to a
% practical sampling rate of 12e6 Hz.
%
% The ADALM-PLUTO radio is capable of using a sampling rate in the range
% [520e3, 61.44e6] Hz. When the ADALM-PLUTO radio is the source, the
% example samples the input directly at 12 MHz.
%
% With the data rate of 1 Mbit/s and a practical sampling rate of 12 MHz,
% there are 12 samples per symbol. The receive processing chain uses the
% magnitude of the complex symbols.
%
% The packet synchronizer works on subframes of data equivalent to two
% extended squitter packets, that is, 1440 samples at 12 MHz or 120 micro
% seconds. This subframe length ensures that a whole extended squitter
% packet is contained in the subframe. The Packet synchronizer first
% correlates the received signal with the 8 microsecond preamble and finds
% the peak value. Then, it validates the synchronization point by checking
% if it matches the preamble sequence, [1 0 0 0 0 0 1 0 1 0 0 0 0 0 0],
% where a '1' represents a high value and a '0' represents a low value.
%
% The Mode-S PPM modulation scheme defines two symbols. Each symbol has two
% chips, where one has a high value and the other has a low value. If the
% first chip is high followed by low chip, this corresponds to the symbol
% being a 1. Alternatively, if the first chip is low followed by high chip,
% then the symbol is 0. The bit parser demodulates the received chips and
% creates a binary message. The binary message is validated using a CRC
% checker. The output of bit parser is a vector of Mode-S physical layer
% header packets that contains the following fields:
%
% * RawBits:  Raw message bits
% * CRCError: FALSE if CRC checks, TRUE if CRC fails
% * Time:     Time of reception in seconds from start of receiver
% * DF:       Downlink format (packet type)
% * CA:       Capability

%%
% *Message Parser*
%
% The message parser extracts data from the raw bits based on the packet
% type as described in [ <#10 2> ]. This example can parse short squitter
% packets and extended squitter packets that contain airborne velocity,
% identification, and airborne position data.

%%
% *Data Viewer*
%
% The data viewer shows the received messages on a graphical user interface
% (GUI). For each packet type, the number of detected packets, the number
% of correctly decoded packets, and the packet error rate (PER) is shown.
% As data is captured, the application lists information decoded from these
% messages in a tabular form.

%% Example Code
% The receiver asks for user input and initializes variables. Then it calls
% the signal source, physical layer, message parser, and data viewer in a
% loop. The loop keeps track of the radio time using the frame duration.

%For the option to change default settings, set |cmdlineInput| to 1.
cmdlineInput = 1;
if cmdlineInput
    % Request user input from the command-line for application parameters
    userInput = helperAdsbUserInput;
else
    load('defaultinputsADSB.mat');
end


%% 


% Calculate ADS-B system parameters based on the user input
[adsbParam,sigSrc] = helperAdsbConfig(userInput);

% Create the data viewer object and configure based on user input
viewer = helperAdsbViewer('LogFileName',userInput.LogFilename, ...
    'SignalSourceType',userInput.SignalSourceType);
if userInput.LogData
    startDataLog(viewer);
end
if userInput.LaunchMap
    startMapUpdate(viewer);
end

% Create message parser object
msgParser = helperAdsbRxMsgParser(adsbParam);

% Start the viewer and initialize radio time
start(viewer)
radioTime = 0;


%%
% Main loop
while radioTime < userInput.Duration


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

    % Process physical layer information (Physical Layer)
    [pkt,pktCnt] = helperAdsbRxPhy(rcv,radioTime,adsbParam);

    % Parse message bits (Message Parser)
    [msg,msgCnt] = msgParser(pkt,pktCnt);

    % View results packet contents (Data Viewer)
    update(viewer,msg,msgCnt,lostFlag);

    % Update radio time
    radioTime = radioTime + adsbParam.FrameDuration;
end

% Stop the viewer and release the signal source
stop(viewer)
release(sigSrc)

%% Further Exploration
% You can further explore ADS-B signals using the ADSBExampleApp app. This
% app allows you to select the signal source and change the duration. To
% launch the app, type |DSBExampleApp| in the MATLAB command window or
% click the link.
%
% You can explore following helper functions for details of the physical
% layer implementation:
%
% *
% <matlab:openExample('comm/AirplaneTrackingUsingADSBSignalsExample','supportingFile','helperAdsbRxPhy.m')
% helperAdsbRxPhy.m>
% *
% <matlab:openExample('comm/AirplaneTrackingUsingADSBSignalsExample','supportingFile','helperAdsbRxPhySync.m')
% helperAdsbRxPhySync.m>
% *
% <matlab:openExample('comm/AirplaneTrackingUsingADSBSignalsExample','supportingFile','helperAdsbRxPhyBitParser.m')
% helperAdsbRxPhyBitParser.m>
% *
% <matlab:openExample('comm/AirplaneTrackingUsingADSBSignalsExample','supportingFile','helperAdsbRxMsgParser.m')
% helperAdsbRxMsgParser.m>

%% Selected Bibliography
% # International Civil Aviation Organization, Annex 10, Volume 4.
% Surveillance and Collision Avoidance Systems.
% # Technical Provisions For Mode S Services and Extended Squitter (Doc
% 9871)