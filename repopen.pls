BEGIN
  -- Configuration
  CSS := :CSS;
  SCRIPTVER := :SCRIPTVER;
  TOP_N_WAITS := :TOP_N_WAITS;
  MK_WAITOBJ  := have_waits();
  MK_INVALIDS := have_invalids();
  SELECT host_name,version,archiver,instance_name INTO S1,S2,S3,S4
    FROM v$instance;
  dbms_output.enable(1000000);
  R_TITLE := 'Report for '||S4;
  TABLE_OPEN := '<TABLE ALIGN="center" BORDER="1">';
  TABLE_CLOSE := '</TABLE>'||CHR(10)||'<BR CLEAR="all">'||CHR(10);

  L_LINE := '<HTML><HEAD>'||CHR(10)||
            ' <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15"/>'||
            CHR(10)||' <TITLE>'||R_TITLE||'</TITLE>';
  print(L_LINE);
  L_LINE := ' <LINK REL="stylesheet" TYPE="text/css" HREF="'||CSS||'">'||CHR(10)||
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
  L_LINE := ' [ <A HREF="#events">Events</A> ]';
  IF MK_WAITOBJ
  THEN 
    L_LINE := L_LINE||' [ <A HREF="#waitobj">Wait Objects</A> ]';
  END IF;
  IF MK_INVALIDS
  THEN
    L_LINE := L_LINE||' [ <A HREF="#invobj">Invalid Objects</A> ]';
  END IF;
  L_LINE := L_LINE||' [ <A HREF="#misc">Misc</A> ]</DIV></TD></TR>';
  print(L_LINE);
  L_LINE := TABLE_CLOSE;
  print(L_LINE);

  -- Initial information about this instance
  SELECT to_char(SYSDATE,'DD.MM.YYYY HH24:MI') INTO S5 FROM DUAL;
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="2">Common Instance Information</TH></TR>'||CHR(10)||
            ' <TR><TD class="td_name">Hostname:</TD><TD>'||S1||'</TD></TR>'||CHR(10)||
            ' <TR><TD class="td_name">Instance:</TD><TD>'||S4||'</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD class="td_name">Version:</TD><TD>'||S2||'</TD></TR>'||CHR(10)||
            ' <TR><TD class="td_name">Archiver:</TD><TD>'||S3||'</TD></TR>';
  print(L_LINE);
  SELECT SUM(blocks*block_size)/(1024*1024) INTO I1 FROM v$archived_log;
  S1 := to_char(I1,'999,999,999.99');
  L_LINE := ' <TR><TD class="td_name">ArchivedLogSize:</TD><TD>'||S1||' MB</TD></TR>';
  print(L_LINE);
  SELECT SUM(members*bytes) INTO I1 FROM v$log;
  SELECT SUM(bytes) INTO I2 from v$datafile;
  I3 := (I1+I2)/1048576;
  S1 := to_char(I3,'999,999,999.99');
  SELECT to_char(startup_time,'DD.MM.YYYY HH24:MI'),to_char(sysdate - startup_time,'9990.00')
    INTO S2,S3 FROM v$instance;
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
  get_dbc_advice();
  print('<HR>');

  -- V$SYSSTAT: extracted informations
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="3"><A NAME="sysstat">SYSSTAT Info</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Name</TH><TH CLASS="th_sub">Value</TH>'||
            '<TH CLASS="th_sub">Description</TH></TR>';
  print(L_LINE);
  SELECT value INTO I1 FROM v$sysstat WHERE name='sorts (disk)';
  SELECT value INTO I2 FROM v$sysstat WHERE name='sorts (memory)';
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
  SELECT value INTO I1 FROM v$sysstat WHERE name='redo log space requests';
  S1 := to_char(I1,'999,999,990.99');
  L_LINE := ' <TR><TD>redo log space requests</TD><TD ALIGN="right">'||S1||
            '</TD><TD>how often the log file was full and Oracle had to wait '||
            'for a new file to become available</TD></TR>';
  print(L_LINE);
  SELECT value INTO I1 FROM v$sysstat WHERE name='table fetch continued row';
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
            'process to keep up. Increasing the buffer cache may also be helpful.</TD></TR>';
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
  L_LINE := TABLE_CLOSE||'<HR>';
  print(L_LINE);

  -- Who caused the wait events?
