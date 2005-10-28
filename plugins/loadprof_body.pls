  -- Load Profile
  IF :MK_LOADPROF = 1 THEN
    L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="3"><A NAME="loads">Load Profile</A></TH></TR>'||CHR(10)||
              ' <TR><TH CLASS="th_sub">&nbsp;</TH><TH CLASS="th_sub">Per Second</TH><TH CLASS="th_sub">Per Transaction</TH></TR>';
    print(L_LINE);
    loadprofile;
    print(TABLE_CLOSE);
    print('<HR>');
  END IF;

