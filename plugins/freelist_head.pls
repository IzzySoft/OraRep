
  FUNCTION have_flc RETURN BOOLEAN IS
    CI NUMBER; statement VARCHAR2(500);
    BEGIN
      statement := 'SELECT COUNT(table_name) FROM all_tables a, dba_tablespaces b'||
                   ' WHERE num_freelist_blocks IS NOT NULL'||
                   '   AND avg_space_freelist_blocks IS NOT NULL'||
	           '   AND avg_row_len >0'||
                   '   AND avg_space > (b.block_size*pct_free)/100'||
                   '   AND (b.block_size - avg_space) < (b.block_size*pct_used)/100'||
		   '   AND avg_row_len > avg_space - (b.block_size*pct_free)/100'||
                   '   AND a.tablespace_name=b.tablespace_name';
      EXECUTE IMMEDIATE statement INTO CI;
      IF CI > 0
      THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN RETURN FALSE;
    END;

  PROCEDURE freelist IS
    CURSOR C_Free IS
      SELECT owner,table_name,pct_free,pct_used,
             num_freelist_blocks freelists,
	     avg_space_freelist_blocks freespace,
	     TO_CHAR(avg_row_len,'999,990') rowlen,
	     b.block_size blocksize
        FROM all_tables a, dba_tablespaces b
       WHERE num_freelist_blocks IS NOT NULL
         AND avg_space_freelist_blocks IS NOT NULL
	 AND avg_row_len >0
         AND avg_space > (b.block_size*pct_free)/100
	 AND (b.block_size - avg_space) < (b.block_size*pct_used)/100
	 AND avg_row_len > avg_space - (b.block_size*pct_free)/100
         AND a.tablespace_name=b.tablespace_name
       ORDER BY avg_row_len DESC,avg_space_freelist_blocks DESC;

    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="8"><A NAME="freelist">FreeList Contention</A>'||
                '&nbsp;<A HREF="JavaScript:popup('||CHR(39)||
                'flc'||CHR(39)||')"><IMG SRC="help/help.gif" '||
		'BORDER="0" HEIGTH="12" VALIGN="middle" STYLE="margin-right:5"></A></TH></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">Owner</TH><TH CLASS="th_sub">'||
                'Table</TH><TH CLASS="th_sub">AvgRowLen</TH><TH CLASS="th_sub">';
      print(L_LINE);
      L_LINE := 'PctUsed</TH><TH CLASS="th_sub">PctFree</TH><TH CLASS="th_sub">'||
                'FreeLists</TH><TH CLASS="th_sub">AvgFreeSpace</TH>'||
		'<TH CLASS="th_sub">BlockSize</TH></TR>';
      print(L_LINE);
      S1 := 'x';
      FOR rec IN C_Free LOOP
        S1 := '';
        L_LINE := ' <TR'||S1||'><TD>'||rec.owner||'</TD><TD>'||rec.table_name||
                  '</TD><TD>'||rec.rowlen||'</TD><TD>'||rec.pct_used||
                  '</TD><TD ALIGN="right">'||rec.pct_free||'</TD><TD ALIGN="right">';
        print(L_LINE);
        L_LINE := rec.freelists||'</TD><TD ALIGN="right">'||format_fsize(rec.freespace)||
	          '</TD><TD ALIGN="right">'||format_fsize(rec.blocksize)||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      IF S1 = 'x' THEN
        print(' <TR><TD COLSPAN="8" ALIGN="center">No affected tables found.</TD></TR>');
      END IF;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        print(' <TR><TD COLSPAN="8" ALIGN="center">No affected tables found.</TD></TR>'||TABLE_CLOSE);
      WHEN OTHERS THEN
        L_LINE := ' <TR><TD COLSPAN="8" ALIGN="center">An error occured while '||
	          'processing the FreeList Contention:<BR>'||SQLERRM||'</TD></TR>'||
		  TABLE_CLOSE;
	print(L_LINE);
    END;

