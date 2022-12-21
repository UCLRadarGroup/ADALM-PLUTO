function varargout = ADSBExampleApp
%ADSBExampleApp Further exploration of ADSB Example

% Copyright 2018-2022 The MathWorks, Inc.

% Top-level figure:
figureHandle = uifigure('Visible', 'off', ...
    'HandleVisibility', 'on', ...
    'NumberTitle', 'off', ...
    'IntegerHandle', 'off', ...
    'MenuBar', 'none', ...
    'Name', 'Automatic Dependant Surveillance-Broadcast (ADS-B) Explorer', ...
    'Tag', 'ADSBMLAppFigure', ...
    'AutoResizeChildren', 'off');

% Create the main container
mainContainer = uigridcontainer('v0', 'Parent', figureHandle, ...
    'GridSize', [1 2], 'HorizontalWeight', [0.25 0.75], ...
    'Tag', 'ADSBMLAppMainContainer');

% Create the container for the controller and the viewer
controllerPanel = uipanel('Parent', mainContainer, ...
  'Tag', 'ADSBMLAppCtrlPanel', ...
  'Units', 'pixels', 'AutoResizeChildren', 'off');
viewerPanel = uipanel('Parent', mainContainer, ...
  'Tag', 'ADSBMLAppViewerPanel', ...
  'Units', 'pixels', 'AutoResizeChildren', 'off');

% Instantiate the viewer and controller
viewer = helperAdsbViewer('ParentHandle', viewerPanel, 'isInApp', true);
controller = helperAdsbController('ParentHandle', controllerPanel, ...
  'Viewer', viewer);
render(controller);

movegui(figureHandle, 'center');
drawnow
figureHandle.Position = [figureHandle.Position(1), figureHandle.Position(2), 1053, 525];
drawnow
figureHandle.Visible = 'on';

if nargout > 0
    varargout{1} = controller;
end
if nargout > 1
    varargout{2} = viewer;
end

end