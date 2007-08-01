<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15">
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'>
 <TITLE>OraHelp: User Information</TITLE>
</HEAD><BODY>

<TABLE WIDTH="95%" ALIGN="center"><TR><TD CLASS="text">
 <H3>User Information</H3>
 <P>This table gives you an overview on all users (schemata) existing within
  your database. Even if there is no much statistical data, you should check
  here for a few things:</P>
 <UL>
  <LI>inactive users should be <I>locked</I> (column <I>Account Status</I>)</LI>
  <LI>"temporary users" (created e.g. for a task that has a deadline) should
      have an <I>Expiry Date</I> set</LI>
  <LI>The <I>Default TS</I> should never be <CODE>SYSTEM</CODE> (except for
      <CODE>SYS</CODE> and <CODE>SYSTEM</CODE>)</LI>
  <LI>The <I>Temporary TS</I> should always point to a non-permanent (i.e.
      a temporary) tablespace (which is usually named <CODE>TEMP</CODE> on most
      systems)</LI>
 </UL>
 <P>Up to Oracle version 8, users are created with default and temporary
  tablespaces set to SYSTEM (if not explicitely specified otherwise), causing
  fragmentation of the system tablespace resulting in a performance decrease
  as well - so when creating a new user you should make sure to explicitely
  set at least the temporary tablespace to a non-permanent tablespace. Starting
  with Oracle 9i, the DBA can (and should!) create a default temporary TS using
  the command <CODE>CREATE DEFAULT TEMPORARY TABLESPACE</CODE>. Oracle then will
  implicitly assume this setting for all <CODE>CREATE USER</CODE> statements
  having no explicit temporary TS.</P>
</TD></TR></TABLE>

<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">//<!--
  if ( opener != null && opener.version != '' && opener.version != null )
    version = 'v'+opener.version;
  else version = '';
  document.write('<DIV ALIGN="center" STYLE="margin-top:3px"><IMG SRC="..\/w3c.jpg" ALT="w3c" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-right:3px"><SPAN CLASS="small" ALIGN="middle">OraRep '+version+' &copy; {copy} by <A STYLE="text-decoration:none" HREF="http://www.qumran.org/homes/izzy/" TARGET="_blank">Itzchak Rehberg<\/A> &amp; <A STYLE="text-decoration:none" HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft<\/A><\/SPAN><IMG SRC="..\/islogo.gif" ALT="IzzySoft" WIDTH="14" HEIGHT="14" ALIGN="middle" STYLE="margin-left:3px"><\/DIV>');
//--></SCRIPT>

</BODY></HTML>
