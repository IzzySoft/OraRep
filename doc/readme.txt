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

1. Create the directory where the report files (*.html) should be placed in.
   As example, we assume the /var/www/html/oracle/reports directory here.
2. Below this directory, create another directory named "help"
3. Create a directory to hold the scripts - this should *NOT* be below your
   web servers document root. As example, we use ~/scripts here.
4. Unpack this archive (including the plugins/ sub directories) to ~/scripts
   (since you read this file, you may already have the archive unpacked; in
   this case just move the files there).
5. Edit the ~/scripts/config file to reflect your settings. Important to change
   are at least the settings for user, password, REPDIR (if other than in our
   example) and the location of the style sheet (which you need to copy there;
   just chose one from the *.css files provided in the reports/ directory)
6. Go to the ~scripts/install directory and execute mkhelp.sh which creates
   the help files (placement of the stylesheet is adjusted this way)
7. In six days G*d created the heavens and the earth - the seventh is Shabbat,
   and He rested. Get yourself a cup of coffee, tea or whatever you like, and
   relax for a moment.

To run the script, start report.sh - calling it with no parameters tells
you its syntax. It will run with just giving it the ORACLE_SID of the database
to report on as only parameter - provided, your Oracle environment is set up
correctly.

Have fun!
Izzy.
