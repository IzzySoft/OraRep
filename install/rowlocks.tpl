<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15">
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
 <TITLE>OraHelp: Row Locks</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <H3>What are Row Locks?</H3>
 <P>Row locks (also referred to as transaction (TX) locks) indicate multiple
  users try modifying the same row of a table (row-level-lock) or a row that is
  covered by the same bitmap index fragment, or a session is waiting for an ITL
  (interested transaction list) slot in a block, but one or more sessions have
  rows locked in the same block, and there is no free ITL slot in the block.</P>

 <H3>What can I do?</H3>
 <P>In the first case, the first user has to <CODE>COMMIT</CODE> or
  <CODE>ROLLBACK</CODE> to solve the problem. If multiple transactions
  concurrently hold share table locks for the same table, no transaction can
  update the table (even if row locks are held as the result of a
  <CODE>SELECT... FOR UPDATE</CODE> statement). Therefore, if concurrent share
  table locks on the same table are common, updates cannot proceed and
  deadlocks are common.</P>
 <P>In the second case, increasing the number of ITLs available is the answer
  - which can be done by changing either the
  <A HREF="initrans.html"><CODE>INITRANS</CODE> or <CODE>MAXTRANS</CODE></A>
  for the table in question.</P>
 <P>One more possible reason for <CODE>row lock waits</CODE> are
  <CODE>INSERT</CODE> and <CODE>UPDATE</CODE> statements on a child table
  waiting for row locks on the parent table to clear (foreign key). In this
  case, the only thing that can be done is causing the transaction that holds
  the locks on the parent table to <CODE>COMMIT</CODE> or <CODE>ROLLBACK</CODE>
  - or to wait until it does so unsolicitedly.</P>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OraRep '+version+' &copy; 2003-2004 by <A STYLE="text-decoration:none" HREF="http://www.qumran.org/homes/izzy/" TARGET="_blank">Itzchak Rehberg<\/A> &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
