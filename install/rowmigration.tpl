<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15"/>
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'/>
 <TITLE>OraHelp: Row Migration</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD>
 <P>Migrated rows can cause acute performance degration - the more you have the
  more you will feel the results. This means, they should be corrected
  immediately if they are being reported. For this, you may have to analyse
  your tables:
  <DIV CLASS="code">ANALYZE TABLE tablename COMPUTE STATISTICS;<BR>
  SELECT num_rows,chain_cnt FROM dba_tables WHERE table_name='tablename'';</DIV>
  <I>utlchain.sql</I> then may help you to automatically eliminate migration.
  Make sure to correct PCTFREE before running this script - otherwise it is
  very likely that this problem will re-occur soon.</P>
</TD></TR></TABLE>

</BODY></HTML>
