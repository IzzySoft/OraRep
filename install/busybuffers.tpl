<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15"/>
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'/>
 <TITLE>OraHelp: Buffer Busy Waits</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD>
 <H3>What are <CODE>buffer busy waits</CODE>?</H3>
 <P>If two processes try (almost) simultaneously the same block and the block
  is not resident in the <CODE>buffer cache</CODE>, one process will allocate
  a buffer in the buffer cache, lock it and read the block into the buffer.
  The other process is locked until the block is read. This wait is refered to
  as <CODE>buffer busy wait</CODE>.</P>
 <P>The type of buffer that causes the wait can be queried with
  <CODE>v$waitstat</CODE>, which lists the waits per buffer type for
  <CODE>buffer busy waits</CODE> only.</P>

 <H3>What types of buffers is waited for?</H3>
 <TABLE ALIGN="center" BORDER="1" WIDTH="90%">
  <TR><TH>Block</TH><TH>Description</TH></TR>
  <TR><TD>segment header</TD><TD>The problem is probably a freelist contention.</TD></TR>
  <TR><TD>data block</TD><TD>Increasing the size of the <CODE>database buffer
      cache</CODE> can help to reduce these waits; but this can also point
      to freelist contention.</TD></TR>
  <TR><TD>undo header</TD><TD ROWSPAN="2">If you don't use Undo TableSpaces,
      you probably have too few rollback segments.</TD></TR>
  <TR><TD>undo block</TD></TR>
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
  <TABLE ALIGN="center"><TR><TD>
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
  <TABLE ALIGN="center"><TR><TD>
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

</BODY></HTML>
