
  PROCEDURE ts_quotas IS
    CURSOR C_Quot IS
      SELECT q.tablespace_name ts,username,
             bytes used,
	     DECODE(SIGN(max_bytes),-1,'Unlimited',
	            TO_CHAR(max_bytes/1024/1024,'999,990')||' M') avail,
	     DECODE (t.status,NULL,' CLASS="warn"','') dropped
        FROM dba_ts_quotas q,dba_tablespaces t
       WHERE t.tablespace_name(+)=q.tablespace_name
         AND username IS NOT NULL
       ORDER BY ts,username;

    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="4"><A NAME="ts_quotas">TableSpace '||
                'Quotas</A></TH></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TD COLSPAN="4" ALIGN="center">Highlighted rows mark '||
                'tablespaces that do not exist. If (re-)created, these quotas '||
		'would be (re-)established</TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">TableSpace</TH><TH CLASS="th_sub">'||
                'User</TH><TH CLASS="th_sub">In Use</TH>'||
		'<TH CLASS="th_sub">Quota</TH></TR>';
      print(L_LINE);
      FOR rec IN C_Quot LOOP
        L_LINE := ' <TR'||rec.dropped||'><TD>'||rec.ts||'</TD><TD>'||rec.username||
	          '</TD><TD ALIGN="right">'||format_fsize(rec.used)||
                  '</TD><TD ALIGN="right">'||rec.avail||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN print(TABLE_CLOSE);
    END;

