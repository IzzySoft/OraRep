
  PROCEDURE memvals IS
    CURSOR C_MEM IS
      SELECT name,nvl(value,0) value FROM v$sga;
    CURSOR C_MEMPOOL IS
      SELECT name,DECODE(
              SIGN( LENGTH(value) - LENGTH(TRANSLATE(value,'0123456789GMKgmk','0123456789')) ),
              0,DECODE(SIGN(LENGTH(ROUND(value/1000))-1),
                0,to_char(nvl(value,0)/1024,'999,999,990.00')||' K',
                to_char(nvl(value,0)/1024/1024,'999,999,990.00')||' M'),
              1,value,'&nbsp;') value
        FROM v$parameter WHERE name LIKE '%pool%';

    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="2"><A NAME="memory">Memory Values</A></TH></TR>'||CHR(10)||
                ' <TR><TH CLASS="th_sub">Name</TH><TH CLASS="th_sub">Size</TH></TR>';
      print(L_LINE);
      FOR Rec_MEM IN C_MEM LOOP
        L_LINE := ' <TR><TD>'||Rec_MEM.name||'</TD><TD ALIGN="right">'||
                  format_fsize(Rec_MEM.value)||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      FOR Rec_MEMPOOL IN C_MEMPOOL LOOP
        L_LINE := ' <TR><TD>'||Rec_MEMPOOL.name||'</TD><TD ALIGN="right">'||
                  Rec_MEMPOOL.value||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

