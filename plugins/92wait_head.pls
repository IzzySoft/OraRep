
  PROCEDURE P_92Waits (name IN VARCHAR2, statname IN VARCHAR2, maxcount IN NUMBER) IS
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

    BEGIN
     L_LINE := TABLE_OPEN;
     L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5"><A NAME="'||name||'">Top '||
               TOP_N_WAITS||' '||name||' Objects</A></TH></TR>';
     print(L_LINE);
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
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

