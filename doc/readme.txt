# =============================================================================
# Oracle Basis Report 2 HTML           (c) 2003 by IzzySoft (devel@izzysoft.de)
# -----------------------------------------------------------------------------
# $Id$
# -----------------------------------------------------------------------------
# Create an Oracle (Basis) Report in HTML format
# =============================================================================

Contents
--------

1) Copyright and warranty
2) Requirements
3) Limitations
4) Installation

===============================================================================

1) Copyright and Warranty
-------------------------

This little program is (c)opyrighted by Andreas Itzchak Rehberg
(devel@izzysoft.de) and protected by the GNU Public License Version 2 (GPL).
For details on the License see the file LICENSE in this directory. The
contents of this archive may only be distributed all together.

===============================================================================

2) Requirements
---------------

Since this is a report generator for Oracle Databases, it implies one simple
requirement: an Oracle Database to report on. Additionally, you must have a
shell available - what implies that you run a *NIX operating system. Tested
on RedHat Linux with the bash shell v2.

===============================================================================

3) Limitations
--------------

I tested the script successfully with Oracle v8.1.7, v9.0.1 and v9.2. Basically,
it should work with any version - but I cannot promise this (reports are
welcome). So far, no limitations are know - except that it does report no more
than it does report :-)

===============================================================================

4) Installation
---------------

Just copy all files from the root directory of this archive to a suitable
place and adjust the configuration (to be found in the file "config") to
reflect your settings. Place the main.css file from the reports/ sub directory
in your web tree at the location you configured within the config file.
To run the script, start report.sh - calling it with no parameters tells
you its syntax. It will run with just giving it the ORACLE_SID of the database
to report on as only parameter - provided, your Oracle environment is set up
correctly. The optional second parameter is a directory to change to at the
start of the script - this may be useful if you used relative path names in
your configuration and/or run the script from a wrapper.

Have fun!
Izzy.
