#!/bin/bash
# $Id$
#
# =============================================================================
# Simple Database Analysis Report (c) 2003 by IzzySoft (izzysoft@buntspecht.de)
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
version='0.1.6'
if [ -z "$1" ]; then
  SCRIPT=${0##*/}
  echo
  echo ============================================================================
  echo "OraRep v$version                (c) 2003 by Itzchak Rehberg (devel@izzysoft.de)"
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
CSS=../main.css
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
           to_char(100*(1-(free.bytes/d.bytes)),'990.00') usedpct,
	   to_char(phyrds,'9,999,999,990') phyrds,
           to_char(phywrts,'9,999,999,990') phywrts,
	   to_char(avgiotim,'9,999,999,990') avgiotim
      FROM v\$filestat,v\$datafile d,v\$tablespace t,dba_free_space f,
           (SELECT file_id,SUM(bytes) bytes FROM dba_free_space GROUP BY file_id) free
     WHERE v\$filestat.file#=d.file# AND d.ts#=t.ts# AND f.file_id=d.file# AND free.file_id=d.file#
     UNION
    SELECT distinct t.name tablespace,d.name datafile,status,enabled,
           to_char(d.bytes/1024,'99,999,999.00') kbytes,
           to_char(free.bytes/1024,'99,999,999.00') freekbytes,
           to_char(100*(1-(free.bytes/d.bytes)),'990.00') usedpct,
	   to_char(phyrds,'9,999,999,990') phyrds,
           to_char(phywrts,'9,999,999,990') phywrts,
	   to_char(avgiotim,'9,999,999,990') avgiotim
      FROM v\$filestat,v\$tempfile d,v\$tablespace t,dba_free_space f,
           (SELECT file_id,SUM(bytes) bytes FROM dba_free_space GROUP BY file_id) free
     WHERE v\$filestat.file#=d.file# AND d.ts#=t.ts# AND f.file_id=d.file# AND free.file_id=d.file#;
  CURSOR C_RBS IS
    SELECT d.segment_name,d.status,to_char(r.rssize/1024,'99,999,999.00') rssize,
           to_char(nvl(r.optsize/1024,'0'),'99,999,999.00') optsize,
           to_char(r.hwmsize/1024,'99,999,999.00') hwmsize,r.xacts,
           to_char(r.waits,'9,999,990') waits,
	   to_char(r.shrinks,'9,999,990') shrinks,
	   to_char(r.wraps,'9,999,990') wraps,
	   to_char(r.aveshrink,'9,999,999,990') aveshrink,
	   to_char(r.aveactive,'9,999,999,990') aveactive
      FROM dba_rollback_segs d,v\$rollstat r
     WHERE d.segment_id=r.usn
     ORDER BY d.segment_name;
  CURSOR C_LIB IS
    SELECT namespace,
           to_char(gets,'9,999,999,990') gets,
	   to_char(pins,'9,999,999,990') pins,
	   to_char(reloads,'9,999,999,990') reloads,
           to_char(gethitratio*100,'990.00') ratio,
	   to_char(DECODE(NVL(pins,0),0,0,100*reloads/pins),'990.00') rratio
      FROM v\$librarycache;
  CURSOR C_ROW IS
    SELECT parameter,
           to_char(gets,'9,999,999,990') gets,
	   to_char(getmisses,'9,999,999,990') getmisses,
	   to_char((getmisses/gets)*100,'990.00') ratio
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
    SELECT name,
           to_char(physical_reads,'9,999,999,990') physical_reads,
	   to_char(consistent_gets,'9,999,999,990') consistent_gets,
	   to_char(db_block_gets,'9,999,999,990') db_block_gets,
           to_char(physical_reads/(consistent_gets+db_block_gets),'990.00') ratio
      FROM v\$buffer_pool_statistics
     WHERE consistent_gets+db_block_gets>0;
  CURSOR C_SCAN IS
    SELECT name,TO_CHAR(value,'9,999,999,990') value
      FROM v\$sysstat
     WHERE name like '%table scans%';
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
  CURSOR C_DBLinks IS
    SELECT owner,db_link,username,host,to_char(created,'DD.MM.YYYY') created
      FROM dba_db_links
     ORDER BY owner,db_link;

  PROCEDURE get_wait(eventname IN VARCHAR2, S04 OUT VARCHAR, S01 OUT VARCHAR2,
                     S02 OUT VARCHAR2, S03 OUT VARCHAR2) IS
    BEGIN
       SELECT TO_CHAR(total_waits,'9,999,999,990') totals,
              TO_CHAR(time_waited,'9,999,999,990') timew,
	      TO_CHAR(DECODE(NVL(total_waits,0),0,0,1000*time_waited/total_waits),
	              '9,999,990.0') average,
	      TO_CHAR(total_timeouts,'9,999,999,990') timeouts
	 INTO S01,S02,S04,S03
         FROM v\$system_event WHERE event=eventname;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
       S04 := '0.0'; S01 := '0'; S02 := '0'; S03 := '0';
    END;

  PROCEDURE sysstat_per(aval IN VARCHAR2, bval IN VARCHAR2, rval OUT VARCHAR2) IS
    BEGIN
      SELECT value INTO I1 FROM v\$sysstat WHERE name=aval;
      SELECT value INTO I2 FROM v\$sysstat WHERE name=bval;
      IF NVL(I2,0) = 0
      THEN
        rval := '&nbsp;';
      ELSE
        rval := TO_CHAR(I1/I2,'999,999,990.99');
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN rval := '&nbsp;';
    END;

  PROCEDURE poolsize(aval IN VARCHAR2, rval OUT VARCHAR2) IS
    BEGIN
      SELECT DECODE(SIGN( LENGTH(value) - LENGTH(TRANSLATE(value,'0123456789GMKgmk','0123456789')) ),
             0,to_char(value/1024,'999,999,990.00')||' kB','&nbsp;')
        INTO rval
	FROM v\$parameter
       WHERE name=aval;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN rval := '&nbsp;';
    END;

  PROCEDURE check_dblink(db_link IN VARCHAR2, rval OUT VARCHAR2) IS
    BEGIN
      ROLLBACK;
      S1 := 'SELECT ''>ACTIVE'' FROM DUAL@'||db_link;
      EXECUTE IMMEDIATE S1 INTO rval;
    EXCEPTION
      WHEN OTHERS THEN rval := ' CLASS="alert">INACTIVE';
    END;

  PROCEDURE print(line IN VARCHAR2) IS
    BEGIN
      dbms_output.put_line(line);
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('*!* Problem in print() *!*');
    END;

BEGIN
  -- Configuration
  dbms_output.enable(1000000);
  R_TITLE := 'Report for $ORACLE_SID';
  TABLE_OPEN := '<TABLE ALIGN="center" BORDER="1">';
  TABLE_CLOSE := '</TABLE>'||CHR(10)||'<BR CLEAR="all">'||CHR(10);

  L_LINE := '<HTML><HEAD>'||CHR(10)||
            ' <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15"/>'||
            CHR(10)||' <TITLE>'||R_TITLE||'</TITLE>';
  print(L_LINE);
  L_LINE := ' <LINK REL="stylesheet" TYPE="text/css" HREF="$CSS">'||CHR(10)||
            '</HEAD><BODY>'||CHR(10)||'<H2>'||R_TITLE||'</H2>'||CHR(10);
  print(L_LINE);

  -- Navigation
  L_LINE := TABLE_OPEN||'<TR><TD><DIV CLASS="small">[ <A HREF="#users">Users</A> ] '||
            '[ <A HREF="#datafiles">Datafiles</A> ] [ <A HREF="#rbs">Rollback</A> '||
            '] [ <A HREF="#memory">Memory</A> ]';
  print(L_LINE);
  L_LINE :=   ' [ <A HREF="#poolsize">Pool Sizes</A> ] [ <A HREF="#sharedpool">Shared Pool</A>'||
            ' ] [ <A HREF="#bufferpool">Buffer Pool</A> ] [ <A HREF="#sysstat">SysStat</A> ]';
  print(L_LINE);
  L_LINE := ' [ <A HREF="#events">Events</A> ] [ <A HREF="#invobj">Invalid Objects</A> ]'||
	    ' [ <A HREF="#misc">Misc</A> ]</DIV></TD></TR>';
  print(L_LINE);
  L_LINE := TABLE_CLOSE;
  print(L_LINE);

  -- Initial information about this instance
  SELECT host_name,version,archiver,instance_name INTO S1,S2,S3,S4
    FROM v\$instance;
  SELECT to_char(SYSDATE,'DD.MM.YYYY HH24:MI') INTO S5 FROM DUAL;
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="2">Common Instance Information</TH></TR>'||CHR(10)||
            ' <TR><TD class="td_name">Hostname:</TD><TD>'||S1||'</TD></TR>'||CHR(10)||
            ' <TR><TD class="td_name">Instance:</TD><TD>'||S4||'</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD class="td_name">Version:</TD><TD>'||S2||'</TD></TR>'||CHR(10)||
            ' <TR><TD class="td_name">Archiver:</TD><TD>'||S3||'</TD></TR>';
  print(L_LINE);
  SELECT SUM(blocks*block_size)/(1024*1024) INTO I1 FROM v\$archived_log;
  S1 := to_char(I1,'999,999,999.99');
  L_LINE := ' <TR><TD class="td_name">ArchivedLogSize:</TD><TD>'||S1||' MB</TD></TR>';
  print(L_LINE);
  SELECT SUM(members*bytes) INTO I1 FROM v\$log;
  SELECT SUM(bytes) INTO I2 from v\$datafile;
  I3 := (I1+I2)/1048576;
  S1 := to_char(I3,'999,999,999.99');
  SELECT to_char(startup_time,'DD.MM.YYYY HH24:MI'),to_char(sysdate - startup_time,'9990.00')
    INTO S2,S3 FROM v\$instance;
  L_LINE := ' <TR><TD class="td_name">FileSize (Data+Log)</TD><TD>'||S1||' MB</TD></TR>'||CHR(10)||
            ' <TR><TD class="td_name">Startup / Uptime</TD><TD>'||S2||' / '||S3||' d</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD class="td_name">Report generated:</TD><TD>'||S5||'</TD></TR>'||CHR(10)||
            TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- User Information
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="7"><A NAME="users">User Information</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Username</TH><TH CLASS="th_sub">Account'||
            ' Status</TH><TH CLASS="th_sub">Lock Date</TH><TH CLASS="th_sub">';
  print(L_LINE);
  L_LINE := 'Expiry Date</TH><TH CLASS="th_sub">Default TS</TH><TH CLASS="th_sub">'||
            'Temporary TS</TH><TH CLASS="th_sub">Created</TH></TR>';
  print(L_LINE);
  FOR Rec_USER IN C_USER LOOP
    L_LINE := ' <TR><TD>'||Rec_USER.username||'</TD><TD>'||Rec_USER.account_status||
              '</TD><TD>'||Rec_USER.locked||'</TD><TD>'||Rec_USER.expires||
              '</TD><TD>'||Rec_USER.dts||'</TD><TD>'||Rec_USER.tts||'</TD><TD>'||
              Rec_USER.created||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);

  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="2">Admins</TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">User</TH><TH CLASS="th_sub">Admin '||
            'Option</TH></TR>';
  print(L_LINE);
  FOR Rec_ADM IN C_ADM LOOP
    L_LINE := ' <TR><TD>'||Rec_ADM.grantee||'</TD><TD ALIGN="center">'||
              Rec_ADM.admin_option||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);

  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="6">DB Links</TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Owner</TH><TH CLASS="th_sub">DB Link</TH>';
  print(L_LINE);
  L_LINE := '<TH CLASS="th_sub">Username</TH><TH CLASS="th_sub">Host</TH>'||
            '<TH CLASS="th_sub">Created</TH><TH CLASS="th_sub">Status</TH></TR>';
  print(L_LINE);
  FOR R_Link IN C_DBLinks LOOP
    check_dblink(R_Link.db_link,S1);
    L_LINE := ' <TR><TD>'||R_Link.owner||'</TD><TD>'||R_Link.db_link||
              '</TD><TD>'||R_Link.username||'</TD><TD>'||R_Link.host||
	      '</TD><TD>';
    print(L_LINE);
    L_LINE := R_Link.created||'</TD><TD ALIGN="center"'||S1||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- Data Files
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="10"><A NAME="datafiles">Data Files</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Tablespace</TH><TH CLASS="th_sub">'||
            'Datafile</TH><TH CLASS="th_sub">Status</TH><TH CLASS="th_sub">';
  print(L_LINE);
  L_LINE := 'Enabled</TH><TH CLASS="th_sub">Size (kB)</TH><TH CLASS="th_sub">'||
            'Free (kB)</TH><TH CLASS="th_sub">Used (%)</TH><TH CLASS="th_sub">'||
            'Phys.Reads</TH><TH CLASS="th_sub">Phys.Writes</TH>';
  print(L_LINE);
  L_LINE := '<TH CLASS="th_sub">Avg.I/O Time</TH></TR>';
  print(L_LINE);
  FOR Rec_FILE IN C_FILE LOOP
    L_LINE := ' <TR><TD>'||Rec_FILE.tablespace||'</TD><TD>'||Rec_FILE.datafile||
              '</TD><TD>'||Rec_FILE.status||'</TD><TD>'||Rec_FILE.enabled||
              '</TD><TD ALIGN="right">'||Rec_FILE.kbytes||'</TD><TD ALIGN="right">'||
              Rec_FILE.freekbytes;
    print(L_LINE);
    L_LINE := '</TD><TD ALIGN="right">'||Rec_FILE.usedpct||'</TD><TD ALIGN="right">'||
              Rec_FILE.phyrds||'</TD><TD ALIGN="right">'||Rec_FILE.phywrts||
              '</TD><TD ALIGN="right">'||Rec_FILE.avgiotim||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- Rollback Segments
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="11"><A NAME="rbs">Rollback Segments</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Segment</TH><TH CLASS="th_sub">Status</TH>'||
            '<TH CLASS="th_sub">Size (kB)</TH><TH CLASS="th_sub">OptSize (kB)</TH>';
  print(L_LINE);
  L_LINE := '<TH CLASS="th_sub">HWMSize (kB)</TH><TH CLASS="th_sub">Waits</TH>'||
            '<TH CLASS="th_sub">XActs</TH><TH CLASS="th_sub">Shrinks</TH>'||
            '<TH CLASS="th_sub">Wraps</TH><TH CLASS="th_sub">AveShrink</TH>';
  print(L_LINE);
  L_LINE := '<TH CLASS="th_sub">AveActive</TH></TR>';
  print(L_LINE);
  FOR Rec_RBS IN C_RBS LOOP
    L_LINE := ' <TR><TD>'||Rec_RBS.segment_name||'</TD><TD>'||Rec_RBS.status||
              '</TD><TD ALIGN="right">'||Rec_RBS.rssize||'</TD><TD ALIGN="right">'||
              Rec_RBS.optsize||'</TD><TD ALIGN="right">'||Rec_RBS.hwmsize||
              '</TD><TD ALIGN="right">'||Rec_RBS.waits;
    print(L_LINE);
    L_LINE := '</TD><TD ALIGN="right">'||Rec_RBS.xacts||'</TD><TD ALIGN="right">'||
              Rec_RBS.shrinks||'</TD><TD ALIGN="right">'||Rec_RBS.wraps||
              '</TD><TD ALIGN="right">'||Rec_RBS.aveshrink||'</TD><TD ALIGN="right">'||
              Rec_RBS.aveactive||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- Memory
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="2"><A NAME="memory">Memory Values</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Name</TH><TH CLASS="th_sub">Size</TH></TR>';
  print(L_LINE);
  FOR Rec_MEM IN C_MEM LOOP
    L_LINE := ' <TR><TD>'||Rec_MEM.name||'</TD><TD ALIGN="right">'||Rec_MEM.value||' kB</TD></TR>';
    print(L_LINE);
  END LOOP;
  FOR Rec_MEMPOOL IN C_MEMPOOL LOOP
    L_LINE := ' <TR><TD>'||Rec_MEMPOOL.name||'</TD><TD ALIGN="right">'||
              Rec_MEMPOOL.value||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- Pool Sizes
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="2"><A NAME="poolsize">Pool Sizes</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Pool</TH><TH CLASS="th_sub">Space</TH></TR>';
  print(L_LINE);
  poolsize('shared_pool_size',S1);
  L_LINE := ' <TR><TD>Shared_Pool_Size</TD><TD ALIGN="right">'||S1||'</TD></TR>'||CHR(10);
  poolsize('shared_pool_reserved_size',S1);
  L_LINE := L_LINE||' <TR><TD>Shared_Pool_Reserved_Size</TD><TD ALIGN="right">'||S1||'</TD></TR>'||CHR(10);
  poolsize('large_pool_size',S1);
  L_LINE := L_LINE||' <TR><TD>Large_Pool_Size</TD><TD ALIGN="right">'||S1||'</TD></TR>'||CHR(10);
  print(L_LINE);
  poolsize('java_pool_size',S1);
  L_LINE := ' <TR><TD>Java_Pool_Size</TD><TD ALIGN="right">'||S1||'</TD></TR>'||CHR(10);
  poolsize('sort_area_size',S1);
  L_LINE := L_LINE||' <TR><TD>Sort_Area_Size</TD><TD ALIGN="right">'||S1||'</TD></TR>'||CHR(10);
  poolsize('sort_area_retained_size',S1);
  L_LINE := L_LINE||' <TR><TD>Sort_Area_Retained_Size</TD><TD ALIGN="right">'||S1||'</TD></TR>'||CHR(10);
  print(L_LINE);

  L_LINE := ' <TR><TH CLASS="th_sub">Pool</TH><TH CLASS="th_sub">Free Space</TH></TR>';
  print(L_LINE);
  FOR Rec_POOL IN C_POOL LOOP
    L_LINE := ' <TR><TD>'||Rec_POOL.pool||'</TD><TD ALIGN="right">'||
              Rec_POOL.kbytes||' kB</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);

  -- Shared Pool Information
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="6"><A NAME="sharedpool">Shared Pool Information</A></TH></TR>'||CHR(10)||
            ' <TR><TH COLSPAN="6" CLASS="th_sub">Library Cache</TH></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD COLSPAN="6">The following cases are indicators '||
            'that SHARED_POOL_SIZE may have to be increased:';
  print(L_LINE);
  L_LINE := ' <BR><LI>RPP (100*reloads/pins) &gt; 1</LI><BR><LI>gethitratio &lt; 90%</LI></TD><TR>'||
            ' <TR><TD CLASS="td_name">NameSpace</TD><TD CLASS="td_name">Gets</TD>';
  print(L_LINE);
  L_LINE := ' <TD CLASS="td_name">Pins</TD><TD CLASS="td_name">Reloads</TD>'||
            '<TD CLASS="td_name">RPP</TD>'||
            '<TD CLASS="td_name">GetHitRatio (%)</TD></TR>';
  print(L_LINE);
  FOR Rec_LIB IN C_LIB LOOP
    L_LINE := ' <TR><TD>'||Rec_LIB.namespace||'</TD><TD ALIGN="right">'||
              Rec_LIB.gets||'</TD>'||'<TD ALIGN="right">'||Rec_LIB.pins||
              '</TD><TD ALIGN="right">'||Rec_LIB.reloads||
              '</TD><TD ALIGN="right">'||Rec_LIB.rratio||
	      '</TD><TD ALIGN="right">'||Rec_LIB.ratio||'</TD></TR>';
    print(L_LINE);
  END LOOP;

  L_LINE := ' <TR><TD COLSPAN="6">'||CHR(38)||'nbsp;</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH COLSPAN="6" CLASS="th_sub">Row Cache</TH></TR>'||
            ' <TR><TD COLSPAN="6">If Ratio = (getmisses/gets)*100 > 15,'||
            ' SHARED_POOL_SIZE may have to be increased:</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD COLSPAN="3" CLASS="td_name">Parameter</TD><TD CLASS="td_name">Gets</TD>'||
            '<TD CLASS="td_name">GetMisses</TD><TD CLASS="td_name">Ratio</TD></TR>';
  print(L_LINE);
  FOR Rec_ROW IN C_ROW LOOP
    L_LINE := ' <TR><TD COLSPAN="3">'||Rec_ROW.parameter||'</TD><TD ALIGN="right">'||
              Rec_ROW.gets||'</TD><TD ALIGN="right">'||Rec_ROW.getmisses||
              '</TD><TD ALIGN="right">'||Rec_ROW.ratio||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);

  -- Buffer Pool Statistics
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5"><A NAME="bufferpool">Buffer Pool Statistics</A></TH></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD COLSPAN="5">Ratio = physical_reads/(consistent_gets+db_block_gets)'||
            ' should be &lt; 0.9:';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Pool</TH><TH CLASS="th_sub">'||
            'physical_reads</TH><TH CLASS="th_sub">consistent_gets</TH>'||
            '<TH CLASS="th_sub">db_block_gets</TH><TH CLASS="th_sub">Ratio</TH></TR>';
  print(L_LINE);
  FOR Rec_BUF IN C_BUF LOOP
    L_LINE := ' <TR><TD>'||Rec_BUF.name||'</TD><TD ALIGN="right">'||
              Rec_BUF.physical_reads||'</TD><TD ALIGN="right">'||
              Rec_BUF.consistent_gets||'</TD><TD ALIGN="right">'||
              Rec_BUF.db_block_gets||'</TD><TD ALIGN="right">'||
              Rec_BUF.ratio||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- V$SYSSTAT: extracted informations
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="3"><A NAME="sysstat">SYSSTAT Info</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Name</TH><TH CLASS="th_sub">Value</TH>'||
            '<TH CLASS="th_sub">Description</TH></TR>';
  print(L_LINE);
  SELECT value INTO I1 FROM v\$sysstat WHERE name='sorts (disk)';
  SELECT value INTO I2 FROM v\$sysstat WHERE name='sorts (memory)';
  I3 := I1+I2;
  IF NVL(I3,0) = 0
  THEN
    S1 := '&nbsp;';
  ELSE
    S1 := TO_CHAR(100*I1/I3,'990.00');
  END IF;
  L_LINE := ' <TR><TD WIDTH="300">Percent DiskSorts (of DiskSorts + MemSorts)</TD>'||
            '<TD ALIGN="right">'||S1||'</TD><TD>Should be less than 5% - ';
  print(L_LINE);
  L_LINE := 'higher values are an indicator to increase <I>SORT_AREA_SIZE</I>, '||
            'but you of course have to consider the amount of physical memory '||
	    'available on your machine.</TD></TR>';
  print(L_LINE);
  sysstat_per('summed dirty queue length','write requests',S1);
  L_LINE := ' <TR><TD>summed dirty queue length / write requests</TD><TD ALIGN="right">'||S1||
            '</TD><TD>If this value is &gt; 100, the LGWR is too lazy -- so you may '||
            'want to decrease <I>DB_BLOCK_MAX_DIRTY_TARGET</I></TD></TR>';
  print(L_LINE);
  sysstat_per('free buffer inspected','free buffer requested',S1);
  L_LINE := ' <TR><TD>free buffer inspected / free buffer requested</TD><TD ALIGN="right">'||
            S1||'</TD><TD>Increase your buffer cache if this value is too high</TD></TR>';
  print(L_LINE);
  sysstat_per('redo buffer allocation retries','redo blocks written',S1);
  L_LINE := ' <TR><TD>redo buffer allocation retries / redo blocks written</TD>'||
            '<TD ALIGN="right">'||S1||'</TD><TD>should be less than 0.01 - larger '||
	    'values indicate ';
  print(L_LINE);
  L_LINE := 'that the LGWR is not keeping up. If this happens, tuning the values '||
            'for <CODE>LOG_CHECKPOINT_INTERVAL</CODE> and <CODE>LOG_CHECKPOINT_TIMEOUT</CODE> '||
	    '(or, with Oracle 9i, ';
  print(L_LINE);
  L_LINE := ' <CODE>FAST_START_MTTR_TARGET</CODE>) can help to improve the '||
            'situation.</TD></TR>';
  print(L_LINE);
  SELECT value INTO I1 FROM v\$sysstat WHERE name='redo log space requests';
  S1 := to_char(I1,'999,999,990.99');
  L_LINE := ' <TR><TD>redo log space requests</TD><TD ALIGN="right">'||S1||
            '</TD><TD>how often the log file was full and Oracle had to wait '||
            'for a new file to become available</TD></TR>';
  print(L_LINE);
  SELECT value INTO I1 FROM v\$sysstat WHERE name='table fetch continued row';
  S1 := to_char(I1,'999,999,990.99');
  L_LINE := ' <TR><TD>table fetch continued row</TD><TD ALIGN="right">'||S1||
            '</TD><TD>How many migrated rows did we encounter during this '||
            'instances life time? Since these can cause acute performance ';
  print(L_LINE);
  L_LINE := 'degration, they should be corrected immediately if they are being '||
            'reported. For this, you may have to analyse your tables:';
  print(L_LINE);
  L_LINE := '<PRE>ANALYZE TABLE tablename COMPUTE STATISTICS;'||CHR(10)||
            'SELECT num_rows,chain_cnt FROM dba_tables WHERE table_name='||
            CHR(39)||'tablename'||CHR(39)||';</PRE>'||
            '<I>utlchain.sql</I> then may help you to automatically eliminate '||
            'migration (correct PCTFREE before running that!).</TD></TR>';
  print(L_LINE);
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- Selected Events
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="6"><A NAME="events">Selected Wait Events (from v'||CHR(36)||'system_event)</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Name</TH><TH CLASS="th_sub">Totals</TH>';
  print(L_LINE);
  L_LINE := '<TH CLASS="th_sub">Total WaitTime (s)</TH><TH CLASS="th_sub">Avg Waited (ms)</TH>'||
            '<TH CLASS="th_sub">Timeouts</TH>'||'<TH CLASS="th_sub">Description</TH></TR>';
  print(L_LINE);
  get_wait('free buffer waits',S4,S1,S2,S3);
  L_LINE := ' <TR><TD><DIV STYLE="width:22ex">free buffer waits</DIV></TD><TD ALIGN="right">'||S1||
            '</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||S4||'</TD>'||
	    '<TD ALIGN="right">'||S3;
  print(L_LINE);
  L_LINE := '</TD><TD>This wait event occurs when the database attemts to locate '||
	    'a clean block buffer but cannot because there are too many outstanding '||
	    'dirty blocks waiting to be written. ';
  print(L_LINE);
  L_LINE := 'This could be an indication that either your database is having an '||
            'IO problem (check the other IO related wait events to validate this) '||
	    'or your database is very busy ';
  print(L_LINE);
  L_LINE := 'and you simply don''t have enough block buffers to go around. A possible '||
            'solution is to adjust the frequency of your checkpoints by tuning the '||
	    '<CODE>CHECK_POINT_TIMEOUT</CODE>';
  print(L_LINE);
  L_LINE := 'and <CODE>CHECK_POINT_INTERVAL</CODE> parameters to help the DBWR '||
            'process to keep up.</TD></TR>';
  print(L_LINE);
  get_wait('buffer busy waits',S4,S1,S2,S3);
  L_LINE := ' <TR><TD><DIV STYLE="width:22ex">buffer busy waits</DIV></TD><TD ALIGN="right">'||S1||
            '</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||S4||'</TD>'||
	    '<TD ALIGN="right">'||S3;
  print(L_LINE);
  L_LINE := '</TD><TD>Indicates contention for a buffer in the SGA. You may need '||
            'to increase the <CODE>INITRANS</CODE> parameter for a specific table ';
  print(L_LINE);
  L_LINE := 'or index if the event is identified as belonging to either a table '||
            'or index.</TD></TR>';
  print(L_LINE);
  get_wait('db file sequential read',S4,S1,S2,S3);
  L_LINE := ' <TR><TD>db file sequential read</TD><TD ALIGN="right">'||S1||
            '</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||S4||'</TD>'||
	    '<TD ALIGN="right">'||S3;
  print(L_LINE);
  L_LINE := '</TD><TD>Indicator for I/O problems on index accesses<BR><DIV CLASS="small">'||
	    '(Consider increasing the buffer cache when value is high)</DIV></TD></TR>';
  print(L_LINE);
  get_wait('db file scattered read',S4,S1,S2,S3);
  L_LINE := ' <TR><TD>db file scattered read</TD><TD ALIGN="right">'||S1||
            '</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||S4||'</TD>'||
	    '<TD ALIGN="right">'||S3;
  print(L_LINE);
  L_LINE := '</TD><TD>Indicator for I/O problems on full table scans<BR><DIV CLASS="small">'||
            '(On increasing <I>DB_FILE_MULTI_BLOCK_READ_COUNT</I> if this value '||
            'is high see the first block of Miscellaneous below)</DIV></TD></TR>';
  print(L_LINE);
  get_wait('undo segment extension',S4,S1,S2,S3);
  L_LINE := ' <TR><TD>undo segment extension</TD><TD ALIGN="right">'||S1||
            '</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||S4||'</TD>'||
	    '<TD ALIGN="right">'||S3;
  print(L_LINE);
  L_LINE := '</TD><TD>Whenever the database must extend or shrink a rollback '||
            'segment, this wait event occurs while the rollback segment is being '||
            'manipulated. ';
  print(L_LINE);
  L_LINE := 'High wait times here could indicate a problem with the extent size, '||
            'the value of MINEXTENTS, or possibly IO related problems.</TD></TR>';
  print(L_LINE);
  get_wait('enqueue',S4,S1,S2,S3);
  L_LINE := ' <TR><TD>enqueue</TD><TD ALIGN="right">'||S1||
            '</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||S4||'</TD>'||
	    '<TD ALIGN="right">'||S3;
  print(L_LINE);
  L_LINE := '</TD><TD>This type of event may be an indication that something is '||
            'either wrong with the code (should multiple sessions be serializing '||
	    'themselves against a common row?) ';
  print(L_LINE);
  L_LINE := 'or possibly the physical design (high activity on child tables '||
            'with unindexed foreign keys, inadequate INITRANS or MAXTRANS '||
	    'values, etc.';
  print(L_LINE);
  L_LINE := 'Since this event also indicates that there are too many DML or DDL '||
            'locks (or, maybe, a large number of sequences), increasing the '||
	    '<CODE>ENQUEUE_RESOURCES</CODE>';
  print(L_LINE);
  L_LINE := 'parameter in the <CODE>init.ora</CODE> will help reduce these waits.</TD></TR>';
  print(L_LINE);
  get_wait('latch free',S4,S1,S2,S3);
  L_LINE := ' <TR><TD>latch free</TD><TD ALIGN="right">'||S1||
            '</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||S4||'</TD>'||
	    '<TD ALIGN="right">'||S3;
  print(L_LINE);
  L_LINE := '</TD><TD>This event occurs whenever one Oracle process is requesting '||
            'a "willing to wait" latch from another process. The event only occurs '||
	    'if the spin_count has been exhausted, ';
  print(L_LINE);
  L_LINE := 'and the waiting process goes to sleep. Latch free waits can occur '||
            'for a variety of reasons including library cache issues, OS process '||
	    'intervention ';
  print(L_LINE);
  L_LINE := '(processes being put to sleep by the OS, etc.), and so on.</TD></TR>';
  print(L_LINE);
  get_wait('LGWR wait for redo copy',S4,S1,S2,S3);
  L_LINE := ' <TR><TD>LGWR wait for redo copy</TD><TD ALIGN="right">'||S1||
            '</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||S4||'</TD>'||
	    '<TD ALIGN="right">'||S3;
  print(L_LINE);
  L_LINE := '</TD><TD>This only needs your attention when many timeouts occur. '||
            'A large amount of waits/wait times does not necessarily indicate a '||
	    'problem - normally it just says ';
  print(L_LINE);
  L_LINE := 'that LGWR waited for incomplete copies into the Redo buffers that '||
            'it intends to write.</TD></TR>';
  print(L_LINE);
  get_wait('log file switch (checkpoint incomplete)',S4,S1,S2,S3);
  L_LINE := ' <TR><TD>log file switch (checkpoint incomplete)</TD><TD ALIGN="right">'||S1||
            '</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||S4||'</TD>'||
	    '<TD ALIGN="right">'||S3;
  print(L_LINE);
  L_LINE := '</TD><TD>Higher values indicate that either your ReDo logs are too small or there are not enough log file groups</TD></TR>';
  print(L_LINE);
  get_wait('log file switch completion',S4,S1,S2,S3);
  L_LINE := ' <TR><TD>log file switch completion</TD><TD ALIGN="right">'||S1||
            '</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||S4||'</TD>'||
	    '<TD ALIGN="right">'||S3;
  print(L_LINE);
  L_LINE := '</TD><TD>You may consider increasing the number of logfile groups.</TD></TR>';
  print(L_LINE);
  get_wait('log buffer wait',S4,S1,S2,S3);
  L_LINE := ' <TR><TD>log buffer wait</TD><TD ALIGN="right">'||S1||
            '</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||S4||'</TD>'||
	    '<TD ALIGN="right">'||S3;
  print(L_LINE);
  L_LINE := '</TD><TD>If this value is too high, log buffers are filling faster '||
            'than being emptied. You then have to consider to increase the '||
            'number of logfile groups or to use larger log files.</TD></TR>';
  print(L_LINE);
  get_wait('log buffer space',S4,S1,S2,S3);
  L_LINE := ' <TR><TD>log buffer space</TD><TD ALIGN="right">'||S1||
            '</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||S4||'</TD>'||
	    '<TD ALIGN="right">'||S3;
  print(L_LINE);
  L_LINE := '</TD><TD>This event frequently occurs when the log buffers are '||
            'filling faster than LGWR can write them to disk. The two obvious '||
            'solutions are to either ';
  print(L_LINE);
  L_LINE := 'increase the amount of log buffers or to change your Redo log '||
            'layout and/or IO strategy.</TD></TR>';
  print(L_LINE);
  get_wait('log file parallel write',S4,S1,S2,S3);
  L_LINE := ' <TR><TD>log file parallel write</TD><TD ALIGN="right">'||S1||
            '</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||S4||'</TD>'||
	    '<TD ALIGN="right">'||S3;
  print(L_LINE);
  L_LINE := '</TD><TD ROWSPAN="2">Indicator for Redo log layout and/or IO strategy<BR>'||
            'As the wait times on these events become higher, you will notice '||
            'additional Wait Events such as ';
  print(L_LINE);
  L_LINE := '<I>log buffer space</I>, <I>log file switch (archiving needed)</I>, '||
            'etc.</TD></TR>';
  print(L_LINE);
  get_wait('log file single write',S4,S1,S2,S3);
  L_LINE := ' <TR><TD>log file single write</TD><TD ALIGN="right">'||S1||
            '</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||S4||'</TD>'||
	    '<TD ALIGN="right">'||S3||'</TD></TR>';
  print(L_LINE);
  get_wait('SQL*Net message to client',S4,S1,S2,S3);
  L_LINE := ' <TR><TD>SQL*Net message to client</TD><TD ALIGN="right">'||S1||
            '</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||S4||'</TD>'||
	    '<TD ALIGN="right">'||S3;
  print(L_LINE);
  L_LINE := '</TD><TD ROWSPAN="2">These wait events occur when the Database'||
            'unexpectedly looses Net8 connectivity with a remote client or '||
            'Database. ';
  print(L_LINE);
  L_LINE := 'Frequent occurences of these events could indicate a networking '||
            'issue.</TD></TR>';
  print(L_LINE);
  get_wait('SQL*Net message to dblink',S4,S1,S2,S3);
  L_LINE := ' <TR><TD>SQL*Net message to dblink</TD><TD ALIGN="right">'||S1||
            '</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||S4||'</TD>'||
	    '<TD ALIGN="right">'||S3||'</TD></TR>';
  print(L_LINE);
  L_LINE := TABLE_CLOSE;
  print(L_LINE);

  -- Who caused the wait events?
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="3"><A NAME="waitobj">Objects causing Wait Events</A></TH></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD COLSPAN="3">On the following segments we noticed one of the '||
            'events <I>buffer busy waits</I>, <I>db file sequential read</I>, '||
	    '<I>db file scattered read</I> or <I>free buffer waits</I> at the '||
	    'time the report was generated.';
  print(L_LINE);
  L_LINE := 'If you had many <I>db file scattered reads</I> above and now find '||
            'some entries with segment type = table in here, these may need ';
  print(L_LINE);
  L_LINE := 'some|more|better|other indices. Use <I>Statspack</I> or <I>'||
	    'Oracle Enterprise Manager Diagnostics Pack</I> to find out more. '||
	    'Other things that may help to avoid some of the <I>db file * read</I> ';
  print(L_LINE);
  L_LINE := 'wait events are:<UL STYLE="margin-top:0;margin-bottom:0">'||
            '<LI>Tune the SQL statements used by your applications and users (most important!)</LI>'||
            '<LI>Re-Analyze the schema to help the optimizer with accurate data e.g. with <I>dbms_stats</I></LI>';
  print(L_LINE);
  L_LINE := '<LI>Stripe objects over multiple disk volumes</LI>'||
            '<LI>Pin frequently used objects</LI><LI>Increase the buffer caches</LI></UL></TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Owner</TH><TH CLASS="th_sub">'||
            'Segment Name</TH><TH CLASS="th_sub">Segment Type</TH></TR>';
  print(L_LINE);
  FOR Rec_WAIT IN C_WAIT LOOP
    L_LINE := ' <TR><TD>'||Rec_WAIT.owner||'</TD><TD ALIGN="right">'||
              Rec_WAIT.segment_name||'</TD><TD ALIGN="right">'||
              Rec_WAIT.segment_type||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- Invalid Objects
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5"><A NAME="invobj">Invalid Objects</A></TH></TR>'||CHR(10)||
            ' <TR><TD COLSPAN="5">The following objects may need your investigation. These are not';
  print(L_LINE);
  L_LINE := ' necessarily problem indicators (e.g. an invalid view may automatically re-compile), but could be:</TH></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Owner</TH><TH CLASS="th_sub">Object</TH><TH CLASS="th_sub">Typ</TH>'||
            '<TH CLASS="th_sub">Created</TH><TH CLASS="th_sub">Last DDL</TH></TR>';
  print(L_LINE);
  FOR Rec_INVOBJ IN C_INVOBJ LOOP
    L_LINE := ' <TR><TD>'||Rec_INVOBJ.owner||'</TD><TD>'||Rec_INVOBJ.object_name||
              '</TD><TD>'||Rec_INVOBJ.object_type||'</TD><TD>'||Rec_INVOBJ.created||
	      '</TD><TD>'||Rec_INVOBJ.last_ddl_time||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- Miscellaneous
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="2"><A NAME="misc">Miscellaneous</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Name</TH><TH CLASS="th_sub">Value</TH></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD COLSPAN="2" CLASS="td_name">If we have many full table '||
            'scans, we may have to optimize <I>DB_FILE_MULTI_BLOCK_READ_COUNT</I>. '||
            'Beneath the statistic below, we need the block count of the largest '||
            'table to find the best value. ';
  print(L_LINE);
  L_LINE := 'A common recommendation is to set <I>DB_FILE_MULTI_BLOCK_READ_COUNT</I> '||
            'to the highest possible value for maximum performance, which is '||
	    '32 (256k) in most environments. The absolute maximum of 128 (1M) is '||
	    'mostly only available on raw devices.</TD></TR>';
  print(L_LINE);
  FOR Rec_SCAN IN C_SCAN LOOP
    L_LINE := ' <TR><TD>'||Rec_SCAN.name||'</TD><TD ALIGN="right">'||
              Rec_SCAN.value||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := ' <TR><TD COLSPAN="2" CLASS="td_name">If there are tables that '||
            'will for sure need more extents shortly, we can reduce I/O overhead '||
            'allocating some extents for them in advance, using ';
  print(L_LINE);
  L_LINE := '"ALTER TABLE tablename ALLOCATE EXTENT". Here are some '||
            'candidates, having less than 10 percent free blocks left:</TD></TR>';
  print(L_LINE);
  FOR Rec_EXT IN C_EXT LOOP
    L_LINE := ' <TR><TD>'||Rec_EXT.owner||'.'||Rec_EXT.table_name||
              '</TD><TD ALIGN="right">'||Rec_EXT.freepct||'%</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);

  -- Page Ending
  L_LINE := '<HR>'||CHR(10)||TABLE_OPEN;
  print(L_LINE);
  L_LINE := '<TR><TD><DIV CLASS="small">Created by OraRep v$version &copy; 2003 by '||
	    '<A HREF="http://www.qumran.org/homes/izzy/" TARGET="_blank">Itzchak Rehberg</A> '||
            '&amp; <A HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft</A></DIV></TD></TR>';
  print(L_LINE);
  print(TABLE_CLOSE);
  L_LINE := '</BODY></HTML>'||CHR(10);
  print(L_LINE);

END;
/

SPOOL off

EOF
