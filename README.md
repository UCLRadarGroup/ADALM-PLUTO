
ADALM-PLUTO
===
The ADALM-PLUTO Active Learning Module (PlutoSDR) is an easy to use tool available from Analog Devices Inc. (ADI) that can be used to introduce fundamentals of Software Defined Radio (SDR) or Radio Frequency (RF) or Communications as advanced topics in electrical engineering in a self or instructor lead setting. [1]

<img width="300" alt="Screenshot 2022-12-21 at 16 27 29" src="https://user-images.githubusercontent.com/103330637/211226955-62117c33-c62c-47d6-a24f-ddda3bca2f0d.png">

## Hardware
To use the ADALM-PLUTO Active Learning Module, you have:
1. 2 RF SMA connectors to connect to instrumentation or an antennas
    - Transmit (labeled 'Tx')
    - Receive (labeled 'Rx')
    - 300 MHz - 3.8 GHz
    - 200 kHz - 20 MHz channel bandwidth
3. USB for your host connectivity (used to stream data)
    - USB 2 (480 Mbits/second)
    - libiio USB device for communicating to the RF device
5. External power
    - It was a possibility during the design of Pluto that the design could have consumed more than 5 unit loads for USB 2 (500mA), and a “backup” power connector was added to mitigate this. This is not necessary for nominal use.


## Quick Start
Guides for quick starting with different operating systems are available [here](https://wiki.analog.com/university/tools/pluto/users/quick_start), and below is an example worked for Windows 10.

1. Install the drivers
    - Before running the installer, ensure that the hardware supported by the drivers is not connected. 
    - This download should support all of : Windows 10, Windows 8.1, Windows 8, Windows 7 Service Pack 1.
    [Windows USB drivers for PlutoSDR and M2k (Windows 32-bit / 64-bit)](https://github.com/analogdevicesinc/plutosdr-drivers-win/releases)
2. Plug the device in to USB, and check things are working.
3. Install IIO-Scope for your host.
    - The ADI IIO Oscilloscope is a cross platform GUI application, which demonstrates how to interface different evaluation boards from within a Linux system.
    - Installation at [IIO-Oscilloscope](https://github.com/analogdevicesinc/iio-oscilloscope/releases).
5. Playback and capture data
6. Connect to your favorite SDR framework (MATLAB and Simulink as examples here).
    - Download the toolbox for ADALM-PLUTO at [ADALM-PLUTO Radio Support from Communications Toolbox](https://uk.mathworks.com/hardware-support/adalm-pluto-radio.html)


Basic Tests
---
### Receiving Signals

In order to test its receiving function, I connected Rx to a Signal Generator which was generating a signal of 80.4 MHz, and setting the receiver to be with center frequency of 80 MHz with Simulink.

<img width="500" alt="Screenshot 2022-12-21 at 16 27 29" src="https://i.imgur.com/agLENyt.png">

From the spectrum analyzer, it is clear that it received a peak of 100 dBm at 0.4MHz above center (which is 80.4MHz), confirmed that the receiving part is working well.

<img width="500" alt="Screenshot 2022-12-21 at 16 27 29" src="https://i.imgur.com/iWHxIjR.png">



### Transmitting Signals

To test its transmitting function, I inputted a waveform of complex envelope with Simulink from MATLAB workspace, and use the oscillocope function from MyDAQ to test its functionality. Here is the design in Simulink.

<img width="350" alt="Screenshot 2022-12-21 at 10 26 02" src="https://user-images.githubusercontent.com/103330637/208882982-79bbe0f5-1279-42b7-b1bf-37ac3aa419cf.png">

Connect the transmitting channel to the input of the MyDAQ, we can observe the transmitted signals on the oscillocope.

<img width="350" alt="Screenshot 2022-12-21 at 10 24 19" src="https://user-images.githubusercontent.com/103330637/208882773-7898df15-94c3-460b-8037-708b83655408.png">

Project 1: FM Broadcast Receiver
---
We can use ADALM-PLUTO to build an FM mono or stereo receiver using MATLAB and Communications Toolbox™. This experiment was conducted at UCL Radar Lab, with reference to the example from MathWorks [FM Broadcast Receiver](https://uk.mathworks.com/help/supportpkg/plutoradio/ug/fm-broadcast-receiver.html). As FM broadcasting uses frequency modulation (FM) to provide high-fidelity sound transmission over broadcast radio channels, Here, as a example, we'll focus on 94.9 MHz which is the FM frequency of BBC Radio London from Crystal Palace.


Before starting, make sure [Communications Toolbox](https://uk.mathworks.com/help/comm/index.html) and [Communications Toolbox Support Package for Analog Devices ADALM-PLUTO Radio](https://uk.mathworks.com/help/supportpkg/plutoradio/index.html) are successfully downloaded and installed.


First, check received signals at 94.9MHz on the FieldFox Microwave Analyzer with the antenna. This is aiming to make sure the enviroment in lab and the antenna is working well for receiving this FM. Just as what we are supposed to see, in range from 94.6 MHz to 95.2MHz, there was a clear peak at the center of 94.9 MHz, which should be from the BBC Radio London.

<img width="350" alt="Screenshot 2023-01-09 at 01 05 25" src="https://user-images.githubusercontent.com/103330637/211227902-c57b890b-48d8-4cfe-829d-655d40353511.png">

Then, get the ADALM-PLUTO and atenna connected and prepared, using command openExample('comm/FMBroadcastReceiverExample') in MATLAB to get helper files (which are also available in the FM Receiver folder in this repository). Enter following information as instructed:
1. Reception duration in seconds - Used 10 as an example
2. Signal source (captured data, RTL-SDR radio, ADALM-PLUTO radio or USRP radio) - Used 3.ADALM-PLUTO radio
3. FM channel frequency - Used 94.9 MHz

The example then plays the received audio over your computer's speakers, with duration of 10 seconds.


Project 2: Airplane Tracking
---
We can also use ADALM-PLUTO to track planes by receiving Automatic Dependent Surveillance-Broadcast (ADS-B) signals and processing it using MATLAB® and Communications Toolbox™. This experiment was conducted at UCL Radar Lab, with reference to the example from MathWorks [FM Broadcast Receiver](https://uk.mathworks.com/help/supportpkg/plutoradio/ug/airplane-tracking-using-ads-b-signals.html).



## References
[1] ADALM-PLUTO Overview, https://wiki.analog.com/university/tools/pluto

[2] Introduction to the ADALM-PLUTO, https://wiki.analog.com/university/tools/pluto/users/intro

[3] FM Broadcast Receiver,https://uk.mathworks.com/help/supportpkg/plutoradio/ug/fm-broadcast-receiver.html


