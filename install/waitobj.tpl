<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15"/>
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'/>
 <TITLE>OraHelp: Objects causing Wait Events</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD>
 <P>If you had many <CODE>db file * reads</CODE> above and now find some
  entries with segment type = table in here, these may need
  some|more|better|other indices. Use <I>Statspack</I> or <I>Oracle Enterprise
  Manager Diagnostics Pack</I> to find out more.</P>
 <P>Other things that may help to avoid some of the <CODE>db file * read</CODE>
  wait events are:
 <UL>
  <LI>Tune the SQL statements used by your applications and users (most
      important!)</LI>
  <LI>Re-Analyze the schema to help the optimizer with accurate data e.g.
      with <I>dbms_stats</I></LI>
  <LI>Stripe objects over multiple disk volumes</LI>
  <LI>Pin frequently used objects</LI><LI>Increase the buffer caches</LI>
 </UL>
</TD></TR></TABLE>

</BODY></HTML>
