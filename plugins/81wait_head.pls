
  PROCEDURE P_81Waits IS
    CURSOR C_81Waits IS
      SELECT owner,segment_name,segment_type
        FROM (SELECT p1 file#,p2 block#
                FROM v$session_wait
  	       WHERE event IN ('buffer busy waits','db file sequential read',
	                       'db file scattered read','free buffer waits')) b,
	     dba_extents a
       WHERE a.file_id=b.file#
         AND b.block# BETWEEN a.block_id AND (a.block_id+blocks-1);

    PROCEDURE print(line IN VARCHAR2) IS
      BEGIN
        dbms_output.put_line(line);
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line('*!* Problem in print() *!*');
      END;
    BEGIN
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
      FOR Rec_WAIT IN C_81Waits LOOP
        L_LINE := ' <TR><TD>'||Rec_WAIT.owner||'</TD><TD ALIGN="right">'||
                  Rec_WAIT.segment_name||'</TD><TD ALIGN="right">'||
                  Rec_WAIT.segment_type||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      L_LINE := TABLE_CLOSE;
      print(L_LINE);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

