
  PROCEDURE ts_quotas IS
    CURSOR C_Quot IS
      SELECT tablespace_name ts,username,
             TO_CHAR(bytes/1024/1024,'999,990')||' M' used,
	     DECODE(SIGN(max_bytes),-1,'Unlimited',
	            TO_CHAR(max_bytes/1024/1024,'999,990')||' M') avail
        FROM dba_ts_quotas
       ORDER BY tablespace_name,username;

    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="4"><A NAME="ts_quotas">TableSpace '||
                'Quotas</A></TH></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">TableSpace</TH><TH CLASS="th_sub">'||
                'User</TH><TH CLASS="th_sub">In Use</TH>'||
		'<TH CLASS="th_sub">Quota</TH></TR>';
      print(L_LINE);
      FOR rec IN C_Quot LOOP
        L_LINE := ' <TR><TD>'||rec.ts||'</TD><TD>'||rec.username||
	          '</TD><TD ALIGN="right">'||rec.used||'</TD><TD ALIGN="right">'||
                  rec.avail||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

