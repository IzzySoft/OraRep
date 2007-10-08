<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15">
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
 <TITLE>OraHelp: Objects causing Wait Events</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <H3>Wait objects: IO</H3>
 <P>If you had many <CODE>db file * reads</CODE> and find some entries with
  segment type = table in the <I>Top_N IO objects</I>, these may need
  some|more|better|other indices. Use <I>Statspack</I> or <I>Oracle Enterprise
  Manager Diagnostics Pack</I> to find out more.</P>

 <H3>How to find out about missing indices?</H3>
 <P>If you know all applications accessing your DB instance well, you'll just
  have to analyze their statements execution plans and look for <I>full table
  scans</I>. If you find any, analyze the statement itself regarding its
  <CODE>WHERE</CODE> and <CODE>GROUP BY</CODE> clauses. Make sure that all
  columns mentioned there are member of a common index (i.e. all affected
  columns of the same table must be in one index, since only one index per
  table and statement will be used for the query). Run an <CODE>ANALYZE
  TABLE...ESTIMATE STATISTICS</CODE> for the tables in question plus their
  indices.</P>
 <P>If you want to avoid to much handwork, I recommend you to install Oracles
  <I>StatsPack</I>. Run hourly snapshots for a couple of days, and then use
  the <CODE>fts_plans.sh</CODE> provided by <I>OSPRep</I> (the companion
  program of <I>OraRep</I>, you'll find it at the
  <A HREF="http://www.izzysoft.de/?topic=oracle">IzzySoft</A> website for free
  download). This script will take the statistics and write all statements
  that caused full table scans together with their most recent execution plans
  into a separate HTML file. For these statements, follow the steps above.</P>

 <H3>What else can be done?</H3>
 <P>Things that may help to avoid some of the <CODE>db file * read</CODE>
  wait events are:
 <UL>
  <LI>Tune the SQL statements used by your applications and users (most
      important! See above for this.)</LI>
  <LI>Re-Analyze the schema to help the optimizer with accurate data e.g.
      with <I>dbms_stats</I></LI>
  <LI>Stripe objects over multiple disk volumes</LI>
  <LI>Pin frequently used objects</LI><LI>Increase the buffer caches</LI>
 </UL>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OraRep '+version+' &copy; {copy} by Itzchak Rehberg &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de/" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
