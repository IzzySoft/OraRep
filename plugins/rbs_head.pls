
  -- recommend more rollback segments?
  PROCEDURE more_rbs IS
    GETS NUMBER; TABOPEN NUMBER; WPG NUMBER;
    CURSOR cr (N_GETS NUMBER) IS
     SELECT class, "COUNT" numcount, TO_CHAR("COUNT"/N_GETS,'990.00') pct
       FROM v$waitstat
      WHERE class IN ('system undo header','system undo block','undo header','undo block')
        AND "COUNT" > N_GETS/100;
    BEGIN
      TABOPEN := 0;
      SELECT sum(value) INTO GETS FROM v$sysstat
       WHERE name IN ('db block gets','consistent gets');
      FOR rec IN cr(GETS) LOOP
        IF TABOPEN = 0 THEN
          TABOPEN := 1;
          L_LINE := TABLE_OPEN||' <TR><TH COLSPAN="3">You may need more rollback segments:</TH></TR>'||
                    CHR(10)||' <TR><TD COLSPAN="3"><DIV ALIGN="center">Wait counts should not exceed '||
                    '1% of logical reads - but we found:</DIV></TD></TR>';
          print(L_LINE);
          L_LINE := ' <TR><TH CLASS="th_sub">Class</TH><TH CLASS="th_sub">'||
                    'Count</TH><TH CLASS="th_sub">% of log.Reads</TH></TR>';
          print(L_LINE);
        END IF;
        L_LINE := ' <TR><TD CLASS="td_name">'||rec.class||'</TD><TD>'||
                  rec.numcount||'</TD><TD><DIV ALIGN="right">'||rec.pct||
                  '</TD></TR>';
        print(L_LINE);
      END LOOP;
      SELECT 100*(SUM(waits)/SUM(gets)) INTO WPG
        FROM v$rollstat;
      IF WPG > 1 THEN
        IF TABOPEN = 0 THEN
          TABOPEN := 1;
          L_LINE := TABLE_OPEN||' <TR><TH COLSPAN="3">You may need more rollback segments:</TH></TR>';
          print(L_LINE);
        END IF;
        L_LINE := ' <TR><TD COLSPAN="3"><DIV ALIGN="center">The number of waits per request for '||
                  'data should not exceed 1%, but it is actually '||
                  TO_CHAR(WPG,'990.00')||'%</DIV></TD></TR>';
        print(L_LINE);
      END IF;
      print('</TABLE>');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

  -- General Rollback Stats
  PROCEDURE rbsstats IS
    CURSOR C_RBS IS
      SELECT d.segment_name,d.status,to_char(r.rssize/1024,'99,999,990.00') rssize,
             to_char(nvl(r.optsize/1024,'0'),'99,999,990.00') optsize,
             to_char(r.hwmsize/1024,'99,999,990.00') hwmsize,r.xacts,
             to_char(r.waits,'9,999,990') waits,
	     to_char(r.shrinks,'9,999,990') shrinks,
	     to_char(r.wraps,'9,999,990') wraps,
	     to_char(r.aveshrink,'9,999,999,990') aveshrink,
	     to_char(r.aveactive,'9,999,999,990') aveactive
        FROM dba_rollback_segs d,v$rollstat r
       WHERE d.segment_id=r.usn
       ORDER BY d.segment_name;

    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="11"><A NAME="rbs">Rollback Segments</A>'||
                '&nbsp;<A HREF="JavaScript:popup('||CHR(39)||'rollstat'||CHR(39)||
	        ')"><IMG SRC="help/help.gif" BORDER="0" HEIGTH="12" '||
	        'VALIGN="middle"></A></TH></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">Segment</TH><TH CLASS="th_sub">Status</TH>'||
                '<TH CLASS="th_sub">Size (kB)</TH><TH CLASS="th_sub">OptSize (kB)</TH>';
      print(L_LINE);
      L_LINE := '<TH CLASS="th_sub">HWMSize (kB)</TH><TH CLASS="th_sub">Waits</TH>'||
                '<TH CLASS="th_sub">XActs</TH><TH CLASS="th_sub">Shrinks</TH>'||
                '<TH CLASS="th_sub">Wraps</TH><TH CLASS="th_sub">AveShrink</TH>';
      print(L_LINE);
      L_LINE := '<TH CLASS="th_sub">AveActive</TH></TR>';
      print(L_LINE);
      FOR Rec_RBS IN C_RBS LOOP
        L_LINE := ' <TR><TD>'||Rec_RBS.segment_name||'</TD><TD>'||Rec_RBS.status||
                  '</TD><TD ALIGN="right">'||Rec_RBS.rssize||'</TD><TD ALIGN="right">'||
                  Rec_RBS.optsize||'</TD><TD ALIGN="right">'||Rec_RBS.hwmsize||
                  '</TD><TD ALIGN="right">'||Rec_RBS.waits;
        print(L_LINE);
        L_LINE := '</TD><TD ALIGN="right">'||Rec_RBS.xacts||'</TD><TD ALIGN="right">'||
                  Rec_RBS.shrinks||'</TD><TD ALIGN="right">'||Rec_RBS.wraps||
                  '</TD><TD ALIGN="right">'||Rec_RBS.aveshrink||'</TD><TD ALIGN="right">'||
                  Rec_RBS.aveactive||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
      more_rbs;
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

