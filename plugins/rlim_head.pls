  -- Resource Limits
  PROCEDURE rlims IS
    limit VARCHAR2(20);
    inita VARCHAR2(20);
    CURSOR cr IS
     SELECT resource_name rname,
            current_utilization curu,
            max_utilization maxu,
            decode(trim(initial_allocation),'UNLIMITED','9999999999',initial_allocation) inita,
            decode(trim(limit_value),'UNLIMITED','9999999999',limit_value) lim
       FROM v$resource_limit
      ORDER BY rname;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5"><A NAME="resourcelimits">Resource Limits</A></TH></TR>'||
                ' <TR><TD COLSPAN="5" ALIGN="center">"Current" is the time of the End SnapShot</TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">Resource</TH><TH CLASS="th_sub">Curr Utilization</TH>'||
	        '<TH CLASS="th_sub">Max Utilization</TH><TH CLASS="th_sub">'||
	        'Init Allocation</TH><TH CLASS="th_sub">Limit</TH></TR>';
      print(L_LINE);
      FOR R_RLim in cr LOOP
        IF R_RLIM.lim = '9999999999' THEN
          limit := 'UNLIMITED';
        ELSE
          limit := numformat(R_RLim.lim);
        END IF;
        IF R_RLIM.inita = '9999999999' THEN
          inita := 'UNLIMITED';
        ELSE
          inita := numformat(R_RLim.inita);
        END IF;
        S1 := alert_gt_warn(R_RLim.curu,R_RLim.lim*:AR_RLIM/100,R_RLim.lim*:WR_RLIM/100);
        S2 := alert_gt_warn(R_RLim.maxu,R_RLim.lim*:AR_RLIM/100,R_RLim.lim*:WR_RLIM/100);
        L_LINE := ' <TR><TD CLASS="td_name">'||R_RLim.rname||'</TD><TD ALIGN="right"'||S1||'>'||
                  numformat(R_RLim.curu)||'</TD><TD ALIGN="right"'||S2||'>'||
                  numformat(R_RLim.maxu)||'</TD><TD ALIGN="right">'||
                  inita||'</TD><TD ALIGN="right">'||limit||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE||'<HR>');
    EXCEPTION
      WHEN OTHERS THEN print(TABLE_CLOSE||SQLERRM||'<HR>');
    END;