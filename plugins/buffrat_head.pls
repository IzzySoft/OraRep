
  PROCEDURE bufferratio IS
    CURSOR C_Busy IS
      SELECT class,
             TO_CHAR(time,'999,999,999,990') time,
	     TO_CHAR(count,'999,999,999,990') count,
             TO_CHAR(DECODE(time,0,0,(count/time)*100),'999,999,990.00') ratio
        FROM v$waitstat
       WHERE count > 0
       GROUP BY class,time,count
       ORDER BY count DESC,ratio DESC;
    CURSOR C_Free IS
      SELECT TO_CHAR((a.total_waits/b.total_waits),'990.00') ratio
        FROM v$system_event a,v$system_event b
       WHERE a.event='free buffer request'
         AND b.event='free buffer waits';

    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="4"><A NAME="buffwait">Buffer Wait Ratios</A></TH></TR>'||CHR(10)||
                ' <TR><TH CLASS="th_sub">Class/Name</TH><TH CLASS="th_sub">Count</TH>';
      print(L_LINE);
      L_LINE := '<TH CLASS="th_sub">Time</TH><TH CLASS="th_sub">Ratio</TH></TR>';
      print(L_LINE);
      print(' <TR><TH CLASS="th_sub2" COLSPAN="4">Buffer Busy Waits</TH></TR>');
      FOR rec IN C_Busy LOOP
        L_LINE := ' <TR><TD>'||rec.class||'</TD><TD ALIGN="right">'||rec.count||'</TD>'||
	          '<TD ALIGN="right">'||rec.time||'</TD><TD ALIGN="right">'||
		  rec.ratio||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      FOR rec IN C_Free LOOP
        print(' <TR><TH CLASS="th_sub2" COLSPAN="4">Free Buffer Waits</TH></TR>');
        L_LINE := ' <TR><TD>Requests/Waits</TD><TD COLSPAN="2">'||CHR(38)||'nbsp;</TD>'||
	          '<TD ALIGN="right">'||rec.ratio||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN print(TABLE_CLOSE);
    END;

