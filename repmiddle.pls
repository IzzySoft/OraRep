
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
    IF 100*I1/I3 > 5 THEN
      S2 := ' CLASS="alert"';
    ELSE
      S2 := '';
    END IF;
  END IF;
  L_LINE := ' <TR><TD WIDTH="300">Percent DiskSorts (of DiskSorts + MemSorts)</TD>'||
            '<TD ALIGN="right"'||S2||'>'||S1||'</TD><TD>Should be less than 5% - ';
  print(L_LINE);
  L_LINE := 'higher values are an indicator to increase <CODE>SORT_AREA_SIZE</CODE>, '||
            'but you of course have to consider the amount of physical memory '||
	    'available on your machine.</TD></TR>';
  print(L_LINE);
  sysstat_per('summed dirty queue length','write requests',100,90,S1,S2);
  L_LINE := ' <TR><TD>summed dirty queue length / write requests</TD><TD ALIGN="right"'||
            S2||'>'||S1||'</TD><TD>If this value is &gt; 100, the LGWR is too '||
	    'lazy -- so you may want to decrease '||
	    '<CODE>DB_BLOCK_MAX_DIRTY_TARGET</CODE></TD></TR>';
  print(L_LINE);
  sysstat_per('free buffer inspected','free buffer requested',50,2,S1,S2);
  L_LINE := ' <TR><TD>free buffer inspected / free buffer requested</TD>'||
            '<TD ALIGN="right"'||S2||'>'||S1||'</TD><TD>Increase your buffer '||
	    'cache if this value is too high</TD></TR>';
  print(L_LINE);
  sysstat_per('redo buffer allocation retries','redo blocks written',0.01,0.005,S1,S2);
  L_LINE := ' <TR><TD>redo buffer allocation retries / redo blocks written</TD>'||
            '<TD ALIGN="right"'||S2||'>'||S1||'</TD><TD>should be less than '||
	    '0.01 - larger values indicate ';
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
  S2 := notify_gt(S1,WPH_NOLOG,'warn');
  L_LINE := ' <TR><TD>redo log space requests</TD><TD ALIGN="right"'||S2||'>'||
            S1||'</TD><TD>how often the log file was full and Oracle had to '||
	    'wait for a new file to become available</TD></TR>';
  print(L_LINE);
  SELECT value INTO I1 FROM v$sysstat WHERE name='table fetch continued row';
  S1 := to_char(I1,'999,999,990.99');
  SELECT value INTO I2 FROM v$sysstat WHERE name='table fetch by rowid';
  I3 := (I1/I2)*100;
  IF NVL(I3,0) > 10 THEN
    S2 := ' CLASS="alert"';
  ELSIF NVL(I3,0) > 5 THEN
    S2 := ' CLASS="warn"';
  ELSE
    S2 := '';
  END IF;
  L_LINE := ' <TR><TD>table fetch continued row</TD><TD ALIGN="right"'||S2||
            '>'||S1||'</TD><TD>How many <A HREF="JavaScript:popup('||
	    CHR(39)||'rowmigration'||CHR(39)||')">migrated rows</A> did we '||
	    'encounter during this instances life time?</TD></TR>';
  print(L_LINE);
  S1 := to_char(I3,'999,990.00');
  L_LINE := ' <TR><TD>Chained-Fetch-Ratio</TD><TD ALIGN="right"'||S2||'>'||S1||
            '%</TD><TD>Percentage of fetched "continued rows" per "rowid" fetch. '||
	    'If this value is very low, do not care about the previous value ;)</TD></TR>';
  print(L_LINE);
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

