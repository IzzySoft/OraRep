
  FUNCTION have_enqs RETURN BOOLEAN IS
--    CI NUMBER;
    BEGIN
      RETURN have_xxx('v$enqueue_stat','eq_type','cum_wait_time > 0');
--      SELECT COUNT(event) INTO CI FROM v$session_wait
--       WHERE event IN ('buffer busy waits','free buffer waits',
--                       'db file sequential read','db file scattered read');
--      IF CI > 0
--      THEN
--        RETURN TRUE;
--      ELSE
--        RETURN FALSE;
--      END IF;
    EXCEPTION
      WHEN OTHERS THEN RETURN FALSE;
    END;

  PROCEDURE P_90enqs IS
    CURSOR C_90enqs IS
      SELECT eq_type etype,
             TO_CHAR(total_req#,'999,999,999,990') totreq,
	     TO_CHAR(total_wait#,'999,999,990') totwait,
	     TO_CHAR(succ_req#,'999,999,999,990') succreq,
	     TO_CHAR(failed_req#,'999,999,999,990') failreq,
	     TO_CHAR(cum_wait_time,'999,999,999,990') cumwait
        FROM v$enqueue_stat
       WHERE cum_wait_time >0
       ORDER BY cum_wait_time DESC;

--    PROCEDURE print(line IN VARCHAR2) IS
--      BEGIN
--        dbms_output.put_line(line);
--      EXCEPTION
--        WHEN OTHERS THEN
--          dbms_output.put_line('*!* Problem in print() *!*');
--      END;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="6"><A NAME="waitobj">Enqueue Waits</A></TH></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TD COLSPAN="6"><DIV ALIGN="center">The following queues '||
                'caused waits during the recent uptime of this instance.<BR>'||
		'Ordered by cumulative wait time (desc)';
      print(L_LINE);
      L_LINE := '<TABLE BORDER="0"><TR><TD CLASS="smallname">CF</TD><TD '||
                'CLASS="small"><B>Control file schema global enqueue</TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TD CLASS="smallname">CU</TD><TD CLASS="small"><B>Cursor '||
                'Bind</B></TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TD CLASS="smallname">DX</TD><TD CLASS="small"><B>'||
                'Distributed Transactions</B></TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TD CLASS="smallname">HW</TD><TD CLASS="small"><B>'||
                'Space Management</B> operations on a specific segment'||
		'</TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TD CLASS="smallname">SQ</TD><TD CLASS="small"><B>'||
                'SeQuences</B> not being cached, having a to small cache size '||
		'or being aged out of the shared pool. ';
      print(L_LINE);
      L_LINE := 'Consider pinning sequences or increasing the '||
                'shared_pool_size.</TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TD CLASS="smallname">ST</TD><TD CLASS="small"><B>'||
                'Space management locks</B> could be caused by using permanent '||
		'tablespaces for sorting (rather than temporary), or ';
      print(L_LINE);
      L_LINE := 'by dynamic allocation resulting from inadequate storage clauses. '||
                'In the latter case, using locally-managed tablespaces may help '||
		'avoiding this problem.</TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TD CLASS="smallname">TM</TD><TD CLASS="small"><B>'||
                'Table locks</B> point to the possibility of e.g. foreign key '||
		'constraints not being indexed</TD></TR>';
      print(L_LINE);
      L_LINE := ' <TD CLASS="smallname">TX</TD><TD CLASS="small"><B>'||
                'Transaction locks</B> indicate multiple users try modifying '||
		'the same row of a table (row-level-lock)</TD></TR></TABLE></DIV></TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">Queue</TH><TH CLASS="th_sub">'||
                'Total Requests</TH><TH CLASS="th_sub">Total Waits</TH>'||
		'<TH CLASS="th_sub">Succ.Requests</TH>';
      print(L_LINE);
      L_LINE := '<TH CLASS="th_sub">Failed Req.</TH><TH CLASS="th_sub">'||
		'Cum.WaitTime</TH></TR>';
      print(L_LINE);
      FOR rec IN C_90enqs LOOP
        L_LINE := ' <TR><TD>'||rec.etype||'</TD><TD ALIGN="right">'||
                  rec.totreq||'</TD><TD ALIGN="right">'||rec.totwait||
		  '</TD><TD ALIGN="right">'||rec.succreq;
        print(L_LINE);
	L_LINE := '</TD><TD ALIGN="right">'||rec.failreq||'</TD><TD ALIGN="right">'||
                  rec.cumwait||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      L_LINE := TABLE_CLOSE;
      print(L_LINE);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

