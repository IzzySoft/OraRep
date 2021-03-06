
  FUNCTION have_waits RETURN BOOLEAN IS
    CI NUMBER;
    BEGIN
      SELECT COUNT(value) INTO CI FROM v$segment_statistics
       WHERE owner NOT IN ('SYS','SYSTEM')
         AND value > 0
         AND ( statistic_name LIKE 'physical%'
               OR statistic_name LIKE 'buffer busy%'
               OR statistic_name LIKE 'row lock%' );
      IF CI > 0
      THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN RETURN FALSE;
    END;

  PROCEDURE P_92Waits (name IN VARCHAR2, statname IN VARCHAR2, maxcount IN NUMBER) IS
    HelpLink VARCHAR2(255);
    CURSOR C_92Waits (statsname IN VARCHAR2) IS
      SELECT owner,object_name,object_type,tablespace_name,statistic_name,
             TO_CHAR(value,'99,999,999,990') value
        FROM ( SELECT owner,object_name,object_type,tablespace_name,statistic_name,value
                 FROM v$segment_statistics
	        WHERE statistic_name LIKE statsname
	          AND owner NOT IN ('SYS','SYSTEM')
	  	  AND value > 0
	        ORDER BY value DESC )
       WHERE rownum <= maxcount;

    PROCEDURE print(line IN VARCHAR2) IS
      BEGIN
        dbms_output.put_line(line);
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line('*!* Problem in print() *!*');
      END;

    FUNCTION have_swaits (statsname IN VARCHAR2) RETURN BOOLEAN IS
      CI NUMBER;
      BEGIN
        SELECT COUNT(value) INTO CI FROM v$segment_statistics
         WHERE owner NOT IN ('SYS','SYSTEM')
           AND value > 0
           AND statistic_name LIKE statsname;
        IF CI > 0
        THEN
          RETURN TRUE;
        ELSE
          RETURN FALSE;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN RETURN FALSE;
      END;

    BEGIN
     IF have_swaits(statname) THEN
      IF name = 'BufferBusy' THEN
        HelpLink := '<A HREF="JavaScript:popup('||CHR(39)||'busybuffers'||
                    CHR(39)||')"><IMG SRC="help/help.gif" BORDER="0" HEIGHT="16" '||
                    'ALIGN="top" ALT="Help" STYLE="margin-right:5"></A>';
      ELSIF name = 'IO' THEN
        HelpLink := '<A HREF="JavaScript:popup('||CHR(39)||'waitobj'||
                    CHR(39)||')"><IMG SRC="help/help.gif" BORDER="0" HEIGHT="16" '||
                    'ALIGN="top" ALT="Help" STYLE="margin-right:5"></A>';
      ELSIF name = 'RowLock' THEN
        HelpLink := '<A HREF="JavaScript:popup('||CHR(39)||'rowlocks'||
                    CHR(39)||')"><IMG SRC="help/help.gif" BORDER="0" HEIGHT="16" '||
                    'ALIGN="top" ALT="Help" STYLE="margin-right:5"></A>';
      ELSE
        HelpLink := '';
      END IF;
      L_LINE := TABLE_OPEN;
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5"><A NAME="'||name||'">Top '||
                TOP_N_WAITS||' '||name||' Objects</A>';
      print(L_LINE);
      print(HelpLink||'</TH></TR>');
      L_LINE := ' <TR><TH CLASS="th_sub">Object</TH><TH CLASS="th_sub">'||
                'Type</TH><TH CLASS="th_sub">TableSpace</TH>'||
                '<TH CLASS="th_sub">Wait Type</TH><TH CLASS="th_sub">Waits</TH></TR>';
      print(L_LINE);
      FOR Rec_W IN C_92Waits(statname) LOOP
        L_LINE := ' <TR><TD CLASS="td_name">'||Rec_W.owner||'.'||Rec_W.object_name||
                  '</TD><TD>'||Rec_W.object_type||'</TD><TD>'||
 		  Rec_W.tablespace_name||'</TD><TD>'||
                  Rec_W.statistic_name||'</TD><TD ALIGN="right">'||
                  Rec_W.value||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      L_LINE := TABLE_CLOSE;
      print(L_LINE);
     END IF;
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

