#!/bin/bash
# $Id$
#
# =============================================================================
# Simple Database Analysis Report      (c) 2003 by IzzySoft (devel@izzysoft.de)     
# -----------------------------------------------------------------------------
# This report script creates a HTML document containing an overview on the
# database, whichs SID you either provide at the command line or configure it
# in the block below. But more than this, it not only reads the usual
# performance indicators out of the usual views, but connects values and gives
# you hints about how to use these results.
# I'ld never claim this report tool to be perfect, complete or "state of the
# art". But it's simple to use and very helpful to those not having a license
# to the expensive AddOns available at Oracle. Any hints on errors or bugs as
# well as recommendations for additions are always welcome.
#                                                              Itzchak Rehberg
#
#
version='0.1.3'
if [ -z "$1" ]; then
  SCRIPT=${0##*/}
  echo
  echo ============================================================================
  echo "OraRap v$version                (c) 2003 by Itzchak Rehberg (devel@izzysoft.de)"
  echo ----------------------------------------------------------------------------
  echo This script is intended to generate a HTML report for a given instance. Look
  echo inside the script header for closer details, and check for the configuration
  echo there as well.
  echo ----------------------------------------------------------------------------
  echo "Syntax: ${SCRIPT} <ORACLE_SID> [StartDir]"
  echo ============================================================================
  echo
  exit 1
fi

# =================================================[ Configuration Section ]===
# SID of the database to analyse
export ORACLE_SID=$1
# in which directory should the report ($ORACLE_SID.html) be placed
REPDIR=/var/www/html/reports
# StyleSheet to use
CSS=main.css
# login information
user=sys
password="pyha#"

# If called from another script, we may have to change to another directory
# before generating the reports
if [ -n "$2" ]; then
  cd $2
fi

# ====================================================[ Script starts here ]===
#$ORACLE_HOME/bin/sqlplus -s $user/$password <<EOF
$ORACLE_HOME/bin/sqlplus -s /NOLOG <<EOF

CONNECT $user/$password@$1
Set TERMOUT OFF
Set SCAN OFF
Set SERVEROUTPUT On Size 1000000
Set LINESIZE 300
Set TRIMSPOOL On 
Set FEEDBACK OFF
Set Echo Off
SPOOL $REPDIR/${ORACLE_SID}.html

DECLARE
  L_LINE VARCHAR(4000);
  R_TITLE VARCHAR(200);
  TABLE_OPEN VARCHAR(100); -- Table Attributes
  TABLE_CLOSE VARCHAR(100);
  S1 VARCHAR(200);
  S2 VARCHAR(200);
  S3 VARCHAR(200);
  S4 VARCHAR(200);
  S5 VARCHAR(200);
  I1 NUMBER;
  I2 NUMBER;
  I3 NUMBER;

  CURSOR C_USER IS
    SELECT username,account_status,NVL(to_char(lock_date,'DD.MM.YYYY'),'-')
           locked,NVL(to_char(expiry_date,'DD.MM.YYYY'),'-') expires,
           default_tablespace dts,temporary_tablespace tts,
           to_char(created,'DD.MM.YYYY') created
      FROM dba_users;
  CURSOR C_ADM IS
    SELECT grantee,admin_option FROM dba_role_privs WHERE granted_role='DBA';
  CURSOR C_FILE IS
    SELECT distinct t.name tablespace,d.name datafile,status,enabled,
           to_char(d.bytes/1024,'99,999,999.00') kbytes,
           to_char(free.bytes/1024,'99,999,999.00') freekbytes,
           to_char(100*(1-(free.bytes/d.bytes)),'990.00') usedpct,phyrds,phywrts,avgiotim
      FROM v\$filestat,v\$datafile d,v\$tablespace t,dba_free_space f,
           (SELECT file_id,SUM(bytes) bytes FROM dba_free_space GROUP BY file_id) free
     WHERE v\$filestat.file#=d.file# AND d.ts#=t.ts# AND f.file_id=d.file# AND free.file_id=d.file#;
  CURSOR C_RBS IS
    SELECT d.segment_name,d.status,to_char(r.rssize/1024,'99,999,999.00') rssize,
           to_char(nvl(r.optsize/1024,'0'),'99,999,999.00') optsize,
           to_char(r.hwmsize/1024,'99,999,999.00') hwmsize,r.xacts,
           r.waits,r.shrinks,r.wraps,r.aveshrink,r.aveactive
      FROM dba_rollback_segs d,v\$rollstat r
     WHERE d.segment_id=r.usn
     ORDER BY d.segment_name;
  CURSOR C_LIB IS
    SELECT namespace,gets,pins,reloads,
           to_char(gethitratio*100,'990.00') ratio FROM v\$librarycache;
  CURSOR C_ROW IS
    SELECT parameter,gets,getmisses,to_char((getmisses/gets)*100,'990.00') ratio
      FROM v\$rowcache WHERE gets>0;
  CURSOR C_MEM IS
    SELECT name,to_char(nvl(value,0)/1024,'999,999,990.00') value FROM v\$sga;
  CURSOR C_MEMPOOL IS
    SELECT name,DECODE(
            SIGN( LENGTH(value) - LENGTH(TRANSLATE(value,'0123456789GMKgmk','0123456789')) ),
            0,to_char(nvl(value,0)/1024,'999,999,990.00')||' kB',1,value,'0 kB') value
      FROM v\$parameter WHERE name LIKE '%pool%';
  CURSOR C_POOL IS
    SELECT pool,to_char(bytes/1024,'99,999,999.00') kbytes
      FROM v\$sgastat WHERE name='free memory';
  CURSOR C_BUF IS
    SELECT name,physical_reads,consistent_gets,db_block_gets,
           to_char(physical_reads/(consistent_gets+db_block_gets),'990.00') ratio
      FROM v\$buffer_pool_statistics
     WHERE consistent_gets+db_block_gets>0;
  CURSOR C_SCAN IS
    SELECT name,value FROM v\$sysstat WHERE name like '%table scans%';
  CURSOR C_EXT IS
    SELECT owner,table_name,
           to_char(100*empty_blocks/(blocks+empty_blocks),'990.00') freepct
      FROM dba_tables
     WHERE 0.1>DECODE(SIGN(blocks+empty_blocks),1,empty_blocks/(blocks+empty_blocks),1);
  CURSOR C_WAIT IS
    SELECT owner,segment_name,segment_type
      FROM (SELECT p1 file#,p2 block#
              FROM v\$session_wait
	     WHERE event IN ('buffer busy waits','db file sequential read',
	                     'db file scattered read','free buffer waits')) b,
	   dba_extents a
     WHERE a.file_id=b.file#
       AND b.block# BETWEEN a.block_id AND (a.block_id+blocks-1);
  CURSOR C_INVOBJ IS
    SELECT owner,object_name,object_type,to_char(created,'dd.mm.yyyy hh:mi') created,
           to_char(last_ddl_time,'dd.mm.yyyy hh:mi') last_ddl_time
      FROM dba_objects
     WHERE status='INVALID'
     ORDER BY owner;

BEGIN
  -- Configuration
  dbms_output.enable(1000000);
  R_TITLE := 'Report for $ORACLE_SID';
  TABLE_OPEN := '<TABLE ALIGN="center" BORDER="1">';
  TABLE_CLOSE := '</TABLE>'||CHR(10)||'<BR CLEAR="all">'||CHR(10);

  L_LINE := '<HTML><HEAD>'||CHR(10)||
            ' <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15"/>'||
            CHR(10)||' <TITLE>'||R_TITLE||'</TITLE>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <LINK REL="stylesheet" TYPE="text/css" HREF="$CSS">'||CHR(10)||
            '</HEAD><BODY>'||CHR(10)||'<H2>'||R_TITLE||'</H2>'||CHR(10);
  dbms_output.put_line(L_LINE);

  -- Navigation
  L_LINE := TABLE_OPEN||'<TR><TD><FONT SIZE=-2>[ <A HREF="#users">Users</A> ] '||
            '[ <A HREF="#datafiles">Datafiles</A> ] [ <A HREF="#rbs">Rollback</A> '||
            '] [ <A HREF="#memory">Memory</A> ]';
  dbms_output.put_line(L_LINE);
  L_LINE :=   ' [ <A HREF="#poolsize">Pool Sizes</A> ] [ <A HREF="#sharedpool">Shared Pool</A>'||
            ' ] [ <A HREF="#bufferpool">Buffer Pool</A> ] [ <A HREF="#sysstat">SysStat</A> ]';
  dbms_output.put_line(L_LINE);
  L_LINE := ' [ <A HREF="#events">Events</A> ] [ <A HREF="#invobj">Invalid Objects</A> ]'||
	    ' [ <A HREF="#misc">Misc</A> ]</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);

  -- Initial information about this instance
  SELECT host_name,version,archiver,instance_name INTO S1,S2,S3,S4
    FROM v\$instance;
  SELECT to_char(SYSDATE,'DD.MM.YYYY HH24:MI') INTO S5 FROM DUAL;
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="2">Common Instance Information</TH></TR>'||CHR(10)||
            ' <TR><TD class="td_name">Hostname:</TD><TD>'||S1||'</TD></TR>'||CHR(10)||
            ' <TR><TD class="td_name">Instance:</TD><TD>'||S4||'</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TD class="td_name">Version:</TD><TD>'||S2||'</TD></TR>'||CHR(10)||
            ' <TR><TD class="td_name">Archiver:</TD><TD>'||S3||'</TD></TR>';
  dbms_output.put_line(L_LINE);
  SELECT SUM(blocks*block_size)/(1024*1024) INTO I1 FROM v_\$archived_log;
  S1 := to_char(I1,'999,999,999.99');
  L_LINE := ' <TR><TD class="td_name">ArchivedLogSize:</TD><TD>'||S1||' MB</TD></TR>';
  dbms_output.put_line(L_LINE);
  SELECT SUM(members*bytes) INTO I1 FROM v\$log;
  SELECT SUM(bytes) INTO I2 from v\$datafile;
  I3 := (I1+I2)/1048576;
  S1 := to_char(I3,'999,999,999.99');
  SELECT to_char(startup_time,'DD.MM.YYYY HH24:MI'),to_char(sysdate - startup_time,'9990.00')
    INTO S2,S3 FROM v\$instance;
  L_LINE := ' <TR><TD class="td_name">FileSize (Data+Log)</TD><TD>'||S1||' MB</TD></TR>'||CHR(10)||
            ' <TR><TD class="td_name">Startup / Uptime</TD><TD>'||S2||' / '||S3||' d</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TD class="td_name">Report generated:</TD><TD>'||S5||'</TD></TR>'||CHR(10)||
            TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- User Information
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="7"><A NAME="users">User Information</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Username</TH><TH CLASS="th_sub">Account'||
            ' Status</TH><TH CLASS="th_sub">Lock Date</TH><TH CLASS="th_sub">';
  dbms_output.put_line(L_LINE);
  L_LINE := 'Expiry Date</TH><TH CLASS="th_sub">Default TS</TH><TH CLASS="th_sub">'||
            'Temporary TS</TH><TH CLASS="th_sub">Created</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR Rec_USER IN C_USER LOOP
    L_LINE := ' <TR><TD>'||Rec_USER.username||'</TD><TD>'||Rec_USER.account_status||
              '</TD><TD>'||Rec_USER.locked||'</TD><TD>'||Rec_USER.expires||
              '</TD><TD>'||Rec_USER.dts||'</TD><TD>'||Rec_USER.tts||'</TD><TD>'||
              Rec_USER.created||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);

  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="2">Admins</TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">User</TH><TH CLASS="th_sub">Admin '||
            'Option</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR Rec_ADM IN C_ADM LOOP
    L_LINE := ' <TR><TD>'||Rec_ADM.grantee||'</TD><TD ALIGN="center">'||
              Rec_ADM.admin_option||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- Data Files
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="10"><A NAME="datafiles">Data Files</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Tablespace</TH><TH CLASS="th_sub">'||
            'Datafile</TH><TH CLASS="th_sub">Status</TH><TH CLASS="th_sub">';
  dbms_output.put_line(L_LINE);
  L_LINE := 'Enabled</TH><TH CLASS="th_sub">Size (kB)</TH><TH CLASS="th_sub">'||
            'Free (kB)</TH><TH CLASS="th_sub">Used (%)</TH><TH CLASS="th_sub">'||
            'Phys.Reads</TH><TH CLASS="th_sub">Phys.Writes</TH>';
  dbms_output.put_line(L_LINE);
  L_LINE := '<TH CLASS="th_sub">Avg.I/O Time</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR Rec_FILE IN C_FILE LOOP
    L_LINE := ' <TR><TD>'||Rec_FILE.tablespace||'</TD><TD>'||Rec_FILE.datafile||
              '</TD><TD>'||Rec_FILE.status||'</TD><TD>'||Rec_FILE.enabled||
              '</TD><TD ALIGN="right">'||Rec_FILE.kbytes||'</TD><TD ALIGN="right">'||
              Rec_FILE.freekbytes;
    dbms_output.put_line(L_LINE);
    L_LINE := '</TD><TD ALIGN="right">'||Rec_FILE.usedpct||'</TD><TD ALIGN="right">'||
              Rec_FILE.phyrds||'</TD><TD ALIGN="right">'||Rec_FILE.phywrts||
              '</TD><TD ALIGN="right">'||Rec_FILE.avgiotim||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- Rollback Segments
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="11"><A NAME="rbs">Rollback Segments</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Segment</TH><TH CLASS="th_sub">Status</TH>'||
            '<TH CLASS="th_sub">Size (kB)</TH><TH CLASS="th_sub">OptSize (kB)</TH>';
  dbms_output.put_line(L_LINE);
  L_LINE := '<TH CLASS="th_sub">HWMSize (kB)</TH><TH CLASS="th_sub">Waits</TH>'||
            '<TH CLASS="th_sub">XActs</TH><TH CLASS="th_sub">Shrinks</TH>'||
            '<TH CLASS="th_sub">Wraps</TH><TH CLASS="th_sub">AveShrink</TH>';
  dbms_output.put_line(L_LINE);
  L_LINE := '<TH CLASS="th_sub">AveActive</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR Rec_RBS IN C_RBS LOOP
    L_LINE := ' <TR><TD>'||Rec_RBS.segment_name||'</TD><TD>'||Rec_RBS.status||
              '</TD><TD ALIGN="right">'||Rec_RBS.rssize||'</TD><TD ALIGN="right">'||
              Rec_RBS.optsize||'</TD><TD ALIGN="right">'||Rec_RBS.hwmsize||
              '</TD><TD ALIGN="right">'||Rec_RBS.waits;
    dbms_output.put_line(L_LINE);
    L_LINE := '</TD><TD ALIGN="right">'||Rec_RBS.xacts||'</TD><TD ALIGN="right">'||
              Rec_RBS.shrinks||'</TD><TD ALIGN="right">'||Rec_RBS.wraps||
              '</TD><TD ALIGN="right">'||Rec_RBS.aveshrink||'</TD><TD ALIGN="right">'||
              Rec_RBS.aveactive||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- Memory
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="2"><A NAME="memory">Memory Values</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Name</TH><TH CLASS="th_sub">Size</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR Rec_MEM IN C_MEM LOOP
    L_LINE := ' <TR><TD>'||Rec_MEM.name||'</TD><TD ALIGN="right">'||Rec_MEM.value||' kB</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  FOR Rec_MEMPOOL IN C_MEMPOOL LOOP
    L_LINE := ' <TR><TD>'||Rec_MEMPOOL.name||'</TD><TD ALIGN="right">'||
              Rec_MEMPOOL.value||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- Pool Sizes
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="2"><A NAME="poolsize">Pool Sizes</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Pool</TH><TH CLASS="th_sub">Space</TH></TR>';
  dbms_output.put_line(L_LINE);
  SELECT DECODE(SIGN( LENGTH(value) - LENGTH(TRANSLATE(value,'0123456789GMKgmk','0123456789')) ),
         0,to_char(value/1024,'999,999,990.00')||' kB','&nbsp;')
         INTO S1 FROM v\$parameter WHERE name='shared_pool_size';
  L_LINE := ' <TR><TD>Shared_Pool_Size</TD><TD ALIGN="right">'||S1||'</TD></TR>'||CHR(10);
  SELECT DECODE(SIGN( LENGTH(value) - LENGTH(TRANSLATE(value,'0123456789GMKgmk','0123456789')) ),
         0,to_char(value/1024,'999,999,990.00')||' kB','&nbsp;')
         INTO S1 FROM v\$parameter WHERE name='shared_pool_reserved_size';
  L_LINE := L_LINE||' <TR><TD>Shared_Pool_Reserved_Size</TD><TD ALIGN="right">'||S1||'</TD></TR>'||CHR(10);
  SELECT DECODE(SIGN( LENGTH(value) - LENGTH(TRANSLATE(value,'0123456789GMKgmk','0123456789')) ),
         0,to_char(value/1024,'999,999,990.00')||' kB','&nbsp;')
         INTO S1 FROM v\$parameter WHERE name='large_pool_size';
  L_LINE := L_LINE||' <TR><TD>Large_Pool_Size</TD><TD ALIGN="right">'||S1||'</TD></TR>'||CHR(10);
  dbms_output.put_line(L_LINE);
  SELECT DECODE(SIGN( LENGTH(value) - LENGTH(TRANSLATE(value,'0123456789GMKgmk','0123456789')) ),
         0,to_char(value/1024,'999,999,990.00')||' kB','&nbsp;')
         INTO S1 FROM v\$parameter WHERE name='java_pool_size';
  L_LINE := ' <TR><TD>Java_Pool_Size</TD><TD ALIGN="right">'||S1||'</TD></TR>'||CHR(10);
  SELECT DECODE(SIGN( LENGTH(value) - LENGTH(TRANSLATE(value,'0123456789GMKgmk','0123456789')) ),
         0,to_char(value/1024,'999,999,990.00')||' kB','&nbsp;')
         INTO S1 FROM v\$parameter WHERE name='sort_area_size';
  L_LINE := L_LINE||' <TR><TD>Sort_Area_Size</TD><TD ALIGN="right">'||S1||'</TD></TR>'||CHR(10);
  SELECT DECODE(SIGN( LENGTH(value) - LENGTH(TRANSLATE(value,'0123456789GMKgmk','0123456789')) ),
         0,to_char(value/1024,'999,999,990.00')||' kB','&nbsp;')
         INTO S1 FROM v\$parameter WHERE name='sort_area_retained_size';
  L_LINE := L_LINE||' <TR><TD>Sort_Area_Retained_Size</TD><TD ALIGN="right">'||S1||'</TD></TR>'||CHR(10);
  dbms_output.put_line(L_LINE);

  L_LINE := ' <TR><TH CLASS="th_sub">Pool</TH><TH CLASS="th_sub">Free Space</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR Rec_POOL IN C_POOL LOOP
    L_LINE := ' <TR><TD>'||Rec_POOL.pool||'</TD><TD ALIGN="right">'||
              Rec_POOL.kbytes||' kB</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);

  -- Shared Pool Information
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5"><A NAME="sharedpool">Shared Pool Information</A></TH></TR>'||CHR(10)||
            ' <TR><TH COLSPAN="5" CLASS="th_sub">Library Cache</TH></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TD COLSPAN="5">If one of the following conditions is <B><I>NOT</B></I> '||
            'met this indicates that SHARED_POOL_SIZE may have to be increased:';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <BR><LI>(reloads/pins)*100 < 1</LI><BR><LI>gethitratio > 0.9</LI></TD><TR>'||
            ' <TR><TD CLASS="td_name">NameSpace</TD><TD CLASS="td_name">Gets</TD>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TD CLASS="td_name">Pins</TD><TD CLASS="td_name">Reloads</TD>'||
            '<TD CLASS="td_name">GetHitRatio</TD></TR>';
  dbms_output.put_line(L_LINE);
  FOR Rec_LIB IN C_LIB LOOP
    L_LINE := ' <TR><TD>'||Rec_LIB.namespace||'</TD><TD ALIGN="right">'||
              Rec_LIB.gets||'</TD>'||'<TD ALIGN="right">'||Rec_LIB.pins||
              '</TD><TD ALIGN="right">'||Rec_LIB.reloads||
              '</TD><TD ALIGN="right">'||Rec_LIB.ratio||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;

  L_LINE := ' <TR><TD COLSPAN="5">'||CHR(38)||'nbsp;</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TH COLSPAN="5" CLASS="th_sub">Row Cache</TH></TR>'||
            ' <TR><TD COLSPAN="5">If Ratio = (getmisses/gets)*100 > 15,'||
            ' SHARED_POOL_SIZE may have to be increased:</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TD COLSPAN="2" CLASS="td_name">Parameter</TD><TD CLASS="td_name">Gets</TD>'||
            '<TD CLASS="td_name">GetMisses</TD><TD CLASS="td_name">Ratio</TD></TR>';
  dbms_output.put_line(L_LINE);
  FOR Rec_ROW IN C_ROW LOOP
    L_LINE := ' <TR><TD COLSPAN="2">'||Rec_ROW.parameter||'</TD><TD ALIGN="right">'||
              Rec_ROW.gets||'</TD><TD ALIGN="right">'||Rec_ROW.getmisses||
              '</TD><TD ALIGN="right">'||Rec_ROW.ratio||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);

  -- Buffer Pool Statistics
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5"><A NAME="bufferpool">Buffer Pool Statistics</A></TH></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TD COLSPAN="5">Ratio = physical_reads/(consistent_gets+db_block_gets)'||
            ' should be > 0.9:';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Pool</TH><TH CLASS="th_sub">'||
            'physical_reads</TH><TH CLASS="th_sub">consistent_gets</TH>'||
            '<TH CLASS="th_sub">db_block_gets</TH><TH CLASS="th_sub">Ratio</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR Rec_BUF IN C_BUF LOOP
    L_LINE := ' <TR><TD>'||Rec_BUF.name||'</TD><TD ALIGN="right">'||
              Rec_BUF.physical_reads||'</TD><TD ALIGN="right">'||
              Rec_BUF.consistent_gets||'</TD><TD ALIGN="right">'||
              Rec_BUF.db_block_gets||'</TD><TD ALIGN="right">'||
              Rec_BUF.ratio||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- V$SYSSTAT: extracted informations
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="3"><A NAME="sysstat">SYSSTAT Info</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Name</TH><TH CLASS="th_sub">Value</TH>'||
            '<TH CLASS="th_sub">Description</TH></TR>';
  dbms_output.put_line(L_LINE);
  SELECT value INTO I1 FROM v\$sysstat WHERE name='sorts (disk)';
  SELECT value INTO I2 FROM v\$sysstat WHERE name='sorts (memory)';
  I3 := I1/I2;
  S1 := to_char(I3,'999,999,990.99');
  L_LINE := ' <TR><TD WIDTH="300">DiskSorts / MemorySorts</TD><TD ALIGN="right">'||S1||'</TD><TD>'||
            'Higher values are an indicator to increase <I>SORT_AREA_SIZE</I></TD></TR>';
  dbms_output.put_line(L_LINE);
  SELECT value INTO I1 FROM v\$sysstat WHERE name='summed dirty queue length';
  I2 := 1;
  BEGIN
    SELECT value INTO I2 FROM v\$sysstat WHERE name='write requests';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
  END;
  I3 := I1/I2;
  S1 := to_char(I3,'999,999,990.99');
  L_LINE := ' <TR><TD>summed dirty queue length / write requests</TD><TD ALIGN="right">'||S1||
            '</TD><TD>If this value is > 100, the LGWR is too lazy -- so you may'||
            'want to decrease <I>DB_BLOCK_MAX_DIRTY_TARGET</I></TD></TR>';
  dbms_output.put_line(L_LINE);
  SELECT value INTO I1 FROM v\$sysstat WHERE name='free buffer inspected';
  SELECT value INTO I2 FROM v\$sysstat WHERE name='free buffer requested';
  I3 := I1/I2;
  S1 := to_char(I3,'999,999,990.99');
  L_LINE := ' <TR><TD>free buffer inspected / free buffer requested</TD><TD ALIGN="right">'||
            S1||'</TD><TD>Increase your buffer cache if this value is too high</TD></TR>';
  dbms_output.put_line(L_LINE);
  SELECT value INTO I1 FROM v\$sysstat WHERE name='redo buffer allocation retries';
  SELECT value INTO I2 FROM v\$sysstat WHERE name='redo blocks written';
  I3 := I1/I2;
  S1 := to_char(I3,'999,999,990.99');
  L_LINE := ' <TR><TD>redo buffer allocation retries / redo blocks written</TD>'||
            '<TD ALIGN="right">'||S1||'</TD><TD>should be less than 0.01</TD></TR>';
  dbms_output.put_line(L_LINE);
  SELECT value INTO I1 FROM v\$sysstat WHERE name='redo log space requests';
  S1 := to_char(I1,'999,999,990.99');
  L_LINE := ' <TR><TD>redo log space requests</TD><TD ALIGN="right">'||S1||
            '</TD><TD>how often the log file was full and Oracle had to wait '||
            'for a new file to become available</TD></TR>';
  dbms_output.put_line(L_LINE);
  SELECT value INTO I1 FROM v\$sysstat WHERE name='table fetch continued row';
  S1 := to_char(I1,'999,999,990.99');
  L_LINE := ' <TR><TD>table fetch continued row</TD><TD ALIGN="right">'||S1||
            '</TD><TD>How many migrated rows did we encounter during this '||
            'instances life time? If the number is markable, you may have to '||
            'analyse your tables:';
  dbms_output.put_line(L_LINE);
  L_LINE := '<PRE>ANALYZE TABLE tablename COMPUTE STATISTICS;'||CHR(10)||
            'SELECT num_rows,chain_cnt FROM dba_tables WHERE table_name='||
            CHR(39)||'tablename'||CHR(39)||';</PRE>'||
            '<I>utlchain.sql</I> then may help you to automatically eliminate '||
            'migration (correct PCTFREE before running that!).</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- Selected Events
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="6"><A NAME="events">Selected Wait Events (from v'||CHR(36)||'system_event)</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Name</TH><TH CLASS="th_sub">Totals</TH>';
  dbms_output.put_line(L_LINE);
  L_LINE := '<TH CLASS="th_sub">Total WaitTime</TH><TH CLASS="th_sub">Avg Waited</TH>'||
            '<TH CLASS="th_sub">Timeouts</TH>'||'<TH CLASS="th_sub">Description</TH></TR>';
  dbms_output.put_line(L_LINE);
  SELECT TO_CHAR(total_waits,'9,999,999,990'),TO_CHAR(time_waited,'9,999,999,990'),average_wait,TO_CHAR(total_timeouts,'99,999,990') INTO S1,S2,I1,S3 FROM v\$system_event WHERE event='db file sequential read';
