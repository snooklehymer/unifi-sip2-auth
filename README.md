unifi-sip2-auth
===============

Authentication module for Unifi AP Controller againt 3M SIP2 server,
This module is designed for Unifi APs using the Unifi AP controller.

Overview
=========
The Unifi APs can be used in the Enterprise to allow access to local networks. This module is designed to allow users access
a local network only after they are authenticated against a 3M SIP2 server - used around the world on many Library Management Systems.

While there exists products to enable wireless authentication agains SIP2 servers they tend to be quite expensive and 
require purchase of either expensive hardware or software. This module if freely availble under the MIT license and can be
installed locally (on the same box as the Unifi controller if needed) and configure to point at your SIP2 server.

Features
==========
 - Local Admin interface for configuration
 - Connection to local or remote SIP2 servers
 - Adheres to most, if not all, of the SIP2 specification relating to SIP2 server login and 63/64 strings
 - Can validate agains Parton ID & PIN or just Patron ID
 - Toggle send character (CR or NL) to cover most SIP servers
 - Support for split messages across SIP responses
 - Strong SIP validation rule enforcing. Allow/dissallow access based on SIP2 attributes e.g Expired Patrons,
   Patrons under age, Screen Message (AF) string etc.
 - Intercepts original destination webpage and force users to land on a redirected page of your choice
 

Installation
=============
Please see the INSTALL document for install details
   
