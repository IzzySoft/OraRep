<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15"/>
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'/>
 <TITLE>OraHelp: Latch Free</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD>
 <P>The <CODE>latch free</CODE> wait event occurs whenever one Oracle process
  is requesting a "willing to wait" latch from another process. The event only
  occurs if the spin_count has been exhausted, and the waiting process goes to
  sleep.</P>
 <P>Latch free waits can occur for a variety of reasons including library cache
  issues, OS process intervention (processes being put to sleep by the OS, etc.),
  and so on.</P>
</TD></TR></TABLE>

</BODY></HTML>
