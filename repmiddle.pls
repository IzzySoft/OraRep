
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
  L_LINE := '</TD><TD><A HREF="JavaScript:popup('||CHR(39)||'freebuffers'||CHR(39)||')">'||
            'This wait event</A> occurs when the database attemts to locate '||
	    'a clean block buffer but cannot ';
  print(L_LINE);
  L_LINE := 'because there are too many outstanding dirty blocks waiting to '||
            'be written.</TD></TR>';
  print(L_LINE);
  get_wait('buffer busy waits',S4,S1,S2,S3);
  L_LINE := ' <TR><TD><DIV STYLE="width:22ex">buffer busy waits</DIV></TD><TD ALIGN="right">'||S1||
            '</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||S4||'</TD>'||
	    '<TD ALIGN="right">'||S3;
  print(L_LINE);
  L_LINE := '</TD><TD><A HREF="JavaScript:popup('||CHR(39)||'busybuffers'||
            CHR(39)||')"><CODE>buffer busy waits</CODE></A> indicate';
  print(L_LINE);
  L_LINE := 'contention for a buffer in the SGA. You may need '||
            'to increase the <A HREF="JavaScript:popup('||
	    CHR(39)||'initrans'||CHR(39)||')"><CODE>INITRANS</CODE></A> parameter for a specific table ';
  print(L_LINE);
  L_LINE := 'or index if the event is identified as belonging to either a table '||
            'or index.</TD></TR>';
  print(L_LINE);
  get_wait('db file sequential read',S4,S1,S2,S3);
  L_LINE := ' <TR><TD>db file sequential read</TD><TD ALIGN="right">'||S1||
            '</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||S4||'</TD>'||
	    '<TD ALIGN="right">'||S3;
  print(L_LINE);
  L_LINE := '</TD><TD>Indicator for <A HREF="JavaScript:popup('||CHR(39)||
            'waitobj'||CHR(39)||')">I/O problems</A> on index accesses<BR>'||
            '<DIV CLASS="small">(Consider increasing the buffer cache when '||
            'value is high)</DIV></TD></TR>';
  print(L_LINE);
  get_wait('db file scattered read',S4,S1,S2,S3);
  L_LINE := ' <TR><TD>db file scattered read</TD><TD ALIGN="right">'||S1||
            '</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||S4||'</TD>'||
	    '<TD ALIGN="right">'||S3;
  print(L_LINE);
  L_LINE := '</TD><TD>Indicator for <A HREF="JavaScript:popup('||CHR(39)||
            'waitobj'||CHR(39)||')">I/O problems</A> on full table scans<BR>'||
            '<DIV CLASS="small">(On increasing <CODE STYLE="font-size:125%">';
  print(L_LINE);
  L_LINE := 'DB_FILE_MULTI_BLOCK_READ_COUNT</CODE> if this value '||
            'is high see the first block of Miscellaneous below)</DIV></TD></TR>';
  print(L_LINE);
  get_wait('undo segment extension',S4,S1,S2,S3);
  L_LINE := ' <TR><TD>undo segment extension</TD><TD ALIGN="right">'||S1||
            '</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||S4||'</TD>'||
	    '<TD ALIGN="right">'||S3;
  print(L_LINE);
  L_LINE := '</TD><TD>High wait times <A HREF="JavaScript:popup('||CHR(39)||
            'undoseg'||CHR(39)||')">here</A> could indicate a problem with the '||
	    'extent size, the value of MINEXTENTS, or possibly IO related '||
	    'problems.</TD></TR>';
  print(L_LINE);
  get_wait('enqueue',S4,S1,S2,S3);
  L_LINE := ' <TR><TD>enqueue</TD><TD ALIGN="right">'||S1||
            '</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||S4||'</TD>'||
	    '<TD ALIGN="right">'||S3;
  print(L_LINE);
  L_LINE := '</TD><TD><A HREF="JavaScript:popup('||CHR(39)||'enqueue'||CHR(39)||
            ')">This type</A> of event may be an indication that something is '||
            'either wrong with the code ';
  print(L_LINE);
  L_LINE := 'or possibly the physical design.</TD></TR>';
  print(L_LINE);
  get_wait('latch free',S4,S1,S2,S3);
  L_LINE := ' <TR><TD>latch free</TD><TD ALIGN="right">'||S1||
            '</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||S4||'</TD>'||
	    '<TD ALIGN="right">'||S3;
  print(L_LINE);
  L_LINE := '</TD><TD><A HREF="JavaScript:popup('||CHR(39)||'latchfree'||
            CHR(39)||')">Latch free</A> waits can occur for a variety of '||
	    'reasons including library cache issues, ';
  print(L_LINE);
  L_LINE := 'OS process intervention, and so on.</TD></TR>';
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
  S5 := notify_gt(S3,TPH_NOLOG,'warn');
  S6 := notify_gt(S1,WPH_NOLOG,'warn');
  L_LINE := ' <TR><TD>log file switch (checkpoint incomplete)</TD><TD ALIGN="right"'||
            S6||'>'||S1||'</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||
	    S4||'</TD>'||'<TD ALIGN="right"'||S5||'>'||S3||'</TD><TD ROWSPAN="2">';
  print(L_LINE);
  L_LINE := 'Higher values for one of <A HREF="JavaScript:popup('||CHR(39)||
            'logfileswitch'||CHR(39)||')">these events</A> indicate that '||
	    'either your ReDo logs are too small or there are not enough log '||
	    'file groups</TD></TR>';
  print(L_LINE);
  get_wait('log file switch (archiving needed)',S4,S1,S2,S3);
  S5 := notify_gt(S3,TPH_NOLOG,'warn');
  S6 := notify_gt(S1,WPH_NOLOG,'warn');
  L_LINE := ' <TR><TD>log file switch (archiving needed)</TD><TD ALIGN="right"'||
            S6||'>'||S1||'</TD><TD ALIGN="right">'||S2||'</TD><TD ALIGN="right">'||
	    S4||'</TD>'||'<TD ALIGN="right"'||S5||'>'||S3||'</TD></TR>';
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
  L_LINE := '</TD><TD><A HREF="JavaScript:popup('||CHR(39)||'logbufferspace'||
            CHR(39)||')">This event</A> frequently occurs when the log buffers are '||
            'filling faster than LGWR can write them to disk.';
  print(L_LINE);
  L_LINE := 'The two obvious solutions are to either increase the amount of '||
            'log buffers or to change your Redo log layout and/or IO strategy.</TD></TR>';
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
  L_LINE := '</TD><TD ROWSPAN="2">These wait events occur when the Database '||
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
