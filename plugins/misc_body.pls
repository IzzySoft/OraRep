  -- Miscellaneous
  L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="2"><A NAME="misc">Miscellaneous</A></TH></TR>'||CHR(10)||
            ' <TR><TH CLASS="th_sub">Name</TH><TH CLASS="th_sub">Value</TH></TR>';
  print(L_LINE);
  IF MK_TABSCAN THEN
    tabscan;
  END IF;
  IF MK_EXTNEED THEN
    extneed;
  END IF;
  print(TABLE_CLOSE||'<HR>');

