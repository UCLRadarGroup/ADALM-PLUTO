classdef helperFMReceiverController < ExampleController
%

%   Copyright 2016-2022 The MathWorks, Inc.
  properties (SetObservable, AbortSet)
    %CenterFrequency FM channel frequency (Hz)
    CenterFrequency = 102.5e6
  end

  properties (Access=protected, Constant)
    ExampleName = 'FMBroadcastReceiverExample'
    ModelName = 'FMReceiverSimulinkExample'
    CodeGenCallback = @generateCodeCallback;
    
    MinContainerWidth = 290
    MinContainerHeight = 370

    Column1Width = 120
    Column2Width = 130
  end

  properties (Access=protected)
    HTMLFilename
    RunFunction = 'runFMReceiver'
  end
  
  methods
    function obj = helperFMReceiverController(varargin)
      obj@ExampleController(varargin{:});
      obj.HTMLFilename = 'comm/FMBroadcastReceiverExample';
      obj.SignalFilename = 'rbds_capture.bb';
      obj.ExampleTitle = 'FM Receiver';
    end
    
    function set.CenterFrequency(obj, aFrequency)
        try
            validateattributes(aFrequency,{'numeric'},...
                {'scalar','real','finite','nonnan','positive'},...
                '', 'CenterFrequency');
            obj.CenterFrequency = aFrequency;
        catch me
            handleErrorsInApp(obj.SignalSourceController,me)
        end
    end
  end
  
  methods
      function flag = isInactiveProperty(obj,prop)
          switch prop
              case 'CenterFrequency'
                  if strcmp(obj.SignalSourceController.SignalSource, 'File')
                      flag = true;
                  else
                      flag = false;
                  end
              otherwise
                  flag = isInactiveProperty@ExampleController(obj, prop);
          end
      end
  end
  
  methods (Access = protected)
    
    function addWidgets(obj)
      obj.addRow('Duration', 'Duration (s)', 'edit', 'numeric');
      obj.addRow('SignalSource', 'Signal source', 'popupmenu');
      obj.addRow('RadioAddress', 'Radio address', 'popupmenu');
      obj.addRow('SignalFilename', 'Signal file name', 'edit', 'text');
      obj.addRow('CenterFrequency', 'Center frequency', 'edit', 'numeric');
    end
    
    function getUserInputImpl(obj)
        getCenterFrequency(obj);
    end
        
    function getCenterFrequency(obj)
      if ~isInactiveProperty(obj, 'CenterFrequency')
        freq = input(...
          sprintf('\n> Enter FM channel frequency (Hz) [%e]: ',...
          obj.CenterFrequency));
        if isempty(freq)
          freq = obj.CenterFrequency;
        end
        obj.CenterFrequency = freq;
      end
    end
  end
end

function generateCodeCallback(userInput)
  % CODEGEN COMMANDS 
    fmRxParams = helperFMConfig(userInput);
    codegen(which('helperFMDemodulator'), '-args', {complex(zeros(fmRxParams.FrontEndSamplesPerFrame, 1)), coder.Constant(fmRxParams)})
end
