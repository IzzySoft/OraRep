<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15"/>
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'/>
 <TITLE>OraHelp: Free Buffer Waits</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD>
 <P>The <code>free buffer waits</code> event occurs when the database attemts
  to locate a clean block buffer but cannot because there are too many
  outstanding dirty blocks waiting to be written. This could be an indication
  that either your database is having an IO problem (check the other IO related
  wait events to validate this) or your database is very busy and you simply
  don''t have enough block buffers to go around.</P>
 <P>A possible solution is to adjust the frequency of your checkpoints by
  tuning the <CODE>CHECK_POINT_TIMEOUT</CODE> and
  <CODE>CHECK_POINT_INTERVAL</CODE> parameters to help the DBWR process to keep
  up. Increasing the buffer cache may also be helpful.';

</TD></TR></TABLE>

</BODY></HTML>
