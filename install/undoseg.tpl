<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15"/>
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'/>
 <TITLE>OraHelp: Undo Segment Extension</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <P>Whenever the database must extend or shrink a rollback segment, the
  <CODE>undo segment extension</CODE> wait event occurs while the rollback
  segment is being manipulated. High wait times here could indicate a problem
  with the extent size, the value of <CODE>MINEXTENTS</CODE>, or possibly IO
  related problems.
</TD></TR></TABLE>

</BODY></HTML>
