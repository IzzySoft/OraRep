<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15"/>
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'/>
 <TITLE>OraHelp: RollBack Stats</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <H3>What are Rollback Segments?</H3>
 <P>The primary task of Rollback Segments is to keep the "before image" of data
  records until changes of transactions have been committed. This makes sure
  that <CODE>ROLLBACK</CODE>s are possible - either explicit by the user or
  implicit by the PMON process. Oracle uses rollback segments for all
  transactions that change the database and assigns every such transaction to
  one of the available rollback segments. Every rollback segment has a
  transaction table in its header and every write transaction, moreover, must
  periodically acquire update access to the transaction table of its rollback
  segment.</P>
 <P>Starting with Oracle 9i automatic Undo handling has been introduced. By this,
  you do no longer have to take care for Rollback Segments manually, but Oracle
  itself will do so automatically. It is recommended to use this feature. In
  order to do so, create an Undo tablespace and set <CODE>UNDO_MANAGEMENT</CODE>
  in your <CODE>init.ora</CODE> to <CODE>AUTO</CODE>.</P>

 <H3>What do the columns of this report table mean?</H3>
 <TABLE ALIGN="center" WIDTH="95%" BORDER="1">
  <TR><TH CLASS="th_sub">Column</TH><TH CLASS="th_sub">Explanation</TH></TR>
  <TR><TD CLASS="inner">Segment</TD><TD CLASS="inner" STYLE="text-align:justify">The segments name</TD></TR>
  <TR><TD CLASS="inner">Status</TD><TD CLASS="inner" STYLE="text-align:justify">Whether this segment is currently
      available (<CODE>ONLINE</CODE>) or not</TD></TR>
  <TR><TD CLASS="inner">Size</TD><TD CLASS="inner" STYLE="text-align:justify">The actual size of this segment</TD></TR>
  <TR><TD CLASS="inner">OptSize</TD><TD CLASS="inner" STYLE="text-align:justify">The optimal size of this segment as defined
      at creation of the segment or with the <CODE>ALTER</CODE> command at a
      later time</TD></TR>
  <TR><TD CLASS="inner">HWMSize</TD><TD CLASS="inner" STYLE="text-align:justify">Size reached by the largest transaction
      we've had</TD></TR>
  <TR><TD CLASS="inner">Waits</TD><TD CLASS="inner" STYLE="text-align:justify">Indicates contention for RBS extents - if
      this value is "large" then there my be a requirement for more RBS extents;
      see recommendations below</TD></TR>
  <TR><TD CLASS="inner">XActs</TD><TD CLASS="inner" STYLE="text-align:justify">current transactions</TD></TR>
  <TR><TD CLASS="inner">Shrinks</TD><TD CLASS="inner" STYLE="text-align:justify">Number of growth beyond the
      <CODE>OPTIMAL<CODE> value (see OptSize in this table) that have been shrunk
      afterwards</TD></TR>
  <TR><TD CLASS="inner">Wraps</TD><TD CLASS="inner" STYLE="text-align:justify">Wraps occur whenever a new extent is needed
      but the next extent in the current RBS is still in use by a transaction,
      so a new extent has to be allocated. This column tells how many times a
      wrap occured.</TD></TR>
  <TR><TD CLASS="inner">AveShrink</TD><TD CLASS="inner" STYLE="text-align:justify">Average amount that this RBS has been
      shrunk</TD></TR>
  <TR><TD CLASS="inner">AveActive</TD><TD CLASS="inner" STYLE="text-align:justify">Average transaction size for this RBS</TD></TR>
 </TABLE>

 <H3>What are recommended actions to take?</H3>
 <TABLE ALIGN="center" WIDTH="95%" BORDER="1">
  <TR><TH CLASS="th_sub">Cumulative # of Shrinks</TH>
      <TH CLASS="th_sub">AveShrink</TH>
      <TH CLASS="th_sub">Recommendation</TH></TR>
  <TR><TD CLASS="inner"><DIV ALIGN="center">Low</DIV></TD>
      <TD CLASS="inner"><DIV ALIGN="center">Low</DIV></TD>
      <TD CLASS="inner" STYLE="text-align:justify">If the value for <I>AveActive</I> is close to
          <I>OptSize</I>, the settings are correct. If not, then the settings
          for <I>OPTIMAL</I> are too large.<BR>
          <FONT SIZE="-1">Note: Be aware that it is sometimes better to have
          a larger <CODE>OPTIMAL</CODE> value - depending on the nature of the
          applications running, reducing it towards <I>AveActive</I> may cause
          some applications to start experiencing <CODE>ORA-01555</CODE>.</FONT></TD></TR>
  <TR><TD CLASS="inner"><DIV ALIGN="center">Low</DIV></TD>
      <TD CLASS="inner"><DIV ALIGN="center">High</DIV></TD>
      <TD CLASS="inner" STYLE="text-align:justify">Excellent - few, large shrinks!</TD></TR>
  <TR><TD CLASS="inner"><DIV ALIGN="center">High</DIV></TD>
      <TD CLASS="inner"><DIV ALIGN="center">Low</DIV></TD>
      <TD CLASS="inner" STYLE="text-align:justify">Too many shrinks - <CODE>OPTIMAL</CODE> is too small!</TD></TR>
  <TR><TD CLASS="inner"><DIV ALIGN="center">High</DIV></TD>
      <TD CLASS="inner"><DIV ALIGN="center">High</DIV></TD>
      <TD CLASS="inner" STYLE="text-align:justify">Increase <CODE>OPTIMAL</CODE> until the number
          of shrinks is lower.</TD></TR>
 </TABLE>
</TD></TR></TABLE>

</BODY></HTML>
