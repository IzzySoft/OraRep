<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15"/>
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'/>
 <TITLE>OraHelp: Enqueue Waits</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD>
 <P>Below you find a description on selected queue types:</P>
 <TABLE BORDER="0">
  <TR><TD CLASS="smallname">BL</TD>
      <TD><B>Buffer Cache Managment</B></TD></TR>
  <TR><TD CLASS="smallname">CF</TD>
      <TD><B>Control file schema</B> global enqueue</TD></TR>
  <TR><TD CLASS="smallname">CI</TD>
      <TD><B>Cross Instance</B> call invocation</TD></TR>
  <TR><TD CLASS="smallname">CU</TD>
      <TD><B>Cursor Bind</B></TD></TR>
  <TR><TD CLASS="smallname">DF</TD>
      <TD><B>Datafile</B></TD></TR>
  <TR><TD CLASS="smallname">DL</TD>
      <TD><B>Direct Loader</B> index creation</TD></TR>
  <TR><TD CLASS="smallname">DR</TD>
      <TD><B>Distributed Recovery</B></TD></TR>
  <TR><TD CLASS="smallname">DX</TD>
      <TD><B>Distributed Transactions</B></TD></TR>
  <TR><TD CLASS="smallname">IR</TD>
      <TD><B>Instance Recovery</B></TD></TR>
  <TR><TD CLASS="smallname">HW</TD>
      <TD><B>Space Management</B> operations on a specific
          segment</TD></TR>
  <TR><TD CLASS="smallname">LA..LP</TD>
      <TD><B>Library Cache</B> Lock</TD></TR>
  <TR><TD CLASS="smallname">MD</TD>
      <TD><B>Materialized Views:</B> enqueue for change data capture
          materialized view log (gotten internally for DDL on a snapshot
	  log); id1=object# of the snapshot log.</TD></TR>
  <TR><TD CLASS="smallname">NA..NZ</TD>
      <TD><B>Library Cache</B> Pin</TD></TR>
  <TR><TD CLASS="smallname">SQ</TD>
      <TD><B>SeQuences</B> not being cached, having a to small
          cache size or being aged out of the shared pool. Consider pinning
	  sequences or increasing the shared_pool_size.</TD></TR>
  <TR><TD CLASS="smallname">ST</TD>
      <TD><B>Space management locks</B> could be caused by using
          permanent tablespaces for sorting (rather than temporary), or by
	  dynamic allocation resulting from inadequate storage clauses. In the
	  latter case, using locally-managed tablespaces may help avoiding this
	  problem.</TD></TR>
  <TR><TD CLASS="smallname">TA</TD>
      <TD><B>Transaction Recovery</B></TD></TR>
  <TR><TD CLASS="smallname">TM</TD>
      <TD><B>Table locks</B> point to the possibility of e.g.
          foreign key constraints not being indexed</TD></TR>
  <TR><TD CLASS="smallname">TX</TD>
      <TD><B>Transaction locks</B> indicate multiple users try
          modifying the same row of a table (row-level-lock)</TD></TR>
  <TR><TD CLASS="smallname">US</TD>
      <TD><B>Undo Segment</B>, serialization</TD></TR>
 </TABLE>

</BODY></HTML>
