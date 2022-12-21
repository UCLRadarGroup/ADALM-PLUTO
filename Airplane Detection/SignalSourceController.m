classdef SignalSourceController < matlab.System
  %SignalSourceController Signal source controller
  
  %   Copyright 2016-2022 The MathWorks, Inc.

  properties (SetObservable, AbortSet, Nontunable)
    %Duration Specify run time in seconds
    Duration = 10
    %SignalSource Specify signal source you want to use
    SignalSource = 'File'
    %SignalFilename Specify captured signal file name
    SignalFilename = 'example.bb'
  end
  
  properties (Access = public, Nontunable)
    %ExampleTitle is used to set the name and tag of the GUI.
    ExampleTitle
  end
  properties (SetObservable, AbortSet, Nontunable, Dependent)
    %RadioAddress Specify address of the radio you want to use
    RadioAddress
  end
  
  properties (Dependent, SetAccess=private)
    SignalSourceType
  end

  properties (Access=private)
    RTLSDRRadioAddress
    PlutoSDRRadioAddress
    USRPRadioAddress
  end
  
  properties(Hidden, Transient)
    SignalSourceSet = matlab.system.internal.DynamicStringSet({'File','RTL-SDR',...
        'ADALM-PLUTO','USRP'});
    RadioAddressSet = matlab.system.internal.DynamicStringSet({'0'});
  end
  
  methods
    
    function obj = SignalSourceController(varargin)
      obj.SignalSourceSet = matlab.system.internal.DynamicStringSet({'File','RTL-SDR',...
        'ADALM-PLUTO', 'USRP'});
      obj.RadioAddressSet = matlab.system.internal.DynamicStringSet({'0'});
      setProperties(obj, nargin, varargin{:});
    end
    
    function set.Duration(obj, aDuration)
        obj.Duration = aDuration;
        try
            validateattributes(aDuration,{'numeric'},...
                {'nonempty','scalar','positive','real','nonnan'},...
                '', 'Duration');
        catch me
            handleErrorsInApp(obj,me)
      end
    end
     
    function set.SignalSource(obj, aSource)
        if strcmp(aSource, 'RTL-SDR')
            try
                radioAddresses = isRadioInstalled(obj, aSource);
                if isempty(radioAddresses)
                    error(message('comm_demos:common:RadioNotFoundApp','RTL-SDR'));
                else
                    obj.SignalSource = aSource;
                    updateRadioAddress(obj,radioAddresses);
                end
            catch me
                handleErrorsInApp(obj,me)   
            end
            
        elseif strcmp(aSource, 'ADALM-PLUTO')
            try
                radioAddresses = isRadioInstalled(obj, aSource);
                if isempty(radioAddresses)
                    error(message('comm_demos:common:RadioNotFoundApp','ADALM-PLUTO'));
                else
                    obj.SignalSource = aSource;
                    updateRadioAddress(obj,radioAddresses);
                end
            catch me
                handleErrorsInApp(obj,me)   
            end

        elseif strcmp(aSource, 'USRP')
            try
                radioAddresses = isRadioInstalled(obj, aSource);
                if isempty(radioAddresses)
                    error(message('comm_demos:common:RadioNotFoundApp','USRP'));
                else
                    obj.SignalSource = aSource;
                    updateRadioAddress(obj,radioAddresses);
                end
            catch me
                handleErrorsInApp(obj,me)   
            end

        else % File
            obj.SignalSource = aSource;
        end
    end
    
    function set.SignalFilename(obj, aFilename)
        try
            aFilename = convertStringsToChars(aFilename);
            validateattributes(aFilename,{'char'},...
                {'nonempty','row'},...
                '', 'SignalFilename');
            obj.SignalFilename = aFilename;
        catch me
            handleErrorsInApp(obj,me)
        end
    end
    
    function out = isRadioInstalled(obj, aSource)
        if strcmp(aSource, 'RTL-SDR')
            if ~exist('sdrrroot', 'file')
                error(message('comm_demos:common:NoSupportPackageApp', ...
                        'Communications Toolbox Support Package for RTL-SDR Radio'));
            else
                out = helperFindRTLSDRRadio();
            end
        elseif strcmp(aSource, 'ADALM-PLUTO')
            if isempty(which('plutoradio.internal.getRootDir'))
            error(message('comm_demos:common:NoSupportPackageApp', ...
                        'Communications Toolbox Support Package for ADALM-PLUTO Radio'));
            else
                 out = helperFindPlutoSDR();
            end
        elseif strcmp(aSource, 'USRP')
            if ~exist('sdruroot', 'file')
            error(message('comm_demos:common:NoSupportPackageApp', ...
                        'Communications Toolbox Support Package for USRP Radio'));
            else
                 out = helperFindUSRPRadio();
            end
        end
    end         

    function handleErrorsInApp(obj,errormsg)
        errordlg(errormsg.message,obj.ExampleTitle,'Modal');
        return
    end
    
    function aType = get.SignalSourceType(obj)
      switch obj.SignalSource
        case 'File'
          aType = ExampleSourceType.Captured;
        case 'RTL-SDR'
          aType = ExampleSourceType.RTLSDRRadio;
        case 'Simulated signal'
          aType = ExampleSourceType.Simulated;
        case 'ADALM-PLUTO'
          aType = ExampleSourceType.PlutoSDRRadio;
        case 'USRP'
          aType = ExampleSourceType.USRPRadio;  
      end
    end
    
    function aRadioAddr = get.RadioAddress(obj)
      if strcmp(obj.SignalSource,'ADALM-PLUTO')
        aRadioAddr = obj.PlutoSDRRadioAddress;
      elseif strcmp(obj.SignalSource,'RTL-SDR')
        aRadioAddr = obj.RTLSDRRadioAddress;
      else
        aRadioAddr = obj.USRPRadioAddress;
      end
    end
    
    function set.RadioAddress(obj,aValue)
      if strcmp(obj.SignalSource,'RTL-SDR')
        obj.RTLSDRRadioAddress = aValue;
      elseif strcmp(obj.SignalSource,'ADALM-PLUTO')
        obj.PlutoSDRRadioAddress = aValue;
      else
        obj.USRPRadioAddress = aValue;
      end
    end   
  end
  
  methods (Access = private)
    function updateRadioAddress(obj,radioAddresses)
      if any(strcmp(radioAddresses,obj.RadioAddress))  
        obj.RadioAddressSet.changeValues(radioAddresses,...
          obj,'RadioAddress',obj.RadioAddress);  
      else % if previous selected radio address is not list
        obj.RadioAddressSet.changeValues(radioAddresses,...
          obj,'RadioAddress',radioAddresses{1});  
      end                
    end
  end
  
  
  methods
     function getDuration(obj)
          tEnd = input(...
              sprintf('\n> Specify run time in seconds [%f]: ', obj.Duration));
          if isempty(tEnd)
              tEnd = obj.Duration;
          end
          validateattributes(tEnd,{'numeric'},{'scalar','real','positive','nonnan'}, '', 'Run Time');
          obj.Duration = tEnd;
      end
      
      function getSignalSource(obj)
          value = obj.SignalSource;
          defaultValue = obj.SignalSourceSet.getIndex(value);
          options = obj.SignalSourceSet.getAllowedValues;
          prompt = sprintf('\n> Enter signal source.');
          for q=1:length(options)
              prompt = sprintf('%s\n>\t%d) %s', ...
                  prompt, q, options{q});
          end
          prompt = sprintf('%s\n>\n> Signal source [%d]: ', ...
              prompt, defaultValue);
          signalSourceNum = input(prompt);
          if isempty(signalSourceNum)
              signalSourceNum = 1;
          end
          if signalSourceNum > length(options)
              error(message('comm_demos:common:IndexExceedsOptions', ...
                  'Signal source', length(options)));
          end
          if strcmp(options{signalSourceNum},'RTL-SDR')
              radioAddresses = helperFindRTLSDRRadio();
              if isempty(radioAddresses)
                  error(message('comm_demos:common:RTLSDRRadioNotFound'));
              end
          elseif strcmp(options{signalSourceNum},'ADALM-PLUTO')
              radioAddresses = helperFindPlutoSDR();
              if isempty(radioAddresses)
                  error(message('comm_demos:common:PlutoRadioNotFound'));
              end
          elseif strcmp(options{signalSourceNum}, 'USRP')
            radioAddresses = helperFindUSRPRadio();
              if isempty(radioAddresses)
                  error('Cannot find a USRP radio. Check your radio connection and try again.');
              end
         end
          
          obj.SignalSource = options{signalSourceNum};
          
          switch obj.SignalSource
              case 'File'
                  filenameAns = input(...
                      sprintf('\n> Enter captured signal file name [%s]: ',obj.SignalFilename), 's');
                  if ~isempty(filenameAns)
                      obj.SignalFilename = filenameAns;
                  end
              case 'RTL-SDR'
                  fprintf('\nSearching for radios connected to your host computer...\n');
                  radioAddress = obj.RadioAddressSet.getAllowedValues;
                  
                  radioCnt = 0;
                  msg = ['\n> Enter the number corresponding to the '...
                      'radio you would like to use.'];
                  for p=1:length(radioAddress)
                      radioCnt = radioCnt + 1;
                      msg = sprintf('%s\n>\t%d) %s [Radio Address: %s]', msg, radioCnt, ...
                          'RTL-SDR', radioAddress{p});
                  end
                  
                  if radioCnt > 0
                      % Found at least one radio. Ask user which one they want to use
                      radioNum = input(sprintf('%s\n>> Radio [1]: ', msg));
                      if isempty(radioNum)
                          radioNum = 1;
                      end
                      if radioNum <= radioCnt
                          obj.RadioAddress = radioAddress{radioNum};
                      else
                          error(message('comm_demos:common:IndexExceedsOptions', ...
                              'Radio', radioCnt));
                      end
                  else
                      error(message('comm_demos:common:RTLSDRRadioNotFound'));
                  end
          end
      end
  end
  methods(Access=protected)
      
      function flag = isInactivePropertyImpl(obj, prop)
          switch prop
              case 'RadioAddress'
                  if strcmp(obj.SignalSource, 'File') || strcmp(obj.SignalSource, 'Simulated signal')
                      flag = true;
                  else
                      flag = false;
                  end
              case 'SignalFilename'
                  if strcmp(obj.SignalSource, 'File')
                      flag = false;
                  else
                      flag = true;
                  end

              case 'SignalSourceType'
                  flag = true;
              otherwise
                  flag = false;
          end
      end
  end
end
