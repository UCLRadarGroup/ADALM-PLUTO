classdef (TunablesDetermineInactiveStatus) LogDataController < matlab.System
  %LogDataController Log data controller
  
  %   Copyright 2016-2022 The MathWorks, Inc.
  
  properties (SetObservable, AbortSet)
    %LogData Do you want to log aircraft information to a text file?
    LogData = false;
  end
  
  properties (SetObservable, AbortSet, Nontunable)
    %LogFilename Specify log file name 
    LogFilename = 'untitled.txt'
  end
  
  methods
    function obj = LogDataController(varargin)
      setProperties(obj, nargin, varargin{:});
    end
    
    function set.LogData(obj, aFlag)
      validateattributes(aFlag,{'logical'},...
        {'scalar'},...
        '', 'LogData');
      obj.LogData = aFlag;
    end
    
    function set.LogFilename(obj, aName)
      aName = convertStringsToChars(aName);  
      validateattributes(aName,{'char'},...
        {'nonempty','row'},...
        '', 'LogFilename');
      obj.LogFilename = aName;
    end
  end
  
  methods
    function getLogData(obj)
      logDataAns = input(...
        '\n> Do you want to log decoded information to a text file [n]: ', 's');
      if isempty(logDataAns)
        obj.LogData = false;
      else
        if strcmpi(logDataAns, 'y')
          obj.LogData = true;
        elseif strcmpi(logDataAns, 'n')
          obj.LogData = false;
        else
          error(message('comm_demos:common:InvalidLoggingOption'));
        end
      end
    end
     function getLogFilename(obj)
      if obj.LogData
        filenameAns = input(...
          sprintf('> Enter log file name [%s]: ',obj.LogFilename), 's');
        if ~isempty(filenameAns)
          obj.LogFilename = filenameAns;
        end
      end
    end
  end
  methods(Access=protected)
    function flag = isInactivePropertyImpl(obj, prop)
      switch prop
        case 'LogFilename'
          if obj.LogData
            flag = false;
           else
             flag = true;
           end
        otherwise
          flag = false;
      end
    end
  end
end
