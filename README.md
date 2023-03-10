
ADALM-PLUTO
===
The ADALM-PLUTO Active Learning Module (PlutoSDR) is an easy to use tool available from Analog Devices Inc. (ADI) that can be used to introduce fundamentals of Software Defined Radio (SDR) or Radio Frequency (RF) or Communications as advanced topics in electrical engineering in a self or instructor lead setting. [2]

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
Guides for quick starting with different operating systems are available [here](https://wiki.analog.com/university/tools/pluto/users/quick_start)(not yet updated the driver for macOS after Mojave 10.14), and below is an example worked for Windows 10:

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

### Transmitting and Receiving Signals Simultaneously 

To test its full-duplex function working, I connected its transmitting and receiving connectors together, giving signal input to the transmittor and use spectrum analyzer to display the output from its receiver, as shown in the diagram.

<img width="400" alt="Screenshot 2023-01-10 at 00 09 00" src="https://user-images.githubusercontent.com/103330637/211433255-b1a0522d-1e40-4624-957c-b1e2e3658d16.png">

Looking at the spectrum analyzer, we can find the signals that we are transmitting.
<img width="400" alt="Screenshot 2023-01-10 at 00 08 51" src="https://user-images.githubusercontent.com/103330637/211434740-9d43fd4f-0ec3-4dea-baac-f2cc3039f557.png">


Example 1: FM Broadcast Receiver
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


Example 2: Airplane Tracking
---
We can also use ADALM-PLUTO to track planes by receiving Automatic Dependent Surveillance-Broadcast (ADS-B) signals and processing it using MATLAB® and Communications Toolbox™. This experiment was conducted at UCL Radar Lab, with reference to the example from MathWorks [Airplane Tracking Using ADS-B Signals](https://uk.mathworks.com/help/supportpkg/plutoradio/ug/airplane-tracking-using-ads-b-signals.html).

Before starting, make sure [Communications Toolbox](https://uk.mathworks.com/help/comm/index.html) and [Communications Toolbox Support Package for Analog Devices ADALM-PLUTO Radio](https://uk.mathworks.com/help/supportpkg/plutoradio/index.html) are successfully installed.

To run this, with the ADALM-PLUTO and the atenna connected, use command openExample('comm/AirplaneTrackingUsingADSBSignalsExample') to get the helper files and codes (which are also available in the FM Receiver folder in this repository), enter following information as instructed:

1. Reception duration in seconds - Used 40 seconds as an example.
2. Signal source (captured data or RTL-SDR radio or ADALM-PLUTO radio) - Used 3.ADALM-PLUTO radio

The example shows the information on the detected airplanes in a tabular form as shown in the following figure.

<img width="350" alt="Screenshot 2023-01-09 at 01 05 25" src="https://user-images.githubusercontent.com/103330637/211417724-edbe912f-9b7c-4731-9a46-6c7ae7ba7f36.png">



## Conclusion

In conclusion, ADALM-PLUTO as a full-duplex SDR can be a good and easy-to-use tool for testing with live RF signals, prototyping of custom radio functions and getting hands-on learning of wireless communications concepts.

More projects with MATLAB and Simulink:

[QPSK Transmitter with ADALM-PLUTO Radio](https://uk.mathworks.com/help/supportpkg/plutoradio/ug/qpsk-transmitter-with-adalm-pluto-radio.html)

[Tone Transmitter](https://github.com/matlab-ambassadors-es/ADALM-Pluto-SDR-Hands-On/tree/main/Excercises/MATLAB%20Tone%20Transmitter)

[Spectrum Analysis of Signals](https://uk.mathworks.com/help/supportpkg/plutoradio/ug/spectral-analysis-with-adalm-pluto-radio.html)

[RDS/RBDS and RadioText Plus (RT+) FM Receiver](https://uk.mathworks.com/help/supportpkg/plutoradio/ug/rds-rbds-and-radiotext-plus-rt-fm-receiver.html)

[Modulation Classification with Deep Learning](https://uk.mathworks.com/help/deeplearning/ug/modulation-classification-with-deep-learning.html?searchHighlight=Adalm%20pluto&s_tid=srchtitle_Adalm%2520pluto_49)

[Introductory Communication Systems Course Using SDR](https://uk.mathworks.com/matlabcentral/fileexchange/69417-introductory-communication-systems-course-using-sdr)





## References

[1]“ADALM-PLUTO Evaluation Board | Analog Devices,” Analog.com, 2017. https://www.analog.com/en/design-center/evaluation-hardware-and-software/evaluation-boards-kits/adalm-pluto.html#eb-overview

[2]“ADALM-PLUTO Overview [Analog Devices Wiki],” wiki.analog.com. https://wiki.analog.com/university/tools/pluto

[3]“Introduction to the ADALM-PLUTO [Analog Devices Wiki],” wiki.analog.com. https://wiki.analog.com/university/tools/pluto/users/intro.

[4]“PlutoSDR Quick Start [Analog Devices Wiki],” wiki.analog.com. https://wiki.analog.com/university/tools/pluto/users/quick_start.

[5]“Introductory Communication Systems Course Using SDR,” uk.mathworks.com. https://uk.mathworks.com/matlabcentral/fileexchange/69417-introductory-communication-systems-course-using-sdr.

[6]“FM Broadcast Receiver - MATLAB & Simulink - MathWorks United Kingdom,” uk.mathworks.com. https://uk.mathworks.com/help/supportpkg/plutoradio/ug/fm-broadcast-receiver.html.

[7]“Airplane Tracking Using ADS-B Signals - MATLAB & Simulink - MathWorks United Kingdom,” uk.mathworks.com. https://uk.mathworks.com/help/supportpkg/plutoradio/ug/airplane-tracking-using-ads-b-signals.html.
‌



