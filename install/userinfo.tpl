<HTML><HEAD>
 <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15"/>
 <LINK REL='stylesheet' TYPE='text/css' HREF='../{css}'/>
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
  <LI>The <I>Default TS</I> should never be SYSTEM (except for SYS and SYSTEM)</LI>
  <LI>The <I>Temporary TS</I> should always point to a non-permanent (i.e.
      a temporary) tablespace (which is usually named TEMP on most systems)</LI>
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

</BODY></HTML>
