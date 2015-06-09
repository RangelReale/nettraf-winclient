NetTraf Windows Client 1.4.0.1
==============================

Welcome to the Windows client for the NetTrafD daemon. This program checks the data sent and received from a Linux interface, and draw graphs and show lights on the taskbar to let the user know how the connection is going.

Changes
-------

* Version 1.4.0.1 (not offical version by smurfy)
- fixed "is no valid integer" problem (hope so)
- added if inet connections dropped or pc wake up from hibernate mode nettraf detect it and reconnect to core

* Version 1.4.0.0 (not offical version by smurfy)
- Added Password support to GUI (need the non offical core for that)
- Added IP-Address display (need the non offical core for that)
- Changed the in/out color to red (out) and blue (in)
- You now can set the GUI always on top when you doubleclick on the main Window (like Windows Taskmanager)
- Added a Option to display the current sent and received infos in taskbar (title of Application)

* Version 1.3.0.0
- Can use the new nettrafd 1.3 interface, which allows people with very fast persistent network connections to use the program
- The taskbar icons can now show the amount of data passed on the connection, instead of only 'data/no data'
- Data logging can be enabled, so you can see on-screen how much data you have sent/received, and since when it started logging. (NOTE: people with fast net connections should not enable this, as it is still limited to 4GB)

* Version 1.1.0.0
- Added About menu
- Added "Show help" menu, so I don't need to describe all the graph information here ;)
- Now the graph shows the average rate, both numerically and as a gray line on the graph.
- The values are now internally stored as unsigned int, so you can now download up to 4GB of data that the program will correctly calculate all the values. ;)

* Version 1.0
- Initial version

Author Offical GUI
------
Rangel Reale
rangel.reale@yahoo.com
http://www.geocities.com/CapeCanaveral/2064/nettraf.html
Brazil
Author Inoffical GUI
------
Smurfy
nettraf@smurfy.de
Changed some things in Nettrafd and the Windows GUI
