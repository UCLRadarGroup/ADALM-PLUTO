classdef ExampleController < handle & matlab.mixin.SetGet
  %ExampleController  controller
  %   C=ExampleController creates an example controller object.

  %   Copyright 2016-2022 The MathWorks, Inc.

  properties (Abstract, Access = protected, Constant)
    %ExampleName 
    %  ExampleName is used for viewing the MATLAB code      
    ExampleName
    %ModelName
    %  ModelName is used to set the parameters of the model blocks, and run
    %  the Simulink model.
    ModelName
    %CodeGenCallback 
    %  CodeGenCallback is the handle of a function defined in a client
    %  class. CodeGenCallback is used to generate code. 
    CodeGenCallback
    %MinContainerWidth minimum width of the GUI
    %  MinContainerWidth is used to set the width of the ParentHandle
    %  just in case there is no ParentHandle
    MinContainerWidth
    %MinContainerHeight minimum height of the GUI
    %  MinContainerHeight is used to set the height of the ParentHandle
    %  just in case there is no ParentHandle
    MinContainerHeight
    
    %Column1Width width of the first column of the ParamHandle
    %  Column1Width sets the width of the labels of the widgets which are
    %  defined in a client.
    Column1Width
    Column2Width
  end
  
  properties ( Dependent , Hidden )
      FileLineNumber
      %  FileLineNumber is used to point to the line at which the MATLAB
      %  script file starts
      SignalFilename
      ExampleTitle
      LogFilename
      Duration
  end
  
  properties (Abstract, Access = protected)
    HTMLFilename
    RunFunction
  end
  
  properties (Access = protected)
    FigureHandle
    ParentHandle
    ParamHandle
    ButtonHandle
    Text = matlab.ui.control.UIControl
    Input = matlab.ui.control.UIControl
    RunButton
    ViewButton
    RunGenCodeButton
    StopButton
    HelpButton
    
    HorizontalSpacing = 10
    VerticalSpacing = 15
    Spacing = 10
    
    LabelWidgetSpacing = 10
    LabelSpacing = 10
    MinLabelWidgetHeight = 0
    RowCount = 0
    
    ButtonWidth = 150
    ButtonHeight = 30
    ButtonSpacing = 1
    
    % isInSimulinkApp determines whether the controller is used in Simulink
    % or MATLAB.
    isInSimulinkApp 
    
    % FileCenterFrequency displays the center frequency of captured signal.
    FileCenterFrequency
    
    % CenterFrequencyUnit is used to calculate the CenterFrequency.
    CenterFrequencyUnit = 'MHz'
    
    % Viewer is an instance of a viewer class. This is used only for App.
    Viewer
  end
  
  properties
    pMATLABCoderLincense = false
    pRendered = false
    pCompileFlag = true
    pStopSimulation = false
    SignalSourceController
    LogDataController
  end
  
  methods (Access = protected)
    addWidgets(obj)
  end
  
  methods

    function obj = ExampleController(varargin) 
      p = inputParser;
      addParameter(p, 'isInSimulinkApp', false);
      addParameter(p,'Viewer',-1);
      addParameter(p,'ParentHandle',-1);
      parse(p,varargin{:});
      obj.isInSimulinkApp = p.Results.isInSimulinkApp;
      obj.Viewer = p.Results.Viewer;
      obj.ParentHandle = p.Results.ParentHandle;
      obj.pMATLABCoderLincense = checkCodegenLicense;
      obj.RunFunction = eval(['@' obj.RunFunction]);
      obj.SignalSourceController = SignalSourceController();
      obj.LogDataController = LogDataController();
    end
    function set.SignalFilename(obj, val)
      obj.SignalSourceController.SignalFilename = val;
    end
    
    function set.ExampleTitle(obj, val)
      obj.SignalSourceController.ExampleTitle = val;
    end
    
    function set.LogFilename(obj, val)
      cachedvalue = obj.LogDataController.LogData;
      obj.LogDataController.LogData = true;
      obj.LogDataController.LogFilename = val;
      obj.LogDataController.LogData = cachedvalue;
    end
    
    function set.Duration(obj, val)
      obj.SignalSourceController.Duration = val;
    end
    
    function val = get.SignalFilename(obj)
      val = obj.SignalSourceController.SignalFilename;
    end

    function val = get.ExampleTitle(obj)
      val = obj.SignalSourceController.ExampleTitle;
    end
    
    function val = get.LogFilename(obj)
      val = obj.LogDataController.LogFilename;
    end
    
    function val = get.Duration(obj)
      val = obj.SignalSourceController.Duration;
    end
    
    function name = getExampleName(obj)
      name = obj.ExampleName;
    end
    
    function render(obj)
      if ~obj.pRendered
        hParent = obj.ParentHandle;
        if ishandle(hParent) && isvalid(hParent)
          noParent = false;
          obj.ParentHandle = hParent;
        else
          noParent = true;
        end
        
        if noParent
          obj.ParentHandle = uifigure('Visible', 'off', ...
            'HandleVisibility', 'on', ...
            'MenuBar', 'none', ...
            'NumberTitle', 'off', ...
            'IntegerHandle', 'off', ...
            'Name', obj.ExampleTitle, ...
            'Tag', [obj.ExampleTitle ' Controller'], ...
            'CloseRequestFcn', @(x,y)figureClosed(x,obj), ...
            'Units', 'pixels', ...
            'Position', [obj.HorizontalSpacing obj.VerticalSpacing ...
            obj.MinContainerWidth obj.MinContainerHeight], ...
            'AutoResizeChildren', 'off');
        else
          % find the ancestor figure, and set the CloseRequestFcn callback
          obj.FigureHandle = ancestor(obj.ParentHandle, 'Figure');
          obj.FigureHandle.CloseRequestFcn = @(x,y)figureClosed(x,obj);
        end
        % SizeChangedFcn callback
        obj.ParentHandle.SizeChangedFcn = @(x, y)parentHandleResize(x, obj);

        % Compute positions of ParamHandle and ButtonContainer
        x = obj.HorizontalSpacing;
        y = obj.VerticalSpacing;
        parentMaxW = obj.ParentHandle.Position(3);
        w = parentMaxW - 2*obj.HorizontalSpacing;
        parentMaxH = obj.ParentHandle.Position(4);
        h = (parentMaxH - 3*obj.VerticalSpacing)/2;
        
        % Button container
        obj.ButtonHandle = uipanel('Parent', obj.ParentHandle, ...
          'Tag', 'ButtonHandle', ...
          'Units', 'pixels', ...
          'Position', [x y w h], ...
          'AutoResizeChildren', 'off');
        
        y = y + obj.VerticalSpacing + h;
        % Param panel
        obj.ParamHandle = uipanel('Parent', obj.ParentHandle, ...
          'Title', 'Parameters', ...
          'Tag', 'ParamHandle', ...
          'Units', 'pixels', ...
          'Position', [x y w h], ...
          'AutoResizeChildren', 'off');
        % Test sizes
        dummy = uicontrol(obj.ParamHandle, 'Visible', 'off', ...
          'Style', 'edit', 'String', 'Sample Text');
        obj.MinLabelWidgetHeight = dummy.Extent(4);
        dummy = uicontrol(obj.ParamHandle, 'Visible', 'off', ...
          'Style', 'popupmenu', 'String', {'Sample Text','Sample Text'});
        obj.MinLabelWidgetHeight = max(obj.MinLabelWidgetHeight, dummy.Extent(4));
        clear dummy;
        
        % Add widgets defined by the client
        addWidgets(obj);        
        
        if noParent          
          movegui(ancestor(obj.ParentHandle, 'Figure'), 'center')
          obj.ParentHandle.Visible = 'on';
        end
        
        % Manage the position of the client widgets
        manageWidgets(obj);
        
        % Add control buttons: Run, View MATLAB Code/Open Simulink Model,
        % Run Generated Code, Stop, Help
        addControlButtons(obj);
        
        obj.pRendered = true;
      end
    end
    
    function setParentHandle(obj, aHandle)
      validateattributes(aHandle, ...
        {'matlab.ui.Figure','matlab.ui.container.internal.UIContainer'},...
        {'scalar'},'','setParentHandle');
      obj.ParentHandle = aHandle;
    end
    
    function userInput = getUserInput(obj)
      getDuration(obj.SignalSourceController)
      getSignalSource(obj.SignalSourceController);
      getUserInputImpl(obj);
      userInput = get(obj);
      userInput.Duration = obj.SignalSourceController.Duration;
      userInput.SignalSource = obj.SignalSourceController.SignalSource;
      userInput.SignalFilename = obj.SignalSourceController.SignalFilename;
      userInput.RadioAddress = obj.SignalSourceController.RadioAddress;
      userInput.SignalSourceType = obj.SignalSourceController.SignalSourceType;
      userInput.LogData = obj.LogDataController.LogData;
      userInput.LogFilename = obj.LogDataController.LogFilename;
    end
    
    function flag = isInactiveProperty(obj,prop)
        switch prop
            case 'FileCenterFrequency'
                if strcmp(obj.SignalSourceController.SignalSource, 'File')
                    flag = false;
                else
                    flag = true;
                end
            case 'CenterFrequencyUnit'
                if strcmp(obj.SignalSourceController.SignalSource, 'File')
                    flag = true;
                else
                    flag = false;
                end
            case 'Browse'
                if strcmp(obj.SignalSourceController.SignalSource, 'File')
                    flag = false;
                else
                    flag = true;
                end
            otherwise
                flag = false;
        end
    end
  end
  
  methods
    function lineNumber = get.FileLineNumber( obj )
        fileContent = fileread( which( obj.ExampleName ) );
        fileContent = splitlines( fileContent );
        fileContent = regexprep( fileContent , '\s' , '' ); % Remove all white spaces.
        fileContent = string( fileContent );
        idxEmptyLines = ( fileContent.strlength == 0 );
        idxCommentLines = fileContent.startsWith( '%' );
        idxMCodeLines = find( ~idxEmptyLines & ~idxCommentLines );
        lineNumber = idxMCodeLines(1);  % Return the first M-code line.
    end
  end
  
  methods (Access = protected)
    function getUserInputImpl(~)
    end
    
    function addRow(obj, propName, label, style, varargin)
      if nargin == 5
        % User data is used to distinguished between the text and numeric
        % edit boxes
        userData = varargin{1};
      end

      obj.RowCount = obj.RowCount + 1;
      height = obj.MinLabelWidgetHeight;
      
      % Set value callback
      if obj.isInSimulinkApp
        callback = eval(['@(x,y)setValueSL(x,obj,''' propName ''')']);
      else
        callback = eval(['@(x,y)setValueML(x,obj,''' propName ''')']);
      end
      if strcmp(propName,'LogData') || strcmp(propName,'LogFilename')
          addlistener(obj.LogDataController,propName,'PostSet',@(x,y)updateGUI(obj));    
      elseif strcmp(propName,'LaunchMap') || strcmp(propName,'CenterFrequency')...
              || strcmp(propName,'OpenScopes') || strcmp(propName,'PlaybackAudio')
          addlistener(obj,propName,'PostSet',@(x,y)updateGUI(obj));
      else
          addlistener(obj.SignalSourceController,propName,'PostSet',@(x,y)updateGUI(obj));
      end
      switch style
        case 'edit'
          obj.Text(obj.RowCount) = uicontrol('Parent', obj.ParamHandle, ...
            'Style', 'text', ...
            'String', [label ':'], ...
            'Tag', [propName 'Label'], ...
            'HorizontalAlignment', 'left', ...
            'Units', 'pixels', ...
            'Position', [obj.Spacing obj.Spacing 50 height]);
          if strcmp(propName,'LogFilename')
            value = get(obj.LogDataController, propName);  
          elseif strcmp(propName,'CenterFrequency')
            value = obj.CenterFrequency/1e6;
          else
            value = get(obj.SignalSourceController, propName);
          end
          obj.Input(obj.RowCount) = uicontrol('Parent', obj.ParamHandle, ...
            'Style', style, ...
            'String', value, ...
            'Tag', propName, ...
            'UserData', userData, ...
            'Callback', callback, ...
            'Units', 'pixels', ...
            'Position', [obj.Spacing+50 obj.Spacing 50 height]);
          
          if strcmp(propName, 'SignalFilename')
            % Add browse push button
            obj.RowCount = obj.RowCount + 1;
            obj.Text(obj.RowCount) = matlab.ui.control.UIControl;
            obj.Input(obj.RowCount) = uicontrol('Parent', obj.ParamHandle, ...
              'Style', 'pushbutton', ...
              'String', '...', ...
              'Tag', 'Browse', ...
              'Callback', @(x,y)browseFileCallback(x,obj), ...
              'Units', 'pixels', ...
              'Position', [obj.Spacing+50 obj.Spacing 50 height]);
            % Add file center frequency
            obj.RowCount = obj.RowCount + 1;
            obj.Text(obj.RowCount) = uicontrol('Parent', obj.ParamHandle, ...
            'Style', 'text', ...
            'String', 'Center frequency: ', ...
            'Tag', 'FileCenterFrequencyLabel', ...
            'HorizontalAlignment', 'left', ...
            'Units', 'pixels', ...
            'Position', [obj.Spacing obj.Spacing 50 height]);
            dummyBBFR = comm.BasebandFileReader(obj.SignalSourceController.SignalFilename);
            [fc, ~, u] = engunits(dummyBBFR.CenterFrequency);
            release(dummyBBFR); 
            clear('dummyBBFR');
            obj.Input(obj.RowCount) = uicontrol('Parent', obj.ParamHandle, ...
              'Style', 'text', ...
              'String', [num2str(fc) ' ' u 'Hz'], ...
              'Tag', 'FileCenterFrequency', ...
              'HorizontalAlignment', 'center', ...
              'Units', 'pixels', ...
              'Position', [obj.Spacing+50 obj.Spacing 50 height]);
          end
          if strcmp(propName, 'CenterFrequency')
            % Add center frequency unit popup menu
            obj.RowCount = obj.RowCount + 1;
            obj.Text(obj.RowCount) = matlab.ui.control.UIControl;
            obj.Input(obj.RowCount) = uicontrol('Parent', obj.ParamHandle, ...
            'Style', 'popupmenu', ...
            'String', {'MHz', 'GHz', 'kHz'}, ...
            'Tag', 'CenterFrequencyUnit', ...
            'Callback', @(x,y)centerFrequencyUnitCallback(x, obj), ...
            'Units', 'pixels', ...
            'Position', [obj.Spacing+50 obj.Spacing 50 height]);
          end
        case 'popupmenu'
            obj.Text(obj.RowCount) = uicontrol('Parent', obj.ParamHandle, ...
                'Style', 'text', ...
                'String', [label ':'], ...
                'Tag', [propName 'Label'], ...
                'HorizontalAlignment', 'left', ...
                'Units', 'pixels', ...
                'Position', [obj.Spacing obj.Spacing 50 height]);

            value{2} = get(obj.SignalSourceController, propName);
            value{1} = eval(['obj.SignalSourceController.' propName 'Set.getAllowedValues']);

            obj.Input(obj.RowCount) = uicontrol('Parent', obj.ParamHandle, ...
                'Style', style, ...
                'String', value{1}, ...
                'Tag', propName, ...
                'Value', find(strcmp(value{1}, value{2})) , ...
                'Callback', callback, ...
                'Units', 'pixels', ...
                'Position', [obj.Spacing+50 obj.Spacing 50 height]);
        case 'checkbox'
            switch propName
              case 'LogData'
                value = get(obj.LogDataController, propName);
              otherwise 
                value = get(obj, propName);
            end
                obj.Text(obj.RowCount) = matlab.ui.control.UIControl;
                obj.Input(obj.RowCount) = uicontrol('Parent', obj.ParamHandle, ...
                    'Style', style, ...
                    'String', label, ...
                    'Tag', [propName 'Label'], ...
                    'Value', value, 'Callback', callback, ...
                    'Units', 'pixels', ...
                    'Position', [obj.Spacing+50 obj.Spacing 50 height]);
      end
    end
    
    function updateGUI(obj)
      manageWidgets(obj);
      manageControlButtons(obj);
    end
    
    function resetGUI(obj)
      obj.RowCount = 0;
      obj.pRendered = false;
    end
  end
  
  methods (Access = private)
    function addControlButtons(obj)
      if isempty(obj.RunButton) || ~(ishandle(obj.RunButton) && ...
          isvalid(obj.RunButton))
        
        maxY = obj.ButtonHandle.Position(2) + obj.ButtonHandle.Position(4);
        x = 0;
        w = obj.ButtonHandle.Position(3);
        h = obj.ButtonHeight;
        buttonSpacing = (obj.ButtonHandle.Position(4)-5*h - obj.VerticalSpacing)/4;
        y = maxY - h - obj.VerticalSpacing;
        
        obj.RunButton = uicontrol('Parent', obj.ButtonHandle, ...
          'Style', 'pushbutton', ...
          'String', 'Run', ...
          'Tag', 'RunButton', ...
          'BackgroundColor', [0 0.5 0], ...
          'ForegroundColor', [1 1 1], ...
          'HorizontalAlignment', 'center', ...
          'Callback', @(x,y)runCallback(x,obj), ...
          'Units', 'pixels', ...
          'Position', [x y w h]);
        
        y = y - h - buttonSpacing;
        if obj.isInSimulinkApp
          viewButtonLabel = 'Open Simulink Model';
        else % MATLAB
          viewButtonLabel = 'View MATLAB Code';
        end
        obj.ViewButton = uicontrol('Parent', obj.ButtonHandle, ...
          'Style', 'pushbutton', ...
          'String', viewButtonLabel, ...
          'Tag', 'ViewButton', ...
          'BackgroundColor', [0 0.45 0.75], ...
          'ForegroundColor', [1 1 1], ...
          'HorizontalAlignment', 'center', ...
          'Callback', @(x,y)viewModelCallback(x,obj), ...
          'Units', 'pixels', ...
          'Position', [x y w h]);
        
        y = y - h - buttonSpacing;
        if obj.isInSimulinkApp
          runGenCodeButtonLabel = 'Run in Accelerator Mode';
        else % MATLAB
          runGenCodeButtonLabel = 'Run Generated Code';
        end
        obj.RunGenCodeButton = uicontrol('Parent', obj.ButtonHandle, ...
          'Style', 'pushbutton', ...
          'String', runGenCodeButtonLabel, ...
          'Tag', 'RungenCodeButton', ...
          'BackgroundColor', [0.08 0.17 0.55], ...
          'ForegroundColor', [1 1 1], ...
          'HorizontalAlignment', 'center', ...
          'Callback', @(x,y)runGeneratedCodeCallback(x,obj), ...
          'Position', [x y w h]);
        
        y = y - h - buttonSpacing;
        obj.StopButton = uicontrol('Parent', obj.ButtonHandle, ...
          'Style', 'pushbutton', ...
          'String', 'Stop', ...
          'Tag', 'StopButton', ...
          'HorizontalAlignment', 'center', ...
          'Enable', 'off', ...
          'Callback', @(x,y)stopCallback(x,obj), ...
          'Units', 'pixels', ...
          'Position', [x y w h]);
        
        y = y - h - buttonSpacing;
        obj.HelpButton = uicontrol('Parent', obj.ButtonHandle, ...
          'Style', 'pushbutton', ...
          'String', 'Help', ...
          'Tag', 'HelpButton', ...
          'HorizontalAlignment', 'center', ...
          'Position', [x y w h], ...
          'Callback', @(x,y)helpCallback(x,obj), ...
          'Units', 'pixels', ...
          'Position', [x y w h]);
      end        
    end
    
    function disableNontunableProperties(obj)
      mc = metaclass(obj);
      propsToDisable = {};
      for q=1:length(mc.PropertyList)
        prop = mc.PropertyList(q);
        if isa(prop.DefiningClass, 'matlab.system.SysObjCustomMetaClass')
          if prop.Nontunable
            propsToDisable = [propsToDisable {prop.Name}]; %#ok
          end
        end
      end
      for p=1:obj.RowCount
          obj.Input(p).Enable = 'off';
      end
    end
    
    function enableNontunableProperties(obj)
      for p=1:obj.RowCount
        obj.Input(p).Enable = 'on';
      end
    end
    
    function manageWidgets(obj)
      % Calculate the width and height of labels and widgets 
      rowCount = obj.RowCount;
      verticalSpacing = obj.VerticalSpacing;
      horizontalSpacing = obj.HorizontalSpacing;
      labelWidgetSpacing = obj.LabelWidgetSpacing;
      labelSpacing = obj.LabelSpacing;
      maxY = obj.ParamHandle.Position(4) - verticalSpacing;
      maxW = obj.ParamHandle.Position(3) - 2*horizontalSpacing - ...
        labelWidgetSpacing;
      maxH = obj.ParamHandle.Position(4) - 2*verticalSpacing;
      
      minLabelWidgetHeight = (maxH - (rowCount - 1)*labelWidgetSpacing)/rowCount;
      if minLabelWidgetHeight < obj.MinLabelWidgetHeight
        minLabelWidgetHeight = obj.MinLabelWidgetHeight;
      end
      x = horizontalSpacing;
      c1w = obj.Column1Width;
      c2w = maxW-c1w;
      if c2w < 0
        c2w = 5;
      end
      
      count = 1;
      for p=1:rowCount
        propName = obj.Input(p).Tag;
        if ~isInactiveProperty(obj.SignalSourceController, propName) && ...
                ~isInactiveProperty(obj.LogDataController, propName)&&...
                ~isInactiveProperty(obj, propName)
          obj.Text(p).Visible = 'on';
          obj.Input(p).Visible = 'on';
          if strcmp(obj.Input(p).Style, 'checkbox')
            obj.Input(p).Position(1) = x;
            obj.Input(p).Position(2) = maxY - count*(minLabelWidgetHeight + labelSpacing);
            obj.Input(p).Position(3) = maxW;
            obj.Input(p).Position(4) = minLabelWidgetHeight;
          elseif (strcmp(obj.Input(p).Style, 'pushbutton') && ...
              strcmp(obj.Input(p).Tag, 'Browse'))
            % There is only one push button in the param panel.
            % Browse button (...) next to signal file name edit box
            browseButtonWidth = 15;
            position3 = obj.Input(p-1).Position(3) - browseButtonWidth;
            if position3 < 0
              obj.Input(p-1).Position(3) = 1;
            else
              obj.Input(p-1).Position(3) = position3;
            end
            obj.Input(p).Position(1) = ...
              obj.Input(p-1).Position(1) + obj.Input(p-1).Position(3);
            obj.Input(p).Position(2) = obj.Input(p-1).Position(2);
            obj.Input(p).Position(3) = browseButtonWidth;
            obj.Input(p).Position(4) = minLabelWidgetHeight;
            count = count - 1;
          elseif (strcmp(obj.Input(p).Style, 'popupmenu') && ...
              strcmp(obj.Input(p).Tag, 'CenterFrequencyUnit'))
            % Center frequency unit is a popup menu next to the center
            % frequency edit box.
            unitPopupWidth = 50;
            obj.Input(p-1).Position(2) = obj.Text(p-1).Position(2) + ...
              minLabelWidgetHeight - 22.9375;
            position3 = obj.Input(p-1).Position(3) - unitPopupWidth;
            if position3 < 0
              obj.Input(p-1).Position(3) = 1;
            else
              obj.Input(p-1).Position(3) = position3;
            end
            % Height of a popup menu is 22.9375. The height of the center
            % frequency edit box should be fixed to the height of the
            % center frequency unit popup menu.
            obj.Input(p-1).Position(4) = 22.9375; 
            obj.Input(p).Position(1) = ...
              obj.Input(p-1).Position(1) + obj.Input(p-1).Position(3);
            obj.Input(p).Position(2) = obj.Text(p-1).Position(2);
            obj.Input(p).Position(3) = unitPopupWidth;
            obj.Input(p).Position(4) = minLabelWidgetHeight;
            count = count - 1;
          else % edit, text, popupmenu
            obj.Text(p).Position(1) = x;
            obj.Input(p).Position(1) = x + c1w;
            obj.Text(p).Position(2) = maxY - count*(minLabelWidgetHeight + labelSpacing);
            obj.Input(p).Position(2) = obj.Text(p).Position(2);
            obj.Text(p).Position(3) = c1w;
            obj.Input(p).Position(3) = c2w + labelWidgetSpacing;
            obj.Text(p).Position(4) = minLabelWidgetHeight;
            obj.Input(p).Position(4) = minLabelWidgetHeight;
          end
          count = count + 1;
        else
          obj.Text(p).Visible = 'off';
          obj.Input(p).Visible = 'off';
        end
      end
    end
    
    function manageControlButtons(obj)
      maxY = obj.ButtonHandle.Position(2) + obj.ButtonHandle.Position(4);
      maxH = obj.ButtonHandle.Position(4) - 2*obj.VerticalSpacing;
      buttonSpacing = obj.ButtonSpacing;
      x = 0;
      w = obj.ButtonHandle.Position(3);
      h = (maxH - 4*buttonSpacing)/5;
      if h < obj.ButtonHeight
        h = obj.ButtonHeight;
      end
      
      y = maxY - h - obj.VerticalSpacing;
      obj.RunButton.Position = [x y w h];
      y = y - h - buttonSpacing;
      obj.ViewButton.Position = [x y w h];
      y = y - h - buttonSpacing;
      obj.RunGenCodeButton.Position = [x y w h];
      y = y - h - buttonSpacing;
      obj.StopButton.Position = [x y w h];
      y = y - h - buttonSpacing;
      obj.HelpButton.Position = [x y w h];
    end
  end
end

function setValueML(x,obj,prop) %#ok<DEFNU>
switch x.Style
  case 'edit'
    if strcmp(x.UserData, 'numeric')
      if strcmpi(prop, 'CenterFrequency')
        freqUnit = obj.CenterFrequencyUnit;
        switch freqUnit
          case 'MHz'
            value = str2double(x.String)*1e6;
          case 'GHz'
            value = str2double(x.String)*1e9;
          case 'kHz'
            value = str2double(x.String)*1e3;
        end 
      else % prop is not CenterFrequency
        try
           value = evalin('base',['[' x.String ']']);
        catch me
           handleErrorsInApp(obj.SignalSourceController,me)
           return
        end
      end
    else % UserData is text
      value = x.String;
    end
  case 'popupmenu'
    value = x.String{x.Value};
    if strcmp(prop, 'SignalSource') && ...
        ~isequal(obj.Viewer, -1) && ...
        isprop(obj.Viewer, 'SignalSourceType')
      if strcmpi(value, 'File')
        % Viewer shows the signal source type (file/radio)
        obj.Viewer.SignalSourceType = ExampleSourceType.Captured;
      elseif strcmpi(value, 'RTL-SDR') 
        obj.Viewer.SignalSourceType = ExampleSourceType.RTLSDRRadio;
      elseif strcmpi(value, 'ADALM-PLUTO')
        obj.Viewer.SignalSourceType = ExampleSourceType.PlutoSDRRadio;
      elseif strcmpi(value, 'USRP')
        obj.Viewer.SignalSourceType = ExampleSourceType.USRPRadio;  
      end
    end 
  case 'checkbox'
    value = logical(x.Value);    
end

if strcmp(prop, 'SignalSource')
    setStatusViewer = obj.Viewer;
    obj.RunButton.Enable = 'on';
    obj.RunGenCodeButton.Enable = 'on';
    startSourceStatus(setStatusViewer)
end

switch prop
    case {'LogData','LogFilename'}
        set(obj.LogDataController, prop, value);
    case {'Duration', 'SignalFilename','RadioAddress', 'SignalSource'}
        set(obj.SignalSourceController, prop, value);
    otherwise
        set(obj, prop, value);
end

% To update the radio addresses
tags = {obj.Input(:).Tag};
ind = strcmp(tags, 'RadioAddress');
obj.Input(ind).String = obj.SignalSourceController.RadioAddressSet.getAllowedValues;
value = find(strcmp(obj.Input(ind).String,obj.SignalSourceController.RadioAddress));
obj.Input(ind).Value = value;

if strcmp(prop, 'RadioAddress') || (strcmp(prop, 'SignalSource') && ~strcmpi(value, 'File'))

    obj.Viewer.RadioAddress = obj.SignalSourceController.RadioAddress;
    setValueViewer = obj.Viewer;
    try 
        if strcmp(obj.Viewer.SignalSourceType,'PlutoSDRRadio')
            findPlutoRadio;
        elseif strcmp(obj.Viewer.SignalSourceType,'RTLSDRRadio')
            RadioAddress = helperFindRTLSDRRadio();
            if isempty(RadioAddress)
                error(message('comm_demos:common:RTLSDRRadioNotFound'))
            end
        elseif strcmp(obj.Viewer.SignalSourceType,'USRPRadio')
            RadioAddress = helperFindUSRPRadio();
            if isempty(RadioAddress)
                error('USRP Radio not found');
            end
        end
        stopSourceStatus(setValueViewer);
    catch
        obj.RunButton.Enable = 'off';
        obj.RunGenCodeButton.Enable = 'off';
    end
end

if strcmp(prop, 'SignalFilename')
  updateFileCenterFrequency(obj);
end 

if strcmp(prop, 'SignalFilename') || strcmp(prop, 'SignalSource')
  % By changing the value of SignalFilename or SignalSource, we should
  % compile again if the Run Generated Code button has been pushed because
  % the new selected file may have a different sample rate.
  obj.pCompileFlag = true;
end
end

function setValueSL(x,obj,prop) %#ok<DEFNU>
modelName = obj.ModelName;
if ~bdIsLoaded(modelName)
  waitBarHandle = waitbar(0, ['Please wait. ' obj.ExampleTitle ' model is being loaded.']);
  load_system(modelName); % Model should be loaded before doing set_param
  waitbar(1, waitBarHandle, [obj.ExampleTitle ' is loaded']);
  close(waitBarHandle);
end
switch x.Style
  case 'edit'
      switch prop
        case 'Duration'
          set_param(modelName, 'StopTime', x.String);
          value = str2double(x.String); 
        case 'SignalFilename'
          value = x.String; % SignalFilename is a char.
          % @todo update the usage of edit-time filter filterOutInactiveVariantSubsystemChoices()
          % instead use the post-compile filter activeVariants() - g2597271
          bbfr_blk = find_system(modelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'MaskType', 'Baseband File Reader' ); % look only inside active choice of VSS
          set_param(bbfr_blk{1}, 'Filename', x.String);
        case 'CenterFrequency'
          freqUnit = obj.CenterFrequencyUnit;
          switch freqUnit
            case 'MHz'
              value = str2double(x.String)*1e6;
            case 'GHz'
              value = str2double(x.String)*1e9;
            case 'kHz'
              value = str2double(x.String)*1e3;
          end
          % @todo update the usage of edit-time filter filterOutInactiveVariantSubsystemChoices()
          % instead use the post-compile filter activeVariants() - g2597271
          rtlsdr_blk = find_system(modelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'MaskType', 'RTL-SDR Receiver' ); % look only inside active choice of VSS
          if strcmpi(get_param(rtlsdr_blk{1}, 'CenterFrequencySource'), 'Dialog')
            set_param(rtlsdr_blk{1}, 'CenterFrequency', num2str(value));
          end
          sys_blk = find_system(modelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices); % look only inside active choice of VSS
          ind = strcmp(sys_blk,cat(2,modelName,'/ADALM-Pluto Radio',newline,'Receiver'));
          plutosdr_blk = sys_blk{ind};
          if strcmpi(get_param(plutosdr_blk, 'CenterFrequencySource'), 'Dialog')
            set_param(plutosdr_blk, 'CenterFrequency', num2str(value));
          end
      end
  case 'popupmenu'
    value = x.String{x.Value};
    switch prop
      case 'SignalSource'
        % @todo update the usage of edit-time filter filterOutInactiveVariantSubsystemChoices()
        % instead use the post-compile filter activeVariants() - g2597271
        mvs_blk = find_system(modelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'MaskType', 'ManualVariantSource' ); % look only inside active choice of VSS
        if strcmpi(value, 'File')
          set_param(mvs_blk{1}, 'LabelModeActiveChoice', 'V_1');
          obj.Viewer.SignalSourceType = ExampleSourceType.Captured;
        elseif strcmpi(value, 'RTL-SDR') % RTL-SDR 
          set_param(mvs_blk{1}, 'LabelModeActiveChoice', 'V_2');
          obj.Viewer.SignalSourceType = ExampleSourceType.RTLSDRRadio;
        else % ADALM-PLUTO
          set_param(mvs_blk{1}, 'LabelModeActiveChoice', 'V_3');
          obj.Viewer.SignalSourceType = ExampleSourceType.PlutoSDRRadio;
        end
%         if ~isequal(obj.Viewer, -1) && isprop(obj.Viewer, 'SignalSource')
%           % Viewer shows the signal source type (file/radio)
%           obj.Viewer.SignalSource = value;
%         end
      case 'RadioAddress'
        if strcmp(obj.SignalSource,'RTL-SDR')
	  % @todo update the usage of edit-time filter filterOutInactiveVariantSubsystemChoices()
	  % instead use the post-compile filter activeVariants() - g2597271
          rtlsdr_blk = find_system(modelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'MaskType', 'RTL-SDR Receiver' ); % look only inside active choice of VSS
          set_param(rtlsdr_blk{1}, 'IPAddress', value);
        else
	  % @todo update the usage of edit-time filter filterOutInactiveVariantSubsystemChoices()
	  % instead use the post-compile filter activeVariants() - g2597271
          sys_blk = find_system(modelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices); % look only inside active choice of VSS
          ind = strcmp(sys_blk,cat(2,modelName,'/ADALM-Pluto Radio',newline,'Receiver'));
          plutosdr_blk = sys_blk{ind};
          set_param(plutosdr_blk, 'RadioID', value);
        end
    end
  case 'checkbox'
    value = logical(x.Value); 
end

if strcmp(prop, 'SignalSource')
    setStatusViewer = obj.Viewer;
    obj.RunButton.Enable = 'on';
    obj.RunGenCodeButton.Enable = 'on';
    startSourceStatus(setStatusViewer)
end


switch prop
    case {'LogData','LogFilename'}
        set(obj.LogDataController, prop, value);
    case {'Duration', 'SignalFilename','RadioAddress', 'SignalSource'}
        set(obj.SignalSourceController, prop, value);
    otherwise
        set(obj, prop, value);
end

% To update the radio addresses
tags = {obj.Input(:).Tag};
ind = strcmp(tags, 'RadioAddress');
obj.Input(ind).String = obj.SignalSourceController.RadioAddressSet.getAllowedValues;
value = find(strcmp(obj.Input(ind).String,obj.SignalSourceController.RadioAddress));
obj.Input(ind).Value = value;

if strcmp(prop, 'RadioAddress') || (strcmp(prop, 'SignalSource') && ~strcmpi(value, 'File'))
    obj.Viewer.RadioAddress = obj.SignalSourceController.RadioAddress;
    setValueViewer = obj.Viewer;
    try 
        if strcmp(obj.Viewer.SignalSourceType,'PlutoSDRRadio')
            findPlutoRadio;
        elseif strcmp(obj.Viewer.SignalSourceType,'RTLSDRRadio')
            RadioAddress = helperFindRTLSDRRadio();
            if isempty(RadioAddress)
                error(message('comm_demos:common:RTLSDRRadioNotFound'))
            end
        elseif strcmp(obj.Viewer.SignalSourceType,'USRPRadio')
            RadioAddress = helperFindUSRPRadio();
            if isempty(RadioAddress)
                error('USRP Radio not found');
            end
        end
        stopSourceStatus(setValueViewer);
    catch
        obj.RunButton.Enable = 'off';
        obj.RunGenCodeButton.Enable = 'off';
    end
end

if strcmp(prop, 'SignalFilename')
  updateFileCenterFrequency(obj);
end 
end

function updateFileCenterFrequency(obj)
% Retrieves the center frequency of the selected baseband file and shows it
% on the controller.
tags = {obj.Input(:).Tag};
ind = find(strcmp(tags, 'FileCenterFrequency'));
if ~isempty(ind)
    try
        dummyBBFR = comm.BasebandFileReader(obj.SignalSourceController.SignalFilename);
        [fc, ~, u] = engunits(dummyBBFR.CenterFrequency);
        release(dummyBBFR);
        clear('dummyBBFR');
        obj.Input(ind).String = [num2str(fc) ' ' u 'Hz'];
    catch
        errordlg('The specified baseband file does not exist', obj.ExampleTitle, 'Modal');
    end
end
end

function parentHandleResize(~, obj)
parentWidth = obj.ParentHandle.Position(3);
parentHeight = obj.ParentHandle.Position(4);
x = obj.HorizontalSpacing;
y = obj.VerticalSpacing;
w = parentWidth - 2*obj.HorizontalSpacing;
if w < 0
  w = obj.ButtonWidth;
end
h = (parentHeight - 3*obj.VerticalSpacing)/2;
if h < 0
  h = obj.ButtonHeight;
end
obj.ButtonHandle.Position = [x y w h];
y = y + obj.VerticalSpacing + h;
obj.ParamHandle.Position = [x y w h]; 

updateGUI(obj);
end

function browseFileCallback(~, obj)
[fileName, pathName]  = uigetfile({'*.bb','Baseband Files (*.bb)'}, ...
    'Select the signal file');
tags = {obj.Input(:).Tag};
ind = find(strcmp(tags, 'SignalFilename'));
if ~obj.isInSimulinkApp
  if isprop(obj, 'SignalFilename') && ~isequal(fileName, 0)
      set(obj, 'SignalFilename', [pathName fileName]);
      if ~isempty(ind)
        obj.Input(ind).String = fileName;
        obj.pCompileFlag = true;  
      end
  end
else % in Simulink
  modelName = obj.ModelName;
  if ~bdIsLoaded(modelName)
    waitBarHandle = waitbar(0, ['Please wait. ' obj.ExampleTitle ' model is being loaded']);
    load_system(modelName);
    waitbar(1, waitBarHandle, [obj.ExampleTitle ' is loaded']);
    close(waitBarHandle);
  end
  % @todo update the usage of edit-time filter filterOutInactiveVariantSubsystemChoices()
  % instead use the post-compile filter activeVariants() - g2597271
  bbrf_blk = find_system(modelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'maskType', 'Baseband File Reader' ); % look only inside active choice of VSS
  set(obj, 'SignalFilename', [pathName fileName]);
  set_param(bbrf_blk{1}, 'Filename', [pathName fileName]);
  if ~isempty(ind)
    obj.Input(ind).String = fileName;
  end
end
updateFileCenterFrequency(obj)
end

function centerFrequencyUnitCallback(x, obj)
fcEditBox = findall(obj.Input, 'Tag', 'CenterFrequency');
if isprop(obj, 'CenterFrequency')
  switch x.Value
    case 1 % MHz
      obj.CenterFrequencyUnit = 'MHz';
      value = str2double(fcEditBox.String)*1e6;
    case 2 % GHz
      obj.CenterFrequencyUnit = 'GHz';
      value = str2double(fcEditBox.String)*1e9;
    case 3 % kHz
      obj.CenterFrequencyUnit = 'kHz';
      value = str2double(fcEditBox.String)*1e3;
  end
  obj.CenterFrequency = value;
end
end

function runCallback(x, obj)
set(obj.RunButton, 'Enable','off');
set(obj.RunButton, 'BackgroundColor',[0.94 0.94 0.94])
set(obj.RunButton, 'String', 'Running')

set(obj.StopButton, 'Enable','on');
set(obj.StopButton, 'BackgroundColor',[1 0 0]);
set(obj.StopButton, 'ForegroundColor',[1 1 1]);

set(obj.RunGenCodeButton, 'Enable','off');

obj.pStopSimulation = false;

if ~obj.isInSimulinkApp
  runCoreML(x, obj, false);
else
  runCoreSL(x, obj, 'normal');
end
end

function runCoreML(x, obj, doCodegen)
    disableNontunableProperties(obj);
    
    clear(obj.ExampleName)
    
    userInput = get(obj);
    userInput.Duration = obj.SignalSourceController.Duration;
    userInput.SignalSource = obj.SignalSourceController.SignalSource;
    userInput.SignalFilename = obj.SignalSourceController.SignalFilename;
    userInput.RadioAddress = obj.SignalSourceController.RadioAddress;
    userInput.SignalSourceType = obj.SignalSourceController.SignalSourceType;
    userInput.LogData = obj.LogDataController.LogData;
    userInput.LogFilename = obj.LogDataController.LogFilename;
    viewer = obj.Viewer;
    reset(viewer)
    
    % Start the viewer
    start(viewer);
    % Main loop
    frameCnt = 0;
    radioTime = 0;
    try
        while radioTime < userInput.Duration
            radioTime = obj.RunFunction(radioTime, userInput, viewer, doCodegen);
            
            frameCnt = frameCnt + 1;
            
            % Update output variables and check for simulation stop
            if rem(frameCnt,10) == 0
                drawnow;
                if obj.pStopSimulation == true
                    obj.pStopSimulation = false;
                    break;
                end
            end
        end
    catch me
        handleErrorsInApp(obj.SignalSourceController,me);
        stop(viewer)
        stopCallback(x, obj);
        return
    end
    
    % Release resources and clear function
    radioTime = userInput.Duration + 1;
    obj.RunFunction(radioTime, userInput, viewer, doCodegen);
    
    % Stop the viewer
    if ishghandle(obj.FigureHandle) % not closed through X button, figure still exists
        stop(viewer)
        stopCallback(x, obj);
    end
end

function runCoreSL(x, obj, simMode)
disableNontunableProperties(obj);
modelName = obj.ModelName;
viewer = obj.Viewer;
start(viewer)
if ~bdIsLoaded(modelName)
    waitBarHandle = waitbar(0, ['Please wait. ' obj.ExampleTitle ' model is being loaded.']);
end
% When the Run button is pushed, the model opens but the focus changes to
% the App window.
open_system(modelName);
if exist('waitBarHandle', 'var')
    close(waitBarHandle);
end
figureHandle = ancestor(obj.ParentHandle, 'Figure');
uifigure(figureHandle);
try
    if strcmp(simMode, 'normal')
        set_param(modelName, 'SimulationMode', 'normal');
        sim(modelName);
    else % Accelerator
        set_param(modelName, 'SimulationMode', 'accelerator');
        currentPath = pwd;
        cd(tempdir)
        sim(modelName);
        cd(currentPath);
    end
catch me
    handleErrorsInApp(obj.SignalSourceController,me);
    stop(viewer)
    stopCallback(x, obj);
    return
end

if ~strcmpi(get_param(modelName, 'SimulationStatus'), 'stopped')
    obj.pStopSimulation = true;
elseif obj.pStopSimulation == true
    obj.pStopSimulation = false;
    set_param(modelName, 'SimulationCommand', 'stop');
end
% The Viewer block in the Simulink model stops the viewer
if ishghandle(obj.FigureHandle)
    stopCallback(x, obj);
end
end

function viewModelCallback(~, obj)
if ~obj.isInSimulinkApp
  edit(obj.ExampleName)
  hEditor = matlab.desktop.editor.getActive;
  hEditor.goToLine(obj.FileLineNumber)
else
  open_system(obj.ModelName);
end
end

function runGeneratedCodeCallback(x, obj)
disableNontunableProperties(obj);
set(obj.RunButton, 'Enable','off');
obj.pStopSimulation = false;
if obj.isInSimulinkApp
  set(obj.RunGenCodeButton,'String','Running')
  set(obj.RunGenCodeButton,'ForegroundColor',[0.5 0.5 0.5])
  set(obj.RunGenCodeButton,'BackgroundColor',[0.94 0.94 0.94])

  set(obj.StopButton,'BackgroundColor',[1 0 0])
  set(obj.StopButton,'ForegroundColor',[1 1 1])
  set(obj.StopButton,'Enable','On')

  runCoreSL(x, obj, 'accelerator');
else % MATLAB
  compileFlag = obj.pCompileFlag;
  userInput = get(obj);
  userInput.Duration = obj.SignalSourceController.Duration;
  userInput.SignalSource = obj.SignalSourceController.SignalSource;
  userInput.SignalFilename = obj.SignalSourceController.SignalFilename;
  userInput.RadioAddress = obj.SignalSourceController.RadioAddress;
  userInput.SignalSourceType = obj.SignalSourceController.SignalSourceType;
  userInput.LogData = obj.LogDataController.LogData;
  userInput.LogFilename = obj.LogDataController.LogFilename;

  if compileFlag
    set(obj.RunGenCodeButton,'String','Compiling')
    set(obj.RunGenCodeButton,'BackgroundColor',[0.68 0.68 1])
    drawnow
    
    try
      obj.CodeGenCallback(userInput);
      obj.pCompileFlag = false;
    catch e %#ok<*NASGU>
      % An error occurred, e.g., the current folder is not writable. 
      stopCallback([], obj);
      return;
    end
  end

  set(obj.RunGenCodeButton,'String','Running')
  set(obj.RunGenCodeButton,'ForegroundColor',[0.5 0.5 0.5])
  set(obj.RunGenCodeButton,'BackgroundColor',[0.94 0.94 0.94])

  set(obj.StopButton,'BackgroundColor',[1 0 0])
  set(obj.StopButton,'ForegroundColor',[1 1 1])
  set(obj.StopButton,'Enable','On')

  runCoreML(x, obj, true);
end
end

function stopCallback(~, obj)
set(obj.RunButton, 'Enable','on');
set(obj.RunButton, 'String', 'Run');
set(obj.RunButton, 'BackgroundColor', [0 0.5 0]);

set(obj.StopButton, 'Enable','off');
set(obj.StopButton, 'BackgroundColor',[0.94 0.94 0.94]);
set(obj.StopButton, 'ForegroundColor',[0 0 0]);

if obj.pMATLABCoderLincense && ~obj.isInSimulinkApp
  set(obj.RunGenCodeButton, 'BackgroundColor',[0.08 0.17 0.55])
  set(obj.RunGenCodeButton, 'ForegroundColor',[1 1 1])
  set(obj.RunGenCodeButton, 'String', 'Run Generated Code')
  set(obj.RunGenCodeButton, 'Enable','on');
end

if obj.isInSimulinkApp && bdIsLoaded(obj.ModelName)
  set_param(obj.ModelName, 'SimulationCommand', 'stop');
  set(obj.RunGenCodeButton, 'Enable','on');
  if strcmpi(get_param(obj.ModelName, 'SimulationMode'), 'accelerator')
    set(obj.RunGenCodeButton, 'BackgroundColor',[0.08 0.17 0.55])
    set(obj.RunGenCodeButton, 'ForegroundColor',[1 1 1])
    set(obj.RunGenCodeButton, 'String', 'Run in Accelerator Mode')
  end  
end

enableNontunableProperties(obj);

obj.pStopSimulation = true;
end
    
function helpCallback(~, obj)
try
  showExample(obj.HTMLFilename)
catch
  web(obj.HTMLFilename)
end
end

function figureClosed(x,obj)
if obj.isInSimulinkApp
  if bdIsLoaded(obj.ModelName)
    if  ~strcmp(get_param(obj.ModelName, 'SimulationStatus'), 'stopped')
      set_param(obj.ModelName, 'SimulationCommand', 'stop');
    else
      % close_system errors for models that currently simulating. The above
      % command (set_param SimulationStatus) is not synchronous, so there
      % are no guarantees that the model would be immediately stopped.
      % In this case, users will need to manually close the model.
      close_system(obj.ModelName, 0);
    end    
  end
end
resetGUI(obj);
% close the dialog:
stopCallback([], obj);
delete(x)

end

% [EOF]