<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15"/>
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'/>
 <TITLE>OraHelp: FreeList Contention</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
<H3>What is that "FreeList Contention" and what effects does it have?</H3>
<P>This is best explained using an example. Imagine you are going to insert a
 large amount of rows into a table which is already frequently used. For this
 Oracle must find blocks with free space in them. That is done by consulting
 the <I>Freelists</I>.</P>
<P>Which block comes on a freelist depends on the settings of
 <CODE>PCTFREE</CODE> and <CODE>PCTUSED</CODE> for the table in question:
 <I>Inserts</I> may use all space except <CODE>PCTFREE</CODE> in a block, the
 remaining space is reserved for <I>Updates</I>. So if there's less than
 <CODE>PCTFREE</CODE> space available in a block, this block is removed from
 the freelist. Now, if an <I>Update</I> finds a block filled less than
 <CODE>PCTUSED</CODE>, this block is moved to a freelist again.</P>
<P>Now back to our example. Let's assume <CODE>PCTFREE</CODE> is set to 5, and
 <CODE>PCTUSED</CODE> to 90. Now comes our <I>Insert</I>, finds a lot of blocks
 that are filled to about 75% - but the remaining 20% are too small to keep an
 entire row. So in order to not having to inspect this block on the next insert,
 it is removed from the freelist.</P>
<P>Next comes a large <I>Update</I>. As it goes, it touches a lot of the blocks
 that just have been removed from the freelist and finds, that the used space is
 less than <CODE>PCTUSED</CODE>, so the block comes back to the freelist. So on
 the next <I>Insert</I>, they all will be inspected again and probably moved
 back from the freelist again. All in all, a useless overhead - and
 unnecessarily making the transaction using more time and resources.</P>
<P>In our example it is very clear that the span between <CODE>PCTFREE</CODE>
 and <CODE>PCTUSED</CODE> is too small and the described problem is subject to
 occur quite often.</P>

<H3>Explanation of the table columns</H3>
<P>The table in the report lists up the key data for our problem, one row for
 each possibly affected table. Like already may be obvious by above description,
 we list only tables where there's more space available than defined by
 <CODE>PCTFREE</CODE> and less space used than permitted by <CODE>PCTUSED</CODE>
 (so the block will be on the freelist for inserts) plus the average row length
 is to large to fit into the gap.<BR>
 Following is an explanation of the columns:</P>
 <TABLE ALIGN="center" BORDER="1">
  <TR><TH CLASS="th_sub">Column</TH><TH CLASS="th_sub">Description</TH></TR>
  <TR><TD>Owner</TD><TD>The schema this table belongs to</TD></TR>
  <TR><TD>Table</TD><TD>Name of the table</TD></TR>
  <TR><TD>AvgRowLen</TD><TD>Average Size of each table row (in bytes)</TD></TR>
  <TR><TD>PctUsed</TD><TD ROWSPAN="2">Table settings, adjustable via the
      <CODE>ALTER TABLE</CODE> command</TD></TR>
  <TR><TD>PctFree</TD></TR>
  <TR><TD>FreeLists</TD><TD>Available freelists for this table</TD></TR>
  <TR><TD>AvgFreeSpace</TD><TD>Average size (bytes) available per block</TD></TR>
  <TR><TD>BlockSize</TD><TD>Block size used for the tablespace</TD></TR>
 </TABLE>

<H3>The result set</H3>
<P>If you get no results within the table, the reasons can be different:</P>
<UL>
 <LI><B>Your tables are not analyzed.</B><BR>
     In order to obtain the needed data for the above described evaluation,
     we need to access the tables statistics in the <CODE>all_tables</CODE>
     system view. As a recommendation, <I>ESTIMATE</I> the statistics at least
     for possible candidates.</LI>
 <LI><B>Your problem is a different one.</B><BR>
     Since the above described scenario is just one possible reason for
     <CODE>buffer busy waits</CODE> (and other waits that <I>may</I> point to
     a freelist contention), you may have to search for the cause of your
     problem at another point.</LI>
 <LI><B>This problem affects almost nobody.</B><BR>
     Although the above scenario (which I found in some tuning book) sounds
     very reasonable, I didn't find any database where this query had any
     result (if one of your databases is the exception, please let me know!!!).
     So possibly, this problem is just of academical nature.</LI>
</UL>

</TD></TR></TABLE>

</BODY></HTML>
