BEGIN
  -- Configuration
  CSS := :CSS;
  SCRIPTVER := :SCRIPTVER;
  TOP_N_WAITS  := :TOP_N_WAITS;
  TOP_N_TABLES := :TOP_N_TABLES;
  MK_RSRC      := :MK_RSRC;
  MK_DBAPROF   := :MK_DBAPROF;
  MK_TSQUOT    := :MK_TSQUOT;
  MK_FILES     := :MK_FILES;
  MK_RBS       := :MK_RBS;
  MK_MEMVAL    := :MK_MEMVAL;
  MK_POOL      := :MK_POOL;
  MK_ENQ       := :MK_ENQ;
  MK_WAITOBJ  := have_waits();
  MK_INVALIDS := have_invalids();
  MK_TABSCAN  := have_tablescans();
  MK_EXTNEED  := have_extentneed();
  MK_BUFFP    := have_buffp_stats();
  MK_ADVICE   := have_advice();
  IF MK_ENQ = 1 THEN
    MK_ENQS := have_enqs();
  ELSE
    MK_ENQS := FALSE;
  END IF;
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
  L_LINE := TABLE_OPEN||'<TR><TD><DIV CLASS="small">[ <A HREF="#users">Users</A> ] ';
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
  IF MK_FILES = 1 THEN
    L_LINE := L_LINE||'[ <A HREF="#datafiles">Datafiles</A> ]';
  END IF;
  IF MK_RBS = 1 THEN
    L_LINE := L_LINE||' [ <A HREF="#rbs">Rollback</A> ]';
  END IF;
  IF MK_MEMVAL = 1 THEN
    L_LINE := L_LINE||' [ <A HREF="#memory">Memory</A> ]';
  END IF;
  print(L_LINE);
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
  L_LINE := L_LINE||' [ <A HREF="#sysstat">SysStat</A> ]';
  print(L_LINE);
  L_LINE := ' [ <A HREF="#events">Events</A> ]';
  IF MK_WAITOBJ
  THEN 
    L_LINE := L_LINE||' [ <A HREF="#waitobj">Wait Objects</A> ]';
  END IF;
  IF MK_ENQS THEN
    L_LINE := L_LINE||' [ <A HREF="#enqwaits">Enqueue Waits</A> ]';
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
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="9"><A NAME="users">User Information</A>'||
            '&nbsp;<A HREF="JavaScript:popup('||CHR(39)||'userinfo'||CHR(39)||
	    ')"><IMG SRC="help/help.gif" BORDER="0" HEIGTH="12" '||
	    'VALIGN="middle"></A></TH></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Username</TH><TH CLASS="th_sub">Account'||
            ' Status</TH><TH CLASS="th_sub">Lock Date</TH><TH CLASS="th_sub">';
  print(L_LINE);
  L_LINE := 'Expiry Date</TH><TH CLASS="th_sub">Default TS</TH><TH CLASS="th_sub">'||
            'Temporary TS</TH><TH CLASS="th_sub">Created</TH><TH CLASS="th_sub">'||
            'Profile</TH><TH CLASS="th_sub">Init.ResourceGroup</TH></TR>';
  print(L_LINE);
  FOR Rec_USER IN C_USER LOOP
    L_LINE := ' <TR><TD>'||Rec_USER.username||'</TD><TD>'||Rec_USER.account_status||
              '</TD><TD>'||Rec_USER.locked||'</TD><TD>'||Rec_USER.expires||
              '</TD><TD>'||Rec_USER.dts||'</TD><TD>'||Rec_USER.tts||'</TD><TD>'||
              Rec_USER.created;
    print(L_LINE);
    L_LINE := '</TD><TD>'||Rec_USER.profile||'</TD><TD>'||Rec_USER.resource_group||
              '</TD></TR>';
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

