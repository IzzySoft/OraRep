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
  and so on. One possible cause can also be an oversized shared pool (yes, a
  bigger large pool not always results in better performance!): Increasing the
  shared pool allows for a larger number of versions of SQL; this will
  increase the amount of CPU and latching required for Oracle in order to
  determine whether a "new" statement is present in the library cache or not.</P>
 <P>If you have many <CODE>latch free</CODE> waits, you need to further
  investigate what latches are affected. A good point to start with is Oracle
  StatsPack which lists them all up in a reasonable order (and you may use my
  OSPRep Report generator to list them all up ;)</P>
</TD></TR></TABLE>

</BODY></HTML>
