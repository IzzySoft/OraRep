BEGIN
  -- Configuration
  CSS := :CSS;
  SCRIPTVER := :SCRIPTVER;
  TOP_N_WAITS  := :TOP_N_WAITS;
  TOP_N_TABLES := :TOP_N_TABLES;
  MK_WAITOBJ  := have_waits();
  MK_INVALIDS := have_invalids();
  MK_TABSCAN  := have_tablescans();
  MK_EXTNEED  := have_extentneed();
  MK_BUFFP    := have_buffp_stats();
  MK_ADVICE   := have_advice();
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
            ' <SCRIPT LANGUAGE="JavaScript">'||CHR(10)||
	    '   function popup(page) {'||CHR(10)||
	    '     url = "help/" + page + ".html";';
  print(L_LINE);
  L_LINE := '     pos = (screen.width/2)-400;'||CHR(10)||
            '     helpwin = eval("window.open(url,'||CHR(39)||'help'||CHR(39)||
	    ','||CHR(39)||'toolbar=no,location=no,titlebar=no,directories=no,'||
	    'status=yes,copyhistory=no,scrollbars=yes,width=600,height=400,top=0,left="+pos+"'||
	    CHR(39)||')");';
  print(L_LINE);
  L_LINE := '   }'||CHR(10)||' </SCRIPT>'||CHR(10)||
            '</HEAD><BODY>'||CHR(10)||'<H2>'||R_TITLE||'</H2>'||CHR(10);
  print(L_LINE);

  -- Navigation
  L_LINE := TABLE_OPEN||'<TR><TD><DIV CLASS="small">[ <A HREF="#users">Users</A> ] '||
            '[ <A HREF="#datafiles">Datafiles</A> ] [ <A HREF="#rbs">Rollback</A> '||
            '] [ <A HREF="#memory">Memory</A> ]';
  print(L_LINE);
  L_LINE :=   ' [ <A HREF="#poolsize">Pool Sizes</A> ] [ <A HREF="#sharedpool">Shared Pool</A> ]';
  IF MK_BUFFP THEN
    L_LINE := L_LINE||' [ <A HREF="#bufferpool">Buffer Pool</A> ]';
  END IF;
  IF MK_ADVICE THEN
    L_LINE := L_LINE||' [ <A HREF="#advices">Advices</A> ]';
  END IF;
  L_LINE := L_LINE||' [ <A HREF="#sysstat">SysStat</A> ]';
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
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="7"><A NAME="users">User Information</A>'||
            '&nbsp;<A HREF="JavaScript:popup('||CHR(39)||'userinfo'||CHR(39)||
	    ')"><IMG SRC="help/help.gif" BORDER="0" HEIGTH="12" '||
	    'VALIGN="middle"></A></TH></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Username</TH><TH CLASS="th_sub">Account'||
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

  IF have_dblinks()
  THEN
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
    print(TABLE_CLOSE);
  END IF;
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
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="11"><A NAME="rbs">Rollback Segments</A>'||
            '&nbsp;<A HREF="JavaScript:popup('||CHR(39)||'rollstat'||CHR(39)||
	    ')"><IMG SRC="help/help.gif" BORDER="0" HEIGTH="12" '||
	    'VALIGN="middle"></A></TH></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Segment</TH><TH CLASS="th_sub">Status</TH>'||
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
  more_rbs;
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
            'that <CODE>SHARED_POOL_SIZE</CODE> may have to be increased:';
  print(L_LINE);
  L_LINE := ' <BR><UL><LI>RPP (100*reloads/pins) &gt; 1</LI><LI>gethitratio &lt; 90%</LI></UL></TD><TR>'||
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
            ' <CODE>SHARED_POOL_SIZE</CODE> may have to be increased:</TD></TR>';
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
  IF MK_BUFFP THEN
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
  END IF;

  IF MK_ADVICE THEN
    get_dbc_advice();
  END IF;
