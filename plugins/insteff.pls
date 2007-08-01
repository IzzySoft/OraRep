  -- Instance Efficiency Percentages
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="3"><A NAME="efficiency">Instance Efficiency Percentages (Target: 100%)</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Event</TH><TH CLASS="th_sub">Efficiency (%)</TH>'||
	    '<TH CLASS="th_sub">Comment</TH></TR>';
  print(L_LINE);
  SELECT SUM(count) INTO I1 FROM v$waitstat;
  I2 := dbstat('session logical reads');
  S2 := alert_lt_warn(100*(1-I1/I2),:AR_IE_BUFFNW,:WR_IE_BUFFNW);
  L_LINE := ' <TR><TD><DIV STYLE="width:13em">Buffer Nowait</DIV></TD><TD ALIGN="right"'||
            S2||'>'||to_char(round(100*(1-I1/I2),2),'990.00');
  print(L_LINE);
  L_LINE := '</TD><TD CLASS="text">If this ratio is low, check the '||
            '<A HREF="#buffwait">Buffer Wait Stats</A> section for more detail '||
	    'on which type of block is being contended for.</TD></TR>';
  print(L_LINE);
  I1 := dbstat('redo entries');
  IF I1 = 0
  THEN S1 := '&nbsp;';
  ELSE S1 := decformat(100*(1-I1/I2));
       S2 := alert_lt_warn(100*(1-I1/I2),:AR_IE_REDONW,:WR_IE_REDONW);
  END IF;
  L_LINE := ' <TR><TD>Redo Nowait</TD><TD ALIGN="right"'||S2||'>'||S1||
            '</TD><TD CLASS="text">A value close to 100% indicates minimal '||
	    'time spent waiting for redo logs ';
  print(L_LINE);
  L_LINE := 'to become available, either because the logs are not filling up '||
            'very often or because the database is able to switch to a new log '||
	    'quickly whenever the current log fills up.</TD></TR>';
  print(L_LINE);
  I1 := dbstat('physical reads') - dbstat('physical reads direct') - dbstat('physical reads direct (lob)');
  S2 := alert_lt_warn(100*(1-I1/I2),:AR_IE_BUFFHIT,:WR_IE_BUFFHIT);
  L_LINE := ' <TR><TD>Buffer Hit&nbsp;<A HREF="JavaScript:popup('||CHR(39)||'buffhits'||CHR(39)||
            ')"><IMG SRC="help/help.gif" BORDER="0" HEIGHT="16" ALIGN="top" ALT="Help"></A>'||
            '</TD><TD ALIGN="right"'||S2||'>'||decformat(100*(1-I1/I2));
  print(L_LINE);
  L_LINE := '</TD><TD CLASS="text">A low buffer hit ratio does not necessarily mean '||
            'the cache is too small: it may very well be that potentially valid '||
	    'full-table-scans are artificially ';
  print(L_LINE);
  L_LINE := 'reducing what is otherwise a good ratio. A too-small buffer cache '||
            'can sometimes be identified by the appearance of write complete waits '||
	    'event indicating hot blocks ';
  print(L_LINE);
  L_LINE := '(i.e. blocks still being modified) are aging out of the cache while '||
            'they are still needed; check the <A HREF="#events">Wait Events</A> '||
	    'list for evidence of this event.</TD></TR>';
  print(L_LINE);
  I1 := dbstat('sorts (memory)');
  I3 := dbstat('sorts (disk)');
  IF (I1+I3) = 0
  THEN S1 := '&nbsp;';
  ELSE S1 := decformat(100*I1/(I1+I3));
       S2 := alert_lt_warn(100*I1/(I1+I3),:AR_IE_IMSORT,:WR_IE_IMSORT);
  END IF;
  L_LINE := ' <TR><TD>In-Memory Sort&nbsp;<A HREF="JavaScript:popup('||CHR(39)||'sorts'||CHR(39)||
            ')"><IMG SRC="help/help.gif" BORDER="0" HEIGHT="16" ALIGN="top" ALT="Help"></A></TD>';
  print(L_LINE);
  L_LINE := '<TD ALIGN="right"'||S2||'>'||S1||'</TD><TD CLASS="text">A too low ratio indicates '||
	    'too many disk sorts appearing. One possible ';
  print(L_LINE);
  L_LINE := 'solution could be increasing the sort area/PGA size.</TD></TR>';
  print(L_LINE);
  SELECT 100*sum(pinhits)/sum(pins) INTO I1 FROM v$librarycache;
  S2 := alert_lt_warn(I1,:AR_IE_LIBHIT,:WR_IE_LIBHIT);
  L_LINE := ' <TR><TD>Library Hit</TD><TD ALIGN="right"'||S2||'>'||
            decformat(I1);
  print(L_LINE);
  L_LINE := '</TD><TD CLASS="text">A low library hit ratio could imply that '||
            'SQL is prematurely aging out of a too-small shared pool, or that '||
	    'non-shareable SQL is being used. ';
  print(L_LINE);
  L_LINE := 'If the soft parse ratio is also low, check whether there is a '||
            'parsing issue.</TD></TR>';
  print(L_LINE);
  I1 := dbstat('parse count (hard)') / dbstat('parse count (total)');
  S2 := alert_lt_warn(100*(1-I1),:AR_IE_SOFTPRS,:WR_IE_SOFTPRS);
  L_LINE := ' <TR><TD>Soft Parse&nbsp;<A HREF="JavaScript:popup('||CHR(39)||'softparse'||CHR(39)||
            ')"><IMG SRC="help/help.gif" BORDER="0" HEIGHT="16" ALIGN="top" ALT="Help"></A>'||
            '</TD><TD ALIGN="right"'||S2||'>'||
            decformat(100*(1-I1))||'</TD><TD CLASS="text">When the soft parse ';
  print(L_LINE);
  L_LINE := 'ratio falls much below 80%, investigate whether you can share '||
            'SQL by using bind variables or force cursor sharing. But before '||
            'drawing any conclusions, compare the soft parse ';
  print(L_LINE);
  L_LINE := 'ratio against the actual hard and soft parse rates shown in the ';
  IF :MK_LOADPROF = 1 THEN
    L_LINE := L_LINE||'<A HREF="#loads">Loads Profile</A>. ';
  ELSE
    L_LINE := L_LINE||'Loads Profile (after enabling this in your <code>config</code> '||
              'file by setting <code>MK_LOADPROF=1</code>). ';
  END IF;
  L_LINE := L_LINE||'Furthermore, investigate the number of <I>Parse CPU to Parse '||
            'Elapsed</I> below.</TD></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD>Execute to Parse&nbsp;<A HREF="JavaScript:popup('||CHR(39)||'parseexec'||CHR(39)||
            ')"><IMG SRC="help/help.gif" BORDER="0" HEIGHT="16" ALIGN="top" ALT="Help"></A></TD>';
  print(L_LINE);
  I1 := dbstat('parse count (hard)') / dbstat('execute count');
  L_LINE := '<TD ALIGN="right">'||decformat(100*(1-I1))||
	    '</TD><TD CLASS="text">A low value here (&lt; 50%) indicates that there is no '||
            'much re-usable SQL (see <I>Soft Parse</I> for possible actions). ';
  print(L_LINE);
  L_LINE := 'It may also point to a too small shared pool, or frequent logons/logoffs. ';
  print(L_LINE);
  L_LINE := 'Negative values connote that there are more Parses than Executes, '||
            'which could point to syntactically incorrect SQL statements (or '||
            'missing privileges).</TD></TR>';
  print(L_LINE);
  SELECT SUM(misses)/SUM(gets) INTO I1 FROM v$latch;
  S2 := alert_lt_warn(100*(1-I1),:AR_IE_LAHIT,:WR_IE_LAHIT);
  L_LINE := ' <TR><TD>Latch Hit</TD><TD ALIGN="right"'||S2||'>'||
            decformat(100*(1-I1));
  print(L_LINE);
  L_LINE := '</TD><TD CLASS="text">A low value for this ratio indicates a '||
            'latching problem, whereas a high value is generally good. However, '||
	    'a high latch hit ratio can artificially mask a low get rate on a '||
	    'specific latch.</TD></TR>';
  print(L_LINE);
  I1 := dbstat('parse time elapsed');
  I3 := dbstat('parse time cpu');
  IF I1 = 0
  THEN S1 := '&nbsp;';
  ELSE S1 := decformat(100*I3/I1);
       S3 := alert_lt_warn(100*I3/I1,:AR_IE_PRSC2E,:WR_IE_PRSC2E);
  END IF;
  I1 := dbstat('CPU used by this session');
  IF I1 = 0
  THEN S2 := '&nbsp;';
  ELSE S2 := decformat(100*(1-(I3/I1)));
  END IF;
  L_LINE := ' <TR><TD>Parse CPU to Parse Elapsed</TD><TD ALIGN="right"'||S3||'>'||
            S1||'</TD><TD>A low value here indicates high wait time in parse. '||
            'These will most probably cause shared pool and/or library cache latches.';
  print(L_LINE);
  L_LINE := 'See <I>Soft Parse</I> above.</TD></TR>'||' <TR><TD>Non-Parse CPU</TD>'||
            '<TD ALIGN="right">'||S2||'</TD><TD>A low value here indicates that too much '||
            'time is spent for parsing.';
  print(L_LINE);
  L_LINE := 'See <I>Soft Parse</I> and <I>Execute to Parse</I> above for possible solutions.</TD></TR>';
  print(L_LINE);
  print(TABLE_CLOSE);
  print('<HR>');
