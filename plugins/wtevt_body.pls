  -- Selected Events
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="6"><A NAME="events">Selected Wait Events (from v'||CHR(36)||'system_event)</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Name</TH><TH CLASS="th_sub">Totals</TH>';
  print(L_LINE);
  L_LINE := '<TH CLASS="th_sub">Total WaitTime</TH><TH CLASS="th_sub">Avg Waited</TH>'||
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
  L_LINE := '<CODE>log buffer space</CODE>, <CODE>log file switch (archiving '||
            'needed)</CODE>, etc.</TD></TR>';
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

