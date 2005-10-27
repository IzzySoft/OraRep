BEGIN
  -- Configuration
  CSS := :CSS;
  SCRIPTVER := :SCRIPTVER;
  TOP_N_WAITS  := :TOP_N_WAITS;
  TOP_N_TABLES := :TOP_N_TABLES;
  MK_USER      := :MK_USER;
  MK_DBLINK    := :MK_DBLINK;
  MK_RSRC      := :MK_RSRC;
  MK_DBAPROF   := :MK_DBAPROF;
  MK_TSQUOT    := :MK_TSQUOT;
  IF MK_TSQUOT = 1 THEN
    IF NOT have_quotas() THEN
      MK_TSQUOT := 0;
    END IF;
  END IF;
  MK_TABS      := :MK_TABS;
  MK_FILES     := :MK_FILES;
  MK_DBWR      := :MK_DBWR;
  MK_LGWR      := :MK_LGWR;
  MK_RBS       := :MK_RBS;
  MK_MEMVAL    := :MK_MEMVAL;
  MK_POOL      := :MK_POOL;
  MK_BUFFRAT   := :MK_BUFFRAT;
  MK_SYSSTAT   := :MK_SYSSTAT;
  MK_WTEVT     := :MK_WTEVT;
  MK_FLC       := :MK_FLC;
  MK_ENQ       := :MK_ENQ;
  MK_INVOBJ    := :MK_INVOBJ;
  IF :MK_TSCAN = 1 THEN
    MK_TABSCAN  := have_tablescans();
  END IF;
  IF :MK_NEXT = 1 THEN
    MK_EXTNEED  := have_extentneed();
  END IF;
  MK_WAITOBJ  := have_waits();
  MK_BUFFP    := have_buffp_stats();
  MK_ADVICE   := have_advice();
  TPH_NOLOG   := :TPH_NOLOG;
  WPH_NOLOG   := :WPH_NOLOG;
  WR_BUFF     := :WR_BUFF;
  AR_BUFF     := :AR_BUFF;
  WR_FILEUSED := :WR_FILEUSED;
  AR_FILEUSED := :AR_FILEUSED;
  WR_RWP      := :WR_RWP;
  AR_RWP      := :AR_RWP;
  IF MK_ENQ = 1 THEN
    MK_ENQS := have_enqs();
  ELSE
    MK_ENQS := FALSE;
  END IF;
  SELECT (SYSDATE - startup_time) * 24 * 3600 INTO ELA FROM v$instance;
  SELECT host_name,version,archiver,instance_name INTO S1,S2,S3,S4
    FROM v$instance;
  dbms_output.enable(1000000);
  R_TITLE := 'Report for '||S4;
  TABLE_OPEN := '<TABLE ALIGN="center" BORDER="1">';
  TABLE_CLOSE := '</TABLE>'||CHR(10)||'<BR CLEAR="all">'||CHR(10);

  L_LINE := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'||CHR(10)||
            '<HTML><HEAD>'||CHR(10)||
            ' <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-15">'||
            CHR(10)||' <TITLE>'||R_TITLE||'</TITLE>';
  print(L_LINE);
  L_LINE := ' <LINK REL="stylesheet" TYPE="text/css" HREF="'||CSS||'">'||CHR(10)||
            ' <SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">'||CHR(10)||
	    '   function popup(page) {'||CHR(10)||
	    '     url = "help/" + page + ".html";';
  print(L_LINE);
  L_LINE := '     pos = (screen.width/2)-400;'||CHR(10)||
            '     helpwin = eval("window.open(url,'||CHR(39)||'help'||CHR(39)||
	    ','||CHR(39)||'toolbar=no,location=no,titlebar=no,directories=no,'||
	    'status=yes,copyhistory=no,scrollbars=yes,width=600,height=400,top=0,left="+pos+"'||
	    CHR(39)||')");';
  print(L_LINE);
  L_LINE := '   }'||CHR(10)||'  version="'||SCRIPTVER||'";'||CHR(10)||
            ' </SCRIPT>'||CHR(10)||'</HEAD><BODY>'||CHR(10)||'<H2>'||
	    R_TITLE||'</H2>'||CHR(10);
  print(L_LINE);

  -- Navigation
  L_LINE := TABLE_OPEN||'<TR><TD><DIV CLASS="small" ALIGN="center">';
  IF MK_USER = 1 THEN
    L_LINE := L_LINE||'[ <A HREF="#users">Users</A> ] ';
  END IF;
  IF MK_DBLINK = 1 THEN
    DBLINK_EXIST := have_dblinks();
    IF DBLINK_EXIST THEN
      L_LINE := L_LINE||'[ <A HREF="#dblink">DBLinks</A> ] ';
    END IF;
  END IF;
  IF MK_RSRC = 1 THEN
    L_LINE := L_LINE||'[ <A HREF="#resource_groups">Resource Mgmnt</A> ] ';
  END IF;
  IF MK_DBAPROF = 1 THEN
    L_LINE := L_LINE||'[ <A HREF="#profiles">Profiles</A> ] ';
  END IF;
  print(L_LINE);

  IF MK_TSQUOT = 1 THEN
    L_LINE := '[ <A HREF="#ts_quotas">TS Quotas</A> ] ';
  ELSE
    L_LINE := '';
  END IF;
  IF :MK_INSTEFF = 1 THEN
    L_LINE := L_LINE||' [ <A HREF="#efficiency">Effiencies</A> ]';
  END IF;
  IF MK_TABS = 1 THEN
    L_LINE := L_LINE||' [ <A HREF="#tabs">TableStats</A> ]';
  END IF;
  IF MK_FILES = 1 THEN
    L_LINE := L_LINE||'[ <A HREF="#datafiles">Datafiles</A> ]';
  END IF;
  IF MK_DBWR = 1 THEN
    L_LINE := L_LINE ||'[ <A HREF="#dbwr">DBWR</A> ]';
  END IF;
  IF MK_LGWR = 1 THEN
    L_LINE := L_LINE ||'[ <A HREF="#lgwr">LGWR</A> ]';
  END IF;
  IF MK_RBS = 1 THEN
    L_LINE := L_LINE||' [ <A HREF="#rbs">Rollback</A> ]';
  END IF;
  IF MK_MEMVAL = 1 THEN
    L_LINE := L_LINE||' [ <A HREF="#memory">Memory</A> ]';
  END IF;
  IF LENGTH(L_LINE) > 0 THEN
    print(L_LINE);
  END IF;

  IF MK_POOL = 1 THEN
    L_LINE :=   ' [ <A HREF="#poolsize">Pool Sizes</A> ] [ <A HREF="#sharedpool">Shared Pool</A> ]';
    IF MK_BUFFP THEN
      L_LINE := L_LINE||' [ <A HREF="#bufferpool">Buffer Pool</A> ]';
    END IF;
  ELSE
    L_LINE := '';
  END IF;
  IF MK_ADVICE THEN
    L_LINE := L_LINE||' [ <A HREF="#advices">Advices</A> ]';
  END IF;
  IF MK_SYSSTAT = 1 THEN
    L_LINE := L_LINE||' [ <A HREF="#sysstat">SysStat</A> ]';
  END IF;
  IF LENGTH(L_LINE) > 0 THEN
    print(L_LINE);
  END IF;

  IF MK_WTEVT = 1 THEN
    L_LINE := ' [ <A HREF="#events">Events</A> ]';
  ELSE
    L_LINE := '';
  END IF;
  IF MK_BUFFRAT = 1 THEN 
    L_LINE := L_LINE||' [ <A HREF="#buffwait">Buffer Waits</A> ]';
  END IF;
  IF MK_FLC = 1 THEN 
    L_LINE := L_LINE||' [ <A HREF="#freelist">FreeList Contention</A> ]';
  END IF;
  IF MK_WAITOBJ THEN 
    L_LINE := L_LINE||' [ <A HREF="#waitobj">Wait Objects</A> ]';
  END IF;
  IF MK_ENQS THEN
    L_LINE := L_LINE||' [ <A HREF="#enqwaits">Enqueue Waits</A> ]';
  END IF;
  IF LENGTH(L_LINE) > 0 THEN
    print(L_LINE);
  END IF;

  IF MK_INVOBJ = 1 THEN
    MK_INVALIDS := have_invalids();
    IF MK_INVALIDS THEN
      L_LINE := ' [ <A HREF="#invobj">Invalid Objects</A> ]';
    ELSE
      L_LINE := '';
    END IF;
  ELSE
    L_LINE := '';
  END IF;
  L_LINE := L_LINE||TABLE_CLOSE;
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
  SELECT to_char(startup_time,'DD.MM.YYYY HH24:MI'),to_char(sysdate - startup_time,'9990.00'),
         (sysdate - startup_time)*24
    INTO S2,S3,UTH FROM v$instance;
  L_LINE := ' <TR><TD class="td_name">FileSize (Data+Log)</TD><TD>'||S1||' MB</TD></TR>'||CHR(10)||
            ' <TR><TD class="td_name">Startup / Uptime</TD><TD>'||S2||' / '||S3||' d</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD class="td_name">Report generated:</TD><TD>'||S5||'</TD></TR>'||CHR(10)||
            TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