--  L_LINE := ' <TR><TD>db file sequential read</TD><TD ALIGN="right">'||S1||
  L_LINE := ' <TR><TD><DIV STYLE="width:22ex">db file sequential read</DIV></TD><TD ALIGN="right">'||S1||
            '</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||I1||'</TD>'||
	    '<TD ALIGN="right">'||S3;
  dbms_output.put_line(L_LINE);
  L_LINE := '</TD><TD>Indicator for I/O problems on index accesses<BR><FONT SIZE="-2">'||
	    '(Consider increasing the buffer cache when value is high)</FONT></TD></TR>';
  dbms_output.put_line(L_LINE);
  SELECT TO_CHAR(total_waits,'9,999,999,990'),TO_CHAR(time_waited,'9,999,999,990'),average_wait,TO_CHAR(total_timeouts,'99,999,990') INTO S1,S2,I1,S3 FROM v\$system_event WHERE event='db file scattered read';
  L_LINE := ' <TR><TD>db file scattered read</TD><TD ALIGN="right">'||S1||
            '</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||I1||'</TD>'||
	    '<TD ALIGN="right">'||S3;
  dbms_output.put_line(L_LINE);
  L_LINE := '</TD><TD>Indicator for I/O problems on full table scans<BR><FONT SIZE="-2">'||
            '(On increasing <I>DB_FILE_MULTI_BLOCK_READ_COUNT</I> if this value '||
            'is high see the first block of Miscellaneous below)</FONT></TD></TR>';
  dbms_output.put_line(L_LINE);
  I1 := 0; S1 := '0'; S2 := '0'; S3 := '0';
  BEGIN
    SELECT TO_CHAR(total_waits,'9,999,999,990'),TO_CHAR(time_waited,'9,999,999,990'),average_wait,TO_CHAR(total_timeouts,'99,999,990') INTO S1,S2,I1,S3 FROM v\$system_event WHERE event='latch free';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
  END;
  L_LINE := ' <TR><TD>latch free</TD><TD ALIGN="right">'||S1||
            '</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||I1||'</TD>'||
	    '<TD ALIGN="right">'||S3;
  dbms_output.put_line(L_LINE);
  L_LINE := '</TD><TD>'||CHR(38)||'nbsp;</TD></TR>';
  dbms_output.put_line(L_LINE);
  I1 := 0; S1 := '0'; S2 := '0'; S3 := '0';
  BEGIN
    SELECT TO_CHAR(total_waits,'9,999,999,990'),TO_CHAR(time_waited,'9,999,999,990'),average_wait,TO_CHAR(total_timeouts,'99,999,990') INTO S1,S2,I1,S3 FROM v\$system_event WHERE event='LGWR wait for redo copy';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
  END;
  L_LINE := ' <TR><TD>LGWR wait for redo copy</TD><TD ALIGN="right">'||S1||
            '</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||I1||'</TD>'||
	    '<TD ALIGN="right">'||S3;
  dbms_output.put_line(L_LINE);
  L_LINE := '</TD><TD>'||CHR(38)||'nbsp;</TD></TR>';
  dbms_output.put_line(L_LINE);
  I1 := 0; S1 := '0'; S2 := '0'; S3 := '0';
  BEGIN
    SELECT TO_CHAR(total_waits,'9,999,999,990'),TO_CHAR(time_waited,'9,999,999,990'),average_wait,TO_CHAR(total_timeouts,'99,999,990') INTO S1,S2,I1,S3 FROM v\$system_event WHERE event='log file switch (checkpoint incomplete)';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
  END;
  L_LINE := ' <TR><TD>log file switch (checkpoint incomplete)</TD><TD ALIGN="right">'||S1||
            '</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||I1||'</TD>'||
	    '<TD ALIGN="right">'||S3;
  dbms_output.put_line(L_LINE);
  L_LINE := '</TD><TD>Higher values indicate that either your ReDo logs are too small or there are not enough log file groups</TD></TR>';
  dbms_output.put_line(L_LINE);
  I1 := 0; S1 := '0'; S2 := '0'; S3 := '0';
  BEGIN
    SELECT TO_CHAR(total_waits,'9,999,999,990'),TO_CHAR(time_waited,'9,999,999,990'),average_wait,TO_CHAR(total_timeouts,'99,999,990') INTO S1,S2,I1,S3 FROM v\$system_event WHERE event='log file switch completion';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
  END;
  L_LINE := ' <TR><TD>log file switch completion</TD><TD ALIGN="right">'||S1||
            '</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||I1||'</TD>'||
	    '<TD ALIGN="right">'||S3;
  dbms_output.put_line(L_LINE);
  L_LINE := '</TD><TD>You may consider increasing the number of logfile groups.</TD></TR>';
  dbms_output.put_line(L_LINE);
  I1 := 0; S1 := '0'; S2 := '0'; S3 := '0';
  BEGIN
    SELECT TO_CHAR(total_waits,'9,999,999,990'),TO_CHAR(time_waited,'9,999,999,990'),average_wait,TO_CHAR(total_timeouts,'99,999,990') INTO S1,S2,I1,S3 FROM v\$system_event WHERE event='log buffer wait';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
  END;
  L_LINE := ' <TR><TD>log buffer wait</TD><TD ALIGN="right">'||S1||
            '</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||I1||'</TD>'||
	    '<TD ALIGN="right">'||S3;
  dbms_output.put_line(L_LINE);
  L_LINE := '</TD><TD>If this value is too high, log buffers are filling faster '||
            'than being emptied. You then have to consider to increase the '||
            'number of logfile groups or to use larger log files.</TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);

  -- Who caused the wait events?
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="3"><A NAME="waitobj">Objects causing Wait Events</A></TH></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TD COLSPAN="3">On the following segments we noticed one of the '||
            'events <I>buffer busy waits</I>, <I>db file sequential read</I>, '||
	    '<I>db file scattered read</I> or <I>free buffer waits</I> at the '||
	    'time the report was generated.';
  dbms_output.put_line(L_LINE);
  L_LINE := 'If you had many <I>db file scattered reads</I> above and now find '||
            'some entries with segment type = table in here, these may need ';
  dbms_output.put_line(L_LINE);
  L_LINE := 'some|more|better|other indices. Use <I>Statspack</I> or <I>'||
	    'Oracle Enterprise Manager Diagnostics Pack</I> to find out more. '||
	    'Other things that may help to avoid some of the <I>db file * read</I> ';
  dbms_output.put_line(L_LINE);
  L_LINE := 'wait events are:<UL STYLE="margin-top:0;margin-bottom:0">'||
            '<LI>Tune the SQL statements used by your applications and users (most important!)</LI>'||
            '<LI>Re-Analyze the schema to help the optimizer with accurate data e.g. with <I>dbms_stats</I></LI>';
  dbms_output.put_line(L_LINE);
  L_LINE := '<LI>Stripe objects over multiple disk volumes</LI>'||
            '<LI>Pin frequently used objects</LI><LI>Increase the buffer caches</LI></UL></TD></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Owner</TH><TH CLASS="th_sub">'||
            'Segment Name</TH><TH CLASS="th_sub">Segment Type</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR Rec_WAIT IN C_WAIT LOOP
    L_LINE := ' <TR><TD>'||Rec_WAIT.owner||'</TD><TD ALIGN="right">'||
              Rec_WAIT.segment_name||'</TD><TD ALIGN="right">'||
              Rec_WAIT.segment_type||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- Invalid Objects
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5"><A NAME="invobj">Invalid Objects</A></TH></TR>'||CHR(10)||
            ' <TR><TD COLSPAN="5">The following objects may need your investigation. These are not';
  dbms_output.put_line(L_LINE);
  L_LINE := ' necessarily problem indicators (e.g. an invalid view may automatically re-compile), but could be:</TH></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Owner</TH><TH CLASS="th_sub">Object</TH><TH CLASS="th_sub">Typ</TH>'||
            '<TH CLASS="th_sub">Created</TH><TH CLASS="th_sub">Last DDL</TH></TR>';
  dbms_output.put_line(L_LINE);
  FOR Rec_INVOBJ IN C_INVOBJ LOOP
    L_LINE := ' <TR><TD>'||Rec_INVOBJ.owner||'</TD><TD>'||Rec_INVOBJ.object_name||
              '</TD><TD>'||Rec_INVOBJ.object_type||'</TD><TD>'||Rec_INVOBJ.created||
	      '</TD><TD>'||Rec_INVOBJ.last_ddl_time||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);
  dbms_output.put_line('<HR>');

  -- Miscellaneous
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="2"><A NAME="misc">Miscellaneous</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Name</TH><TH CLASS="th_sub">Value</TH></TR>';
  dbms_output.put_line(L_LINE);
  L_LINE := ' <TR><TD COLSPAN="2" CLASS="td_name">If we have many full table '||
            'scans, we may have to optimize <I>DB_FILE_MULTI_BLOCK_READ_COUNT</I>. '||
            'Beneath the statistic below, we need the block count of the largest '||
            'table to find the best value. ';
  dbms_output.put_line(L_LINE);
  L_LINE := 'A common recommendation is to set <I>DB_FILE_MULTI_BLOCK_READ_COUNT</I> '||
            'to the highest possible value for maximum performance, which is '||
	    '32 (256k) in most environments. The absolute maximum of 128 (1M) is '||
	    'mostly only available on raw devices.</TD></TR>';
  dbms_output.put_line(L_LINE);
  FOR Rec_SCAN IN C_SCAN LOOP
    L_LINE := ' <TR><TD>'||Rec_SCAN.name||'</TD><TD ALIGN="right">'||
              Rec_SCAN.value||'</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := ' <TR><TD COLSPAN="2" CLASS="td_name">If there are tables that '||
            'will for sure need more extents shortly, we can reduce I/O overhead '||
            'allocating some extents for them in advance, using ';
  dbms_output.put_line(L_LINE);
  L_LINE := '"ALTER TABLE tablename ALLOCATE EXTENT". Here are some '||
            'candidates, having less than 10 percent free blocks left:</TD></TR>';
  dbms_output.put_line(L_LINE);
  FOR Rec_EXT IN C_EXT LOOP
    L_LINE := ' <TR><TD>'||Rec_EXT.owner||'.'||Rec_EXT.table_name||
              '</TD><TD ALIGN="right">'||Rec_EXT.freepct||'%</TD></TR>';
    dbms_output.put_line(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  dbms_output.put_line(L_LINE);

  -- Page Ending
  L_LINE := '<HR>'||CHR(10)||TABLE_OPEN;
  dbms_output.put_line(L_LINE);
  L_LINE := '<TR><TD><FONT SIZE="-2">Created by OraRep v$version &copy; 2003 by '||
	    '<A HREF="http://www.qumran.org/homes/izzy/" TARGET="_blank">Itzchak Rehberg</A> '||
            '&amp; <A HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft</A></FONT></TD></TR>';
  dbms_output.put_line(L_LINE);
  dbms_output.put_line(TABLE_CLOSE);
  L_LINE := '</BODY></HTML>'||CHR(10);
  dbms_output.put_line(L_LINE);

END;
/

SPOOL off

EOF
