  -- Miscellaneous
  IF MK_TABSCAN OR MK_EXTNEED
  THEN
    L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="2"><A NAME="misc">Miscellaneous</A></TH></TR>'||CHR(10)||
              ' <TR><TH CLASS="th_sub">Name</TH><TH CLASS="th_sub">Value</TH></TR>';
    print(L_LINE);
    IF MK_TABSCAN
    THEN
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
    END IF;
    IF MK_EXTNEED
    THEN
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
    END IF;
    L_LINE := TABLE_CLOSE;
    print(L_LINE);
  END IF;

  -- Page Ending
  L_LINE := '<HR>'||CHR(10)||TABLE_OPEN;
  print(L_LINE);
  L_LINE := '<TR><TD><DIV CLASS="small">Created by OraRep v'||SCRIPTVER||' &copy; 2003-2004 by '||
	    '<A HREF="http://www.qumran.org/homes/izzy/" TARGET="_blank">Itzchak Rehberg</A> '||
            '&amp; <A HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft</A></DIV></TD></TR>';
  print(L_LINE);
  print(TABLE_CLOSE);
  L_LINE := '</BODY></HTML>'||CHR(10);
  print(L_LINE);

END;
/

SPOOL off
