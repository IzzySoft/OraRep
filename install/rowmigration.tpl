<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15">
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
 <TITLE>OraHelp: Row Migration</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <H3>What is row migration?</H3>
 <P>If an <CODE>UPDATE</CODE> statement increases the amount of data in a row
  so that the row no longer fits into its data block, Oracle tries to find
  another block with enough free space to hold the entire row. If such a block
  is available, Oracle moves the entire row to the new block while the original
  row piece is kept to point to the new block containing the actual data. The
  rowid of the migrated row does not change, and indices are not updated - so
  they still point to the original location.</P>
 <H3>What is the result of this?</H3>
 <P>Whenever data of a migrated row are to be read, this requires an additional
  read (one for the original location just holding the pointer to the real
  location, and one for the real data). Thus, migrated rows can cause acute
  performance degration - the more you have the more you will feel the results.
  This means, they should be corrected immediately if they are being reported.</P>
 <H3>What factors can influence this?</H3>
 <P>First, the settings for <CODE>PCTUSED</CODE> and <CODE>PCTFREE</CODE> are
  the most common causes. If there was too less <CODE>PCTFREE</CODE> reserved
  at table creation, <CODE>INSERT</CODE> statements occupied space in the blocks
  no longer available for <CODE>UPDATE</CODE>s at a later time. The result is
  described above: the updated row may have to be migrated.</P>
 <H3>So how to fix this?</H3>
  <P>For this, you first have to analyse your tables:</P>
  <TABLE ALIGN="center" STYLE="border:0"><TR><TD>
  <DIV CLASS="code" STYLE="width:42em">
  ANALYZE TABLE tablename COMPUTE STATISTICS;<BR>
  SELECT num_rows,chain_cnt FROM dba_tables WHERE table_name='tablename';
  </DIV></TD></TR></TABLE>
 <P><CODE>utlchain.sql</CODE> then may help you to automatically eliminate
  migration. Make sure to correct <CODE>PCTFREE</CODE> before running this
  script - otherwise it is very likely that this problem will re-occur soon.</P>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OraRep '+version+' &copy; 2003-2004 by <A STYLE="text-decoration:none" HREF="http://www.qumran.org/homes/izzy/" TARGET="_blank">Itzchak Rehberg<\/A> &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
