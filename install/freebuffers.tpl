<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15"/>
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'/>
 <TITLE>OraHelp: Free Buffer Waits</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <H3>What are <CODE>free buffer waits</CODE>?</H3>
 <P>The <code>free buffer waits</code> event occurs when the database attemts
  to locate a clean block buffer but cannot because there are too many
  outstanding dirty blocks waiting to be written. This could be an indication
  that either your database is having an IO problem (check the other IO related
  wait events to validate this), there are other resources waited for (such as
  latches), the buffer cache is so small that DBWR spends most of its time
  cleaning out buffers for server processes, or the buffer cache is so big that
  one DBWR process is not enough to free enough buffers in the cache to
  satisfy requests.</P>
 <P>If you changed the state of a tablespace from "read only" to "read write",
  all buffers are reset. In this case, you may also encounter <CODE>free
  buffer waits</CODE> - which of course will not be subject to tuning actions.
  So if this event just occured occasionally, check whether this may have
  been the reason before being worried about the performance of your instance.</P>
 <H3>What actions can be taken?</H3>
  <P>If this event occurs frequently, then examine the session waits for DBWR
   to see whether there is anything delaying DBWR:</P>
 <TABLE ALIGN="center" WIDTH="95%" BORDER="1">
  <TR><TH>Reason</TH><TH>Action</TH></TR>
  <TR><TD>Writes</TD><TD CLASS="text">If it is waiting for writes, then
      determine what is delaying the writes and fix it. Check the following:<UL>
       <LI>Examine <CODE>V$FILESTAT</CODE> to see where most of the writes
           are happening</LI>
       <LI>Examine the host OS statistics for the I/O system. Are the write
           times acceptable?</LI>
      </UL>
      If I/O is slow:<UL>
       <LI>Consider using faster I/O alternatives to speed up write times.</LI>
       <LI>Spread the I/O activity across large number of spindles (disks)
           and controllers.</LI>
      </UL></TD></TR>
  <TR><TD>Cache is too small</TD><TD CLASS="text">It is possible DBWR is very
      active because of the cache is too small. Investigate whether this is a
      probably cause by looking to see if the buffer cache hit ratio is low.
      Also use the <CODE>V$DB_CACHE_ADVICE</CODE> view to determine whether a
      larger cache size would be advantageous.</TD></TR>
  <TR><TD>Cache is too big</TD><TD CLASS="text">If the cache size is adequate
      and the I/O is already evenly spread, then you can potentially modify the
      behaviour of DBWR by using asynchronous I/O or by using multiple database
      writers.<BR>
      <B>Consider multiple database writer (DBWR) processes or I/O Slaves</B><BR>
      Configuring multiple database writer processes, or using I/O slaves, is
      useful when the transaction rates are high or when the buffer cache size
      is so large that a single DBW<I>n</I> process cannot keep up with the
      load.<BR>
      <B><CODE>DB_WRITER_PROCESSES</CODE></B><BR>
      The <CODE>DB_WRITER_PROCESSES</CODE> initialization parameter lets you
      configure multiple database writer processes (from DBW0 to DBW9).
      Configuring multiple DBWR processes distributes the work required to
      identify buffers to be written, and it also distributes the I/O load
      over these processes.<BR>
      <B><CODE>DBWR_IO_SLAVES</CODE></B><BR>
      If it is not practical to use multiple DBWR processes, then Oracle
      provides a facility whereby the I/O load can be distributed over multiple
      slave processes. The DBWR process is the only process that scans the
      buffer cache LRU list for blocks to be written out. However, the I/O for
      those blocks is performed by the I/O slaves. The number of I/O slaves is
      determined by the parameter <CODE>DBWR_IO_SLAVES</CODE>. I/O slaves are
      also useful when asynchronous I/O is not available, because the multiple
      I/O slaves simulate nonblocking, asynchronous requests by freeing DBWR
      to continue identifying blocks in the cache to be written.<BR>
      <B>Decide between additional DBWRs and I/O Slaves</B><BR>
      First you should check whether asynchronous I/O is supported and used by
      your system. If it is supported but not used, enable asynchronous I/O to
      see if this alleviates the problem.<BR>
      Using multiple DBWRs parallelizes the gathering and writing of buffers.
      Therefore, multiple DBW<I>n</I> processes should deliver more throughput
      than one DBWR process with the same number of I/O slaves. For this
      reason, the use of I/O slaves has been deprecated in favour of multiple
      DBWR processes. I/O slaves should only be used if multiple DBWR processes
      cannot be configured.</TD></TR>
 </TABLE>
 <P>Another possible solution is to adjust the frequency of your checkpoints by
  tuning the <CODE>CHECK_POINT_TIMEOUT</CODE> and
  <CODE>CHECK_POINT_INTERVAL</CODE> parameters to help the DBWR process to keep
  up. Increasing the buffer cache may also be helpful.</P>

</TD></TR></TABLE>

</BODY></HTML>
