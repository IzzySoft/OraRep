<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15"/>
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'/>
 <TITLE>OraHelp: Row Locks</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD>
 <P>Row locks (also referred to as transaction (TX) locks) are generally
  indicative of poor application design, as they indicate different users
  contending for the same row of data. If multiple transactions concurrently
  hold share table locks for the same table, no transaction can update the
  table (even if row locks are held as the result of a <CODE>SELECT... FOR
  UPDATE</CODE> statement). Therefore, if concurrent share table locks on the
  same table are common, updates cannot proceed and deadlocks are common.</P>
 <P>One more possible reason for <CODE>row lock waits</CODE> are
  <CODE>INSERT</CODE> and <CODE>UPDATE</CODE> statements on a child table
  waiting for row locks on the parent table to clear (foreign key).</P>
</TD></TR></TABLE>

</BODY></HTML>
