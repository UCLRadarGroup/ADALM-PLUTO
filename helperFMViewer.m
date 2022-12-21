classdef helperFMViewer < handle
% helperFMViewer FM Viewer 
%   V = helperFMViewer creates an FM viewer object which displays 
%   information on GUI.
%
%   helperFMViewer methods:
%
%   start(V) starts message viewer, V. Once started, the GUI is updated
%   upon every update method call.
%
%   stop(V) stops message viewer, V.
%
%   See also FMReceiverExample.

%   Copyright 2017-2022 The MathWorks, Inc.
    
  properties
    SignalSourceType = ExampleSourceType.Captured
    RadioAddress = '0'
  end
  
  properties (Hidden)
    ParentHandle = -1
    isInApp = false
    errorStatus = ''
  end

  properties (SetAccess = private, Dependent)
    StartTime
  end

  properties (Access = private)
    pRawStartTime = 0
    pFigureHandle = -1
    pGUIHandles
    pProgressBar
    pDispStr
  end

  properties (Constant, Access = private)
    CheckMark = char(10003)
  end
    
  methods
    function obj = helperFMViewer(varargin)   
      p = inputParser;
      addParameter(p, 'SignalSourceType', ExampleSourceType.Captured);
      addParameter(p, 'ParentHandle', -1);
      addParameter(p, 'isInApp', false);
      parse(p, varargin{:});
      obj.SignalSourceType = p.Results.SignalSourceType;
      obj.ParentHandle = p.Results.ParentHandle;
      obj.isInApp = p.Results.isInApp;
      
      renderGUI(obj);

      reset(obj);
    end
    
    function start(obj)
      setStartTime(obj);
      startProgressBar(obj);
    end

    function stop(obj)
      stopProgressBar(obj);
    end

    function reset(obj)
      if ~isvalid(obj.pFigureHandle) 
        renderGUI(obj);
      end
    end

    function setStartTime(obj)
      obj.pRawStartTime = now;
    end

    function value = get.StartTime(obj)
      value = datestr(obj.pRawStartTime);
    end

    function flag = isStopped(obj)
      if (isvalid(obj.pGUIHandles.ProgressBarIndicator) && ...
          strcmp(obj.pGUIHandles.ProgressBarIndicator.String, 'Stopped'))
        flag = true;
      else
        flag = false;
      end
    end

    function updateProgressBarLabel(obj)
      sigSrcType = obj.SignalSourceType;
      if strcmp(sigSrcType, 'Captured')
        sigSrcStr = getString(message('comm_demos:common:SignalSourceFile'));
      else % RTL-SDR radio or Pluto radio
        sigSrcStr = getString(message('comm_demos:common:SignalSourceRadio'));
      end
      dispStr = getString(...
        message('comm_demos:common:ProgressBarReceiving', sigSrcStr));
      obj.pGUIHandles.ProgressBarIndicator.String  = dispStr;
      obj.pDispStr = dispStr;
      drawnow;
    end
    
    function startProgressBar(obj)
      start(obj.pProgressBar.Timer)
      drawnow;
    end

    function stopProgressBar(obj)
      obj.pGUIHandles.ProgressBarIndicator.String  = ...
        getString(message('comm_demos:common:ProgressBarStopped'));
      stop(obj.pProgressBar.Timer)
      drawnow;
    end
    
    
   function startSourceStatus(obj)
      sigSrcType = obj.SignalSourceType;
      if strcmp(sigSrcType, 'Captured')
          dispStr = 'Selected file reader as the signal source';
      else 
        dispStr = 'Checking radio connections...';
          %updateProgressBar FM progress indicator
          count = 0;
          switch count
            case 0
              obj.pGUIHandles.ProgressBarIndicator.String = obj.pDispStr;
            case 1
              obj.pGUIHandles.ProgressBarIndicator.String = ...
                [obj.pDispStr '.'];
            case 2
              obj.pGUIHandles.ProgressBarIndicator.String = ...
                [obj.pDispStr '..'];
            case 3
              obj.pGUIHandles.ProgressBarIndicator.String = ...
                [obj.pDispStr '...'];
            case 4
              obj.pGUIHandles.ProgressBarIndicator.String = ...
                [obj.pDispStr '....'];
            case 5
              obj.pGUIHandles.ProgressBarIndicator.String = ...
                [obj.pDispStr '.....'];
          end

          count = count + 1;
          count = mod(count,6);

          obj.pProgressBar.Count = count;
          drawnow
      end
      obj.pGUIHandles.ProgressBarIndicator.String  = dispStr;
      obj.pDispStr = dispStr;
      drawnow;
    end
    
    function stopSourceStatus(obj)
      sigSrcType = obj.SignalSourceType;
      if strcmp(sigSrcType, 'Captured')
          dispStr = 'Selected signal source: File';
      elseif strcmp(sigSrcType, 'RTLSDRRadio') % RTL-SDR radio
          dispStr = ['Connected to RTL-SDR with radio address: ',obj.RadioAddress];
      elseif strcmp(sigSrcType, 'PlutoSDRRadio') % ADALM-PLUTO radio
          dispStr = ['Connected to PlutoSDR with radio address: ',obj.RadioAddress];
      elseif strcmp(sigSrcType, 'USRPRadio')
          dispStr = ['Connected to USRP with radio address: ',obj.RadioAddress];
      end
      obj.pGUIHandles.ProgressBarIndicator.String  = dispStr;
      obj.pDispStr = dispStr;
      drawnow;
    end
    
    
    function radioConfigStatus(obj)
      sigSrcType = obj.SignalSourceType;
      if ~strcmp(sigSrcType, 'Captured')
          dispStr = 'Configuring radio parameters...';
          obj.pGUIHandles.ProgressBarIndicator.String  = dispStr;
          obj.pDispStr = dispStr;
          drawnow;
      end
    end
    
    function errorDisplay(obj)
     obj.pGUIHandles.ProgressBarIndicator.String  = ...
        obj.errorStatus.message;
    obj.pGUIHandles.ProgressBarIndicator.ForegroundColor = [1 0 0];
       drawnow;
    end
    
    function setDisplay(obj)
        obj.pGUIHandles.ProgressBarIndicator.ForegroundColor = [0 0 1];
    end
    
    function closeGUI(obj)
      if ishandle(obj.pFigureHandle) && isvalid(obj.pFigureHandle)
        close(obj.pFigureHandle)
      end
    end

    function delete(obj)
      if ishandle(obj.pFigureHandle) && isvalid(obj.pFigureHandle)
        close(obj.pFigureHandle)
      end
    end
  end    
  
  methods (Hidden)
    function render(obj)
      renderGUI(obj);
      setappdata(obj.pFigureHandle, 'ViewerHandle', obj);
    end
  end
  
  methods (Access = private)
    function updateGUI(obj)
      if (~(isa(obj.pFigureHandle, 'matlab.ui.Figure') || ...
          strcmpi(obj.pFigureHandle.Type, 'uipanel')) || ...
          ~isvalid(obj.pFigureHandle))
        renderGUI(obj);
        startProgressBar(obj);
      end          
    end

    function renderGUI(obj)
      if ~ishandle(obj.ParentHandle) || ~isvalid(obj.ParentHandle)
        obj.pFigureHandle = uifigure('Position', [100 100 920 300], ...
          'Visible', 'off', ...
          'HandleVisibility', 'on', ...
          'IntegerHandle', 'off', ...
          'NumberTitle', 'off', ...
          'MenuBar', 'none', ...
          'Color', [0.8 0.8 0.8], ...
          'Tag', 'FMViewer', ...
          'Name', getString(message('comm_demos:fm:FMViewerFigName')), ...
          'AutoResizeChildren', 'off');
        % In the case where the DefaultFigureWindowStyle is set to docked.
        set(obj.pFigureHandle, 'WindowStyle', 'normal');
        set(obj.pFigureHandle, 'Position', [100 100 920 300]);
        
        movegui(obj.pFigureHandle, 'east')
        obj.ParentHandle = uipanel(obj.pFigureHandle, ...
            'BorderType', 'none', 'AutoResizeChildren', 'off', ...
            'Units', 'Normalized', 'Position', [0 0 1 1]);
      else
        % In the FM App, the viewer is put in a uipanel object. 
        obj.pFigureHandle = ancestor(obj.ParentHandle, 'UIPanel');
      end
      
      % Set the object handle
      setappdata(obj.pFigureHandle, 'ViewerHandle', obj);
      
      if obj.isInApp
        mcgVW = [0 1 0]; % vertical weights of the main grid container 
        rowIndex = [1 2 3]; 
      else
        mcgVW = [0 0 1 0]; % vertical weights of the main grid container 
        rowIndex = [1 2 3 4];
      end
      % Create main container
      hMainContainer = uipanel('Parent', obj.ParentHandle, ...
          'BorderType', 'none', 'AutoResizeChildren', 'off', ...
          'Units', 'Normalized', 'Position', [0 0 1 1]);

      % (1) Create grid of the main container 
      hMainContainerGrid = siglayout.gridbaglayout(hMainContainer);
      hMainContainerGrid.VerticalGap = 15;
      hMainContainerGrid.HorizontalGap = 5;
      hMainContainerGrid.VerticalWeights = mcgVW;
      hMainContainerGrid.HorizontalWeights = [1 1];

      % (3.[1 2]) Create container for progress bar
      hProgressBarContainer = uipanel(obj.ParentHandle, ...
          'BorderType', 'none', 'AutoResizeChildren', 'off', ...
          'Units', 'Normalized', 'Position', [0 0 1 1]);
      add(hMainContainerGrid, hProgressBarContainer, ...
        rowIndex(1), [1 2], ...
        'Fill', 'Both', ...
        'MinimumHeight', 20);

      % Create grid of the progress bar container
      hProgressBarContainerGrid = ...
        siglayout.gridbaglayout(hProgressBarContainer);
      hProgressBarContainerGrid.VerticalGap = 1;
      hProgressBarContainerGrid.HorizontalGap = 1;
      hProgressBarContainerGrid.HorizontalWeights = 1;

      % (3.[1 2].1) Create container for progress bar indicator
      hProgressBarIndicatorContainer = uipanel(hProgressBarContainer, ...
          'BorderType', 'none', 'AutoResizeChildren', 'off', ...
          'Units', 'Normalized', 'Position', [0 0 1 1]);
      add(hProgressBarContainerGrid, hProgressBarIndicatorContainer, ...
        1, 1, ...
        'Fill', 'Both', ...
        'MinimumHeight', 20, ...
        'MinimumWidth', 230);

      % Create grid of the progress bar indicator container
      hProgressBarIndicatorContainerGrid = ...
        siglayout.gridbaglayout(hProgressBarIndicatorContainer);
      hProgressBarIndicatorContainerGrid.VerticalGap = 1;
      hProgressBarIndicatorContainerGrid.HorizontalGap = 5;
      hProgressBarIndicatorContainerGrid.VerticalWeights = 1;

      % (3.[1 2].1.1) Progress bar indicator
      obj.pGUIHandles.ProgressBarIndicator = ...
        uicontrol(hProgressBarIndicatorContainer, ...
        'Style', 'text', ...
        'String', 'Stopped', ...
        'HorizontalAlignment', 'left', ...
        'ForegroundColor', 'blue', ...
        'Tag', 'ProgressBarIndicator');
      add(hProgressBarIndicatorContainerGrid, ...
        obj.pGUIHandles.ProgressBarIndicator, ...
        1, 1, ...
        'Fill', 'Both', ...
        'MinimumHeight', obj.pGUIHandles.ProgressBarIndicator.Extent(4), ...
        'MinimumWidth', obj.pGUIHandles.ProgressBarIndicator.Extent(3));

      initProgressBar(obj);
      
      obj.pFigureHandle.DeleteFcn = @obj.cleanupGUI;

      drawnow;

      obj.pFigureHandle.Visible = 'on';
    end
    

    function initProgressBar(obj)
      % Create a timer object for progress indicator
      count = 0;
      progressBar.Count = count;

      progressBar.Timer = timer(...
        'BusyMode', 'drop', ...
        'ExecutionMode', 'fixedRate', ...
        'Name', 'FMAnimation', ...
        'ObjectVisibility', 'off', ...
        'Period', 0.25, ...
        'StartDelay', 1, ...
        'TimerFcn', @obj.updateProgressBar);

      obj.pProgressBar = progressBar;
    end

    function updateProgressBar(obj, ~, ~)
      %updateProgressBar FM progress indicator
      count = obj.pProgressBar.Count;
      switch count
        case 0
          obj.pGUIHandles.ProgressBarIndicator.String = obj.pDispStr;
        case 1
          obj.pGUIHandles.ProgressBarIndicator.String = ...
            [obj.pDispStr '.'];
        case 2
          obj.pGUIHandles.ProgressBarIndicator.String = ...
            [obj.pDispStr '..'];
        case 3
          obj.pGUIHandles.ProgressBarIndicator.String = ...
            [obj.pDispStr '...'];
        case 4
          obj.pGUIHandles.ProgressBarIndicator.String = ...
            [obj.pDispStr '....'];
        case 5
          obj.pGUIHandles.ProgressBarIndicator.String = ...
            [obj.pDispStr '.....'];
      end

      count = count + 1;
      count = mod(count,6);

      obj.pProgressBar.Count = count;

      drawnow
    end
    
    function cleanupGUI(obj,~,~)
      if (isa(obj.pProgressBar.Timer,'timer') && isvalid(obj.pProgressBar.Timer))
        stop(obj.pProgressBar.Timer)
        delete(obj.pProgressBar.Timer)
      end
    end
  end
end


% [EOF]
