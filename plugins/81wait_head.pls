
  FUNCTION have_waits RETURN BOOLEAN IS
    CI NUMBER;
    BEGIN
      SELECT COUNT(event) INTO CI FROM v$session_wait
       WHERE event IN ('buffer busy waits','free buffer waits',
                       'db file sequential read','db file scattered read');
      IF CI > 0
      THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN RETURN FALSE;
    END;

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

    BEGIN
     IF MK_WAITOBJ THEN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="3"><A NAME="waitobj">Objects causing Wait Events</A>'||
                '&nbsp;<A HREF="JavaScript:popup('||CHR(39)||
                'waitobj'||CHR(39)||')"><IMG SRC="help/help.gif" '||
		'BORDER="0" HEIGHT="16" ALIGN="top" ALT="Help" STYLE="margin-right:5"></A></TH></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TD COLSPAN="3">On the following segments we noticed one '||
                'of the events ';
      print(L_LINE);
      L_LINE := '<CODE>buffer busy waits</CODE>, <CODE>db file sequential read</CODE>, '||
                '<CODE>db file scattered read</CODE> or <CODE>free buffer waits</CODE> at '||
		'the time the report was generated.</TD></TR>';
      print(L_LINE);
      L_LINE := '<TR><TD COLSPAN="3">'||TABLE_OPEN||'<TR><TH CLASS="th_sub">'||
                'Owner</TH><TH CLASS="th_sub">Segment Name</TH>'||
		'<TH CLASS="th_sub">Segment Type</TH></TR>';
      print(L_LINE);
      FOR Rec_WAIT IN C_81Waits LOOP
        L_LINE := ' <TR><TD>'||Rec_WAIT.owner||'</TD><TD ALIGN="right">'||
                  Rec_WAIT.segment_name||'</TD><TD ALIGN="right">'||
                  Rec_WAIT.segment_type||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      L_LINE := '</TABLE></TD></TR>'||TABLE_CLOSE;
      print(L_LINE);
     END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        L_LINE := ' <TR><TD COLSPAN="3" ALIGN="center">Sorry - the objects have '||
	          'meanwhile been removed from <code>V$SESSION_WAIT</code></TD>'||
		  '</TR>';
        print(L_LINE);
	print('</TABLE></TD></TR>'||TABLE_CLOSE);
      WHEN OTHERS THEN
	print('</TABLE></TD></TR>'||TABLE_CLOSE);
	print('<BR>81wait: '||SQLERRM||'<BR>');
    END;

