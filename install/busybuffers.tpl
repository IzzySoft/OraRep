<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15">
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
 <TITLE>OraHelp: Buffer Busy Waits</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <H3>What are <CODE>buffer busy waits</CODE>?</H3>
 <P>If two processes try (almost) simultaneously the same block and the block
  is not resident in the <CODE>buffer cache</CODE>, one process will allocate
  a buffer in the buffer cache, lock it and read the block into the buffer.
  The other process is locked until the block is read. This wait is refered to
  as <CODE>buffer busy wait</CODE>.</P>
 <P><CODE>Buffer busy waits</CODE> may also have caused <CODE>latch free</CODE>
  waits. This is a side effect of multiple simultan insert tries into the same
  block. So instead of trying to decrease the <CODE>latch free</CODE> waits
  (which are only symptomatic in these cases) by increasing the
  <CODE>SPINCOUNT</CODE> you should change the concerned object in a way that
  multiple objects are able to insert into free blocks.</P>
 <P>The type of buffer that causes the wait can be queried with
  <CODE>v$waitstat</CODE>, which lists the waits per buffer type for
  <CODE>buffer busy waits</CODE> only (see the "Buffer Waits" block of this
  report, if you enabled it in the config with <CODE>MK_BUFFRAT=1</CODE>).</P>

 <H3>What types of buffers is waited for?</H3>
 <TABLE ALIGN="center" BORDER="1" WIDTH="90%">
  <TR><TH CLASS="th_sub">Block</TH><TH CLASS="th_sub">Description</TH></TR>
  <TR><TD CLASS="inner">segment header</TD><TD CLASS="inner" STYLE="text-align:justify">The problem is probably a freelist
      contention. Use freelists or increase the amount of freelists. Use
      freelist groups (this may have markable effects even in single instances).</TD></TR>
  <TR><TD CLASS="inner">data block</TD><TD CLASS="inner" STYLE="text-align:justify">Increasing the size of the
      <CODE>db_buffer_cache</CODE> can help to reduce these waits; but this can
      also point to freelist contention:<BR>Change <CODE>PCTFREE</CODE> and/or
      <CODE>PCTUSED</CODE>: Check, whether there are indices where many
      processes insert into the same point. Increase
      <A HREF="initrans.html"><CODE>INITRANS</CODE></A>. Define less lines per
      block.<BR>
      To find out what tables may need changes to <CODE>PCT_FREE</CODE> and/or
      <CODE>PCT_USED</CODE>, turn the <I>MK_FLC</I> option on in your
      <CODE>config</CODE> file and then refer to the <A HREF="flc.html">FreeList
      Contention</A> block of the report.</TD></TR>
  <TR><TD CLASS="inner">undo header</TD><TD CLASS="inner" STYLE="text-align:justify">If you don't use Undo TableSpaces,
      you probably have too few rollback segments. In this case, add more
      rollback segments and/or increase the number of transactions per rollback
      segment.</TD></TR>
  <TR><TD CLASS="inner">undo block</TD><TD CLASS="inner" STYLE="text-align:justify">This may also point to to few rollback
      segments (see "undo header" above), but as well to their size: you may
      want to increase the size of the rollback segments. For "Parallel Server",
      you can also define more PCM locks in &lt;Parameter:GC_ROLLBACK_LOCKS&gt;</TD></TR>
  <TR><TD CLASS="inner">free list</TD><TD CLASS="inner" STYLE="text-align:justify">Add more freelists or increase the
      number of free lists. For "Parallel Server", make sure that each instance
      has its own freelist group(s).</TD></TR>
 </TABLE>

 <H3>What can I do about FreeList contention?</H3>
 <P>Beside tuning the <CODE>FREELISTS</CODE> and <CODE>FREELIST GROUPS</CODE>
  parameter for each single object (which is a bunch of work and, at least for
  <CODE>FREELIST GROUPS</CODE>, requires a complete rebuild of the affected
  table), there's something new with Oracle 9i: If you use locally managed
  tablespaces, you may benefit from a new feature called ASSM, Automatic
  Segment Space Management. This is defined at tablespace level on creation of
  the same - which means, you cannot change it for existing tablespaces but
  must create a new tablespace and move all objects there:</P>
  <TABLE ALIGN="center" STYLE="border:0"><TR><TD>
    <DIV CLASS="code" STYLE="width:28em">
    CREATE TABLESPACE index01<BR>
    DATAFILE '/disk1/oraData/index01.dbf' SIZE 750M<BR>
    AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED<BR>
    EXTENT MANAGEMENT LOCAL<BR>
    <B>SEGMENT SPACE MANAGEMENT AUTO</B>
    </DIV>
  </TD></TR></TABLE>
  <P>To ease the move of all objects, there are some scripts available for
   download at the <A HREF="http://www.izzysoft.de/?topic=oracle">IzzySoft</A>
   website: look for the DBAHelpers archive there. Create a new tablespace as
   described above, then use the <CODE>tabmove.sh</CODE> and/or
   <CODE>idxmove.sh</CODE> script from the DBAHelper archive to move all objects
   to this tablespace. When those scripts successfully finished their work,
   check for objects that may have remained in the original tablespace:</P>
  <TABLE ALIGN="center" STYLE="border:0"><TR><TD>
    <DIV CLASS="code" STYLE="width:26em">
    SELECT *<BR>
    FROM dba_segments<BR>
    WHERE tablespace_name='orig_tablespace_name'
    </DIV>
  </TD></TR></TABLE>
  <P>Of course you have to replace the string "orig_tablespace_name" with the
   name of your original tablespace (uppercase!) in the above statement. If no
   objects remained, use the <CODE>DROP TABLESPACE orig_tablespace_name</CODE>
   statement to remove the original tablespace, delete the datafile that
   belonged to it, and then create the tablespace anew with ASSM (see above).</P>
  <P>If there are any objects left in the original tablespace, check the logs
   of <CODE>tabmove.sh</CODE> and/or <CODE>idxmove.sh</CODE> for the reason:
   may be you have some objects that are not supported by ASSM - LOBs could be
   one example, see next paragraph.</P>
  <P>One side effect to consider is, that at least with Oracle 9i LOB objects
   are not supported with ASSM. So if you have LOB objects and want to use ASSM,
   you must create a separate tablespace for the LOB objects that does
   <B><I>not</I></B> use ASSM. For index tablespaces this shouldn't be a
   restriction, since one normally should not have LOB objects there.</P>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OraRep '+version+' &copy; {copy} by <A STYLE="text-decoration:none" HREF="http://www.qumran.org/homes/izzy/" TARGET="_blank">Itzchak Rehberg<\/A> &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
