<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15"/>
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'/>
 <TITLE>OraHelp: Enqueue Waits</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD>
 <P>Below you find a description on selected queue types:</P>
 <TABLE BORDER="0">
  <TR><TD CLASS="smallname">CF</TD>
      <TD><B>Control file schema global enqueue</TD></TR>
  <TR><TD CLASS="smallname">CU</TD>
      <TD><B>Cursor Bind</B></TD></TR>
  <TR><TD CLASS="smallname">DX</TD>
      <TD><B>Distributed Transactions</B></TD></TR>
  <TR><TD CLASS="smallname">HW</TD>
      <TD><B>Space Management</B> operations on a specific
          segment</TD></TR>
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
  <TR><TD CLASS="smallname">TM</TD>
      <TD><B>Table locks</B> point to the possibility of e.g.
          foreign key constraints not being indexed</TD></TR>
  <TR><TD CLASS="smallname">TX</TD>
      <TD><B>Transaction locks</B> indicate multiple users try
          modifying the same row of a table (row-level-lock)</TD></TR>
 </TABLE>

</BODY></HTML>
