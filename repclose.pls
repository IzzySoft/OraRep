  -- Invalid Objects
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5"><A NAME="invobj">Invalid Objects</A></TH></TR>'||CHR(10)||
            ' <TR><TD COLSPAN="5">The following objects may need your investigation. These are not';
  print(L_LINE);
  L_LINE := ' necessarily problem indicators (e.g. an invalid view may automatically re-compile), but could be:</TH></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TH CLASS="th_sub">Owner</TH><TH CLASS="th_sub">Object</TH><TH CLASS="th_sub">Typ</TH>'||
            '<TH CLASS="th_sub">Created</TH><TH CLASS="th_sub">Last DDL</TH></TR>';
  print(L_LINE);
  FOR Rec_INVOBJ IN C_INVOBJ LOOP
    L_LINE := ' <TR><TD>'||Rec_INVOBJ.owner||'</TD><TD>'||Rec_INVOBJ.object_name||
              '</TD><TD>'||Rec_INVOBJ.object_type||'</TD><TD>'||Rec_INVOBJ.created||
	      '</TD><TD>'||Rec_INVOBJ.last_ddl_time||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);
  print('<HR>');

  -- Miscellaneous
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="2"><A NAME="misc">Miscellaneous</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Name</TH><TH CLASS="th_sub">Value</TH></TR>';
  print(L_LINE);
  L_LINE := ' <TR><TD COLSPAN="2" CLASS="td_name">If we have many full table '||
            'scans, we may have to optimize <I>DB_FILE_MULTI_BLOCK_READ_COUNT</I>. '||
            'Beneath the statistic below, we need the block count of the largest '||
            'table to find the best value. ';
  print(L_LINE);
  L_LINE := 'A common recommendation is to set <I>DB_FILE_MULTI_BLOCK_READ_COUNT</I> '||
            'to the highest possible value for maximum performance, which is '||
	    '32 (256k) in most environments. The absolute maximum of 128 (1M) is '||
	    'mostly only available on raw devices.</TD></TR>';
  print(L_LINE);
  FOR Rec_SCAN IN C_SCAN LOOP
    L_LINE := ' <TR><TD>'||Rec_SCAN.name||'</TD><TD ALIGN="right">'||
              Rec_SCAN.value||'</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := ' <TR><TD COLSPAN="2" CLASS="td_name">If there are tables that '||
            'will for sure need more extents shortly, we can reduce I/O overhead '||
            'allocating some extents for them in advance, using ';
  print(L_LINE);
  L_LINE := '"ALTER TABLE tablename ALLOCATE EXTENT". Here are some '||
            'candidates, having less than 10 percent free blocks left:</TD></TR>';
  print(L_LINE);
  FOR Rec_EXT IN C_EXT LOOP
    L_LINE := ' <TR><TD>'||Rec_EXT.owner||'.'||Rec_EXT.table_name||
              '</TD><TD ALIGN="right">'||Rec_EXT.freepct||'%</TD></TR>';
    print(L_LINE);
  END LOOP;
  L_LINE := TABLE_CLOSE;
  print(L_LINE);

  -- Page Ending
  L_LINE := '<HR>'||CHR(10)||TABLE_OPEN;
  print(L_LINE);
  L_LINE := '<TR><TD><DIV CLASS="small">Created by OraRep v'||SCRIPTVER||' &copy; 2003 by '||
	    '<A HREF="http://www.qumran.org/homes/izzy/" TARGET="_blank">Itzchak Rehberg</A> '||
            '&amp; <A HREF="http://www.izzysoft.de" TARGET="_blank">IzzySoft</A></DIV></TD></TR>';
  print(L_LINE);
  print(TABLE_CLOSE);
  L_LINE := '</BODY></HTML>'||CHR(10);
  print(L_LINE);

END;
/

SPOOL off
