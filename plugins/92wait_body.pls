  -- Top N Wait Objects
  IF MK_WAITOBJ
  THEN
    L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="3"><A NAME="waitobj">Objects causing Wait Events</A>'||
              '&nbsp;<A HREF="JavaScript:popup('||CHR(39)||
              'waitobj'||CHR(39)||')"><IMG SRC="help/help.gif" '||
              'BORDER="0" HEIGTH="12" VALIGN="middle" STYLE="margin-right:5"></A></TH></TR>';
    print(L_LINE);
    L_LINE := ' <TR><TD COLSPAN="3">On the following segments we noticed one of '||
              'the events <CODE>buffer busy waits</CODE>, <CODE>db file sequential read'||
              '</CODE>, <CODE>db file scattered read</CODE>';
    print(L_LINE);
    L_LINE := 'or <CODE>free buffer waits</CODE> at the time the report was '||
              'generated.</TD></TR>';
    print(L_LINE);
    L_LINE := TABLE_CLOSE;
    print(L_LINE);
    P_92Waits('IO','physical%',TOP_N_WAITS);
    P_92Waits('BufferBusy','buffer busy%',TOP_N_WAITS);
    P_92Waits('RowLock','row lock%',TOP_N_WAITS);
    print('<HR>');
  END IF;

