<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15"/>
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'/>
 <TITLE>OraHelp: Enqueue</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD>
 <P>The <code>Enqueue</code> wait event may be an indication that something is
  either wrong with the code (should multiple sessions be serializing
  themselves against a common row?) or possibly the physical design (high
  activity on child tables with unindexed foreign keys, inadequate
  <A HREF="initrans.html"><CODE>INITRANS</CODE></A> or MAXTRANS values, etc.).
  Since this event also indicates that there are too many DML or DDL locks (or,
  maybe, a large number of sequences), increasing the
  <CODE>ENQUEUE_RESOURCES</CODE> parameter in the <CODE>init.ora</CODE> may
  help reduce these waits as well.</P>

</TD></TR></TABLE>

</BODY></HTML>
