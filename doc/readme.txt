Report generator for Oracle 8i databases. For details see head of report.sh
P.S.: put the main.css file into your web directory, adjust it to your needs.
(c) 2003 by Itzchak Rehberg & IzzySoft

History:
========

v0.1.0 (19.01.2003)  initial version (first release)

v0.1.1 (28.10.2003)  small fixes:
! fixed a "division by zero" error rarely occuring on freepct check for tables
+ added progInfo footer with link to web site of IzzySoft (e.g. for retrieving
  updates of this little tool ;)
+ added instance startup time and uptime to Common Instance Information
! fixed "invalid number error" occuring when sizes in the DB haven't been
  declared in bytes but as e.g. "5M"
! in datafile statistics, when a datafile was filled more than 99.99%, the
  pctused column got the value '######' for this row

v0.1.2 (xx.xx.2003)  small enhancements:
+ in the "Data Files" block, statistics are now grouped by data files instead
  of listing up each segment separately
+ some comments/recommendations are now more precise
+ for the wait events, objects that caused them (at the time the report was
  generated) are listed
+ added more hints/comments
