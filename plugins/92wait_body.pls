  -- Top N Wait Objects
  IF MK_WAITOBJ
  THEN
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
    L_LINE := TABLE_CLOSE;
    print(L_LINE);
    P_92Waits('IO','physical%',TOP_N_WAITS);
    P_92Waits('BufferBusy','buffer busy%',TOP_N_WAITS);
    P_92Waits('RowLock','row lock%',TOP_N_WAITS);
    print('<HR>');
  END IF;

