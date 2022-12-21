function userInput = helperFMUserInput
%helperFMUserInput Gather user input for FM Broadcast Receiver Example
%   UIN = helperFMUserInput displays questions on the MATLAB command
%   window and collects user input, UIN.
%
%   UIN is a structure of user inputs with following fields:
%
%   * Duration:           Run time of example (seconds)
%   * SourceType:         Source type
%   * RadioAddress:       Address string for radio (if radio is selected)
%   * Channel frequency:  FM channel frequency (Hz)
%
%   See also FMReceiverExample

%   Copyright 2016-2021 The MathWorks, Inc.

controller = helperFMReceiverController;
controller.Duration = 10.8;
userInput = getUserInput(controller);
