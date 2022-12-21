function varargout = FMReceiverExampleApp
%FMReceiverExampleApp  App based FM receiver example

% Copyright 2017-2022 The MathWorks, Inc.

% Top-level figure:
figureHandle = uifigure('Visible', 'off', ...
    'HandleVisibility', 'on', ...
    'NumberTitle', 'off', ...
    'IntegerHandle', 'off', ...
    'MenuBar', 'none', ...
    'Name', 'Broadcast FM Receiver Explorer', ...
    'Tag', 'FMAppFigure', ...
    'AutoResizeChildren', 'off');

% Create the main container
mainContainer = uigridcontainer('v0', 'Parent', figureHandle, ...
 'GridSize', [2 1], 'VerticalWeight', [15 2], ...
    'Tag', 'FMAppMainContainer');

% Create the container for the controller and the viewer
controllerPanel = uipanel('Parent', mainContainer, ...
  'Tag', 'FMAppCtrlPanel', ...
  'Units', 'pixels', 'AutoResizeChildren', 'off');
viewerPanel = uipanel('Parent', mainContainer, ...
  'Tag', 'FMAppViewerPanel', ...
  'Units', 'pixels', 'AutoResizeChildren', 'off');

% Instantiate the viewer and controller
viewer = helperFMViewer('ParentHandle', viewerPanel, 'isInApp', true);
controller = helperFMReceiverController('ParentHandle', controllerPanel, ...
  'Viewer', viewer);
render(controller);

movegui(figureHandle, 'center');
drawnow
figureHandle.Position = [figureHandle.Position(1:2), 370, 470];
drawnow
figureHandle.Visible = 'on';

if nargout > 0
    varargout{1} = controller;
end
if nargout > 1
    varargout{2} = viewer;
end

end
