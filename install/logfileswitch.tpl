<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15">
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
 <TITLE>OraHelp: Log File Switch</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <H3>What does this event mean?</H3>
 <P>In both events, <CODE>log file switch (archiving needed)</CODE> and
    <CODE>log file switch (checkpoint incomplete)</CODE>, the LGWR is unable
    to switch into the next online redo log, and all the commit requests wait
    for this event.</P>
 <H3>What actions can be taken?</H3>
 <P>For the <CODE>log file switch (archiving needed)</CODE> event, examine why
    the archiver is unable to archive the logs in a timely fashion. It could be
    due to the following:<UL>
    <LI>Archive destination is running out of free space.</LI>
    <LI>Archiver is not able to read redo logs fast enough (contention with
        the LGWR).</LI>
    <LI>Archiver is not able to write fast enough (contention on the archive
        destination, or not enough ARCH processes).</LI></UL>
 <P>Depending on the nature of bottleneck, you might need to redistribute I/O
    or add more space to the archive destination to alleviate the problem. For
    the <CODE>log file switch (checkpoint incomplete)</CODE> event:</P><UL>
    <LI>Check if DBWR is slow, possibly due to an overloaded or slow I/O
        system. Check the DBWR write times, check the I/O system, and
        distribute I/O if necessary.</LI>
    <LI>Check if there are too few, or too small redo logs. If you have a few
        and/or small redo logs (for example two x 100k logs), and your system
        produces enough redo to cycle through all of the logs before DBWR has
        been able to complete the checkpoint, then increase the size and/or
        number of redo logs.</LI></UL>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OraRep '+version+' &copy; 2003-2004 by <A STYLE="text-decoration:none" HREF="http://www.qumran.org/homes/izzy/" TARGET="_blank">Itzchak Rehberg<\/A> &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
