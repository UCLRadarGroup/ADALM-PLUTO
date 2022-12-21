function h = helperAdsbBin2Hex(b)
%helperAdsbBin2Hex Binary to hexadecimal converter
%   H = helperAdsbBin2Hex(B) converts binary numeric array B to a
%   hexadecimal character array. B must be a column vector with the number
%   of elements a multiple of four.
%
%   See also ADSBExample, helperAdsbRxMsgParser, helperAdsbViewer.

%   Copyright 2015-2016 The MathWorks, Inc.

numHexSymbols = length(b)/4;
h = repmat(' ', 1, numHexSymbols);
hexSymbols = '0123456789ABCDEF';
idx = 1:4;
for p=1:numHexSymbols
  h(p) = hexSymbols([8 4 2 1]*single(b(idx,1))+1);
  idx = idx+4;
end
end

