  PROCEDURE tabs IS
    pcomment VARCHAR2(2000);

    PROCEDURE tabscan IS
      CURSOR C_SCAN IS
        SELECT name,TO_CHAR(value,'9,999,999,990') value
          FROM v$sysstat
         WHERE name like '%table scans%';
      BEGIN
        L_LINE := ' <TR><TD COLSPAN="3" CLASS="td_name">If we have many full table '||
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
                    Rec_SCAN.value||'</TD><TD>&nbsp;</TD></TR>';
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
        L_LINE := ' <TR><TD COLSPAN="3" CLASS="td_name">If there are tables that '||
                  'will for sure need more extents shortly, we can reduce I/O overhead '||
                  'allocating some extents for them in advance, using ';
        print(L_LINE);
        L_LINE := '<CODE>"ALTER TABLE tablename ALLOCATE EXTENT"</CODE>. Here are '||
                  'the max. Top '||TOP_N_TABLES||' candidates, having less than '||
                  '10 percent free blocks left:</TD></TR>';
        print(L_LINE);
        FOR Rec_EXT IN C_EXT LOOP
          L_LINE := ' <TR><TD>'||Rec_EXT.owner||'.'||Rec_EXT.table_name||
                    '</TD><TD ALIGN="right">'||Rec_EXT.freepct||'%</TD><TD>&nbsp;</TD></TR>';
          print(L_LINE);
        END LOOP;
      EXCEPTION
        WHEN OTHERS THEN NULL;
      END;

    PROCEDURE writerow(val1 IN VARCHAR2, val2 IN VARCHAR2, val3 IN VARCHAR2) IS
      BEGIN
        L_LINE := ' <TR><TD CLASS="td_name" STYLE="width:21em">'||val1||'</TD>'||
                  '<TD ALIGN="right" NOWRAP>'||val2||'</TD><TD ALIGN="justify">'||val3||'</TD></TR>';
        print(L_LINE);
      EXCEPTION
        WHEN OTHERS THEN NULL;
      END;

    PROCEDURE write(first IN VARCHAR2, last IN VARCHAR2, scomment IN VARCHAR2) IS
      erg VARCHAR2(20);
      BEGIN
        erg := decformat(dbstats(first,last));
        L_LINE := ' <TR><TD STYLE="width:22em">'||first||' / '||last||'</TD><TD ALIGN="right">'||
                  erg||'</TD><TD ALIGN="justify">'||scomment||'</TD></TR>';
        print(L_LINE);
      EXCEPTION
        WHEN OTHERS THEN NULL;
      END;

    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="3"><A NAME="tabs"></A>Table Statistics</TH></TR>'||
                ' <TR><TH CLASS="th_sub">Statistic</TH><TH CLASS="th_sub">Value</TH>'||
                '<TH CLASS="th_sub">Comment</TH></TR>';
      print(L_LINE);
      pcomment := 'This ratio (blocks scanned per scanned row) should get close to 0 with '||
                  'acceptable table scan blocks gotten if you are not using LONG objects '||
                  'frequently. If it is high, you probably should:<UL>'||
                  '<LI>Check missing index(es) on statements doing Full Table Scan(FTS).</LI>'||
                  '<LI>If Statements have to do FTS, reorganize tables used in FTS to reset '||
                  'High Water Mark(HWM). Because, in FTS, Oracle scans table from bottom of '||
                  'table to top of table(HWM) even if there are just a few rows in table. This '||
                  'makes problems on frequently inserted/deleted tables since <code>INSERT</code> '||
                  'increases HWM, but <code>DELETE</code> does not decrease HWM. After '||
                  'reorganization, the number of scanned blocks will be reduced.</LI></UL>';
      write('table scan blocks gotten','table scan rows gotten',pcomment);
      pcomment := 'The chained-fetch-ratio indicates the average chained/migrated rows in '||
                  'multiple blocks, which are accessed by a single ROWID. This ratio should be '||
                  'as low as possible to access a row in a single block. If it is high,<UL>'||
                  '<LI>find the chained/migrated rows</LI>'||
                  '<LI>increase <code>PCTFREE</code>, decrease <code>PCTUSED</code> storage '||
                  'parameters of tables which have many chained/migrated rows frequently used</LI>'||
                  '<LI>reorganize these tables (e.g. <code>ALTER TABLE..MOVE</code>, or '||
                  '<code>EXP</code> / <code>IMP</code>)</LI></UL>';
      write('table fetch continued row','table fetch by rowid',pcomment);
      IF MK_TABSCAN THEN
        tabscan;
      END IF;
      IF MK_EXTNEED THEN
        extneed;
      END IF;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN print(TABLE_CLOSE||SQLERRM||'<br>'||I3||' ('||S3||')');
    END;

