function NL = helperAdsbNL(lat)
%helperAdsbNL   Number of longitude zones
%   NL = helperAdsbNL(LAT) returns the number of longitude zones for
%   latitude, LAT.
%
%   See also ADSBExample, helperAdsbRxMsgParser.

%   Copyright 2015-2016 The MathWorks, Inc.

NL = coder.nullcopy(zeros(1,1));

latTable = ...
  [87.0000000000000 86.5353699751210 85.7554162094442 84.8916619070208 ...
   83.9917356298056 83.0719944471981 82.1395698051061 81.1980134927195 ...
   80.2492321328051 79.2942822545693 78.3337408292275 77.3678946132819 ...
   76.3968439079447 75.4205625665336 74.4389341572514 73.4517744166786 ...
   72.4588454472894 71.4598647302898 70.4545107498760 69.4424263114402 ...
   68.4232202208333 67.3964677408466 66.3617100838262 65.3184530968209 ...
   64.2661652256744 63.2042747938193 62.1321665921033 61.0491777424635 ...
   59.9545927669403 58.8476377614846 57.7274735386611 56.5931875620592 ...
   55.4437844449504 54.2781747227290 53.0951615279600 51.8934246916877 ...
   50.6715016555384 49.4277643925569 48.1603912809662 46.8673325249875 ...
   45.5462672266023 44.1945495141927 42.8091401224355 41.3865183226024 ...
   39.9225668433386 38.4124189241226 36.8502510759353 35.2289959779638 ...
   33.5399343629848 31.7720970768108 29.9113568573181 27.9389871012190 ...
   25.8292470705878 23.5450448655707 21.0293949260285 18.1862635707134 ...
   14.8281743686868 10.4704712999685 0];
 NL(1) = find(latTable<lat,1,'first');
end
