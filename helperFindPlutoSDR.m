function address = helperFindPlutoSDR()
%helperFindPlutoSDR Find an PlutoSDR on the host computer
%   R = helperFindPlutoSDR searches the host computer 

%   Copyright 2017-2022 The MathWorks, Inc.

% First check if the HSP exists
if isempty(which('plutoradio.internal.getRootDir'))
  msg = message('comm_demos:common:NoSupportPackage', ...
    'Communications Toolbox Support Package for ADALM-PLUTO Radio', ...
    ['<a href="https://www.mathworks.com/hardware-support/' ...
    'pluto.html">ADALM-PLUTO Radio Support From Communications Toolbox</a>']);
  error(msg);
end

try
  plutoRadios = findPlutoRadio();
catch
  plutoRadios = {};
end

radioCnt = length(plutoRadios);
address = cell(radioCnt,1);
for p=1:length(plutoRadios)
  radioCnt = radioCnt + 1;
  address{p} = plutoRadios(p).RadioID;
end
