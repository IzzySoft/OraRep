
  PROCEDURE tabscan IS
    CURSOR C_SCAN IS
      SELECT name,TO_CHAR(value,'9,999,999,990') value
        FROM v$sysstat
       WHERE name like '%table scans%';
    BEGIN
      L_LINE := ' <TR><TD COLSPAN="2" CLASS="td_name">If we have many full table '||
                'scans, we may have to optimize <CODE>DB_FILE_MULTI_BLOCK_READ_COUNT</CODE>. '||
                'Beneath the statistic below, we need the block count of the largest ';
      print(L_LINE);
      L_LINE := 'table to find the best value. A common recommendation is to set '||
                '<CODE>DB_FILE_MULTI_BLOCK_READ_COUNT</CODE> to the highest '||
                'possible value for maximum performance, which is 32 (256k) in ';
      print(L_LINE);
      L_LINE := 'most environments. The absolute maximum of 128 (1M) is '||
    	        'mostly only available on raw devices.</TD></TR>';
      print(L_LINE);
      FOR Rec_SCAN IN C_SCAN LOOP
        L_LINE := ' <TR><TD>'||Rec_SCAN.name||'</TD><TD ALIGN="right">'||
                  Rec_SCAN.value||'</TD></TR>';
        print(L_LINE);
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

  PROCEDURE extneed IS
    CURSOR C_EXT IS
      SELECT owner,table_name,freepct
        FROM ( SELECT owner,table_name,
                      to_char(100*empty_blocks/(blocks+empty_blocks),'990.00') freepct
                 FROM dba_tables
                WHERE 0.1>DECODE(SIGN(blocks+empty_blocks),1,empty_blocks/(blocks+empty_blocks),1)
                ORDER BY empty_blocks/(blocks+empty_blocks) )
       WHERE rownum <= TOP_N_TABLES;
    BEGIN
      L_LINE := ' <TR><TD COLSPAN="2" CLASS="td_name">If there are tables that '||
                'will for sure need more extents shortly, we can reduce I/O overhead '||
                'allocating some extents for them in advance, using ';
      print(L_LINE);
      L_LINE := '<CODE>"ALTER TABLE tablename ALLOCATE EXTENT"</CODE>. Here are '||
                'the max. Top '||TOP_N_TABLES||' candidates, having less than '||
                '10 percent free blocks left:</TD></TR>';
      print(L_LINE);
      FOR Rec_EXT IN C_EXT LOOP
        L_LINE := ' <TR><TD>'||Rec_EXT.owner||'.'||Rec_EXT.table_name||
                  '</TD><TD ALIGN="right">'||Rec_EXT.freepct||'%</TD></TR>';
        print(L_LINE);
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;
