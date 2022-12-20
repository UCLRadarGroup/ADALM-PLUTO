

ADALM-PLUTO
===


[TOC]

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
Guides for quick starting with different operating systems are available [here](https://wiki.analog.com/university/tools/pluto/users/quick_start).
Below is the example for Windows 10.
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

User story
---



Project Timeline
---


> Read more here: 





## References
[1] Introduction to the ADALM-PLUTO https://wiki.analog.com/university/tools/pluto/users/intro

