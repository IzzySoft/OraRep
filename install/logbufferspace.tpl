<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15">
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
 <TITLE>OraHelp: Log buffer space</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <H3>What is this?</H3>
 <P>The <CODE>log buffer space</CODE> wait event occurs when server processes
    are waiting for free space in the log buffer, because you are writing redo
    to the log buffer faster than LGWR can write it out.</P>
 <H3>What actions can be taken?</H3>
 <P>Modify the redo log buffer size. If the size of the log buffer is already
    reasonable, then ensure that the disks on which the online redo logs reside
    do not suffer from I/O contention. The <I>log buffer space</I> wait
    event could be indicative of either disk I/O contention on the disks where
    the redo logs reside, or of a too-small log buffer. Check the I/O profile
    of the disks containing the redo logs to investigate whether the I/O system
    is the bottleneck. If the I/O system is not a problem, then the redo log
    buffer could be too small. Increase the size of the redo log buffer until
    this event is no longer significant.</P>
  <H3>What are reasonable values for the log buffer size?</H3>
  <P>A common <CODE>LOG_BUFFER</CODE> size for a system generating numerous
   logs is 3 MB to 5 MB. If the number of retries is still high after
   increasing <CODE>LOG_BUFFER</CODE> size, a problem might exist with the disk
   on which the log files reside. In that case, tune the I/O subsystem to
   increase the I/O rates for redo. One way of doing this is to use
   fine-grained striping across multiple disks. For example, use a stripe size
   of 16 KB. A simpler approach is to isolate redo logs on their own disk.</P>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OraRep '+version+' &copy; {copy} by Itzchak Rehberg &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de/" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
