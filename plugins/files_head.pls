
  PROCEDURE datafiles IS
    CURSOR C_FILE IS
      SELECT distinct t.name tablespace,d.name datafile,status,enabled,
             to_char(d.bytes/1024,'99,999,999.00') kbytes,
             to_char(free.bytes/1024,'99,999,999.00') freekbytes,
             to_char(100*(1-(free.bytes/d.bytes)),'990.00') usedpct,
	     to_char(phyrds,'9,999,999,990') phyrds,
             to_char(phywrts,'9,999,999,990') phywrts,
	     to_char(avgiotim,'9,999,999,990') avgiotim
        FROM v$filestat,v$datafile d,v$tablespace t,dba_free_space f,
             (SELECT file_id,SUM(bytes) bytes FROM dba_free_space GROUP BY file_id) free
       WHERE v$filestat.file#=d.file# AND d.ts#=t.ts# AND f.file_id=d.file# AND free.file_id=d.file#
       UNION
      SELECT distinct t.name tablespace,d.name datafile,status,enabled,
             to_char(d.bytes/1024,'99,999,999.00') kbytes,
             to_char(free.bytes/1024,'99,999,999.00') freekbytes,
             to_char(100*(1-(free.bytes/d.bytes)),'990.00') usedpct,
	     to_char(phyrds,'9,999,999,990') phyrds,
             to_char(phywrts,'9,999,999,990') phywrts,
	     to_char(avgiotim,'9,999,999,990') avgiotim
        FROM v$filestat,v$tempfile d,v$tablespace t,dba_free_space f,
             (SELECT file_id,SUM(bytes) bytes FROM dba_free_space GROUP BY file_id) free
       WHERE v$filestat.file#=d.file# AND d.ts#=t.ts# AND f.file_id=d.file# AND free.file_id=d.file#;

    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="10"><A NAME="datafiles">Data Files</A></TH></TR>'||CHR(10)||
                ' <TR><TH CLASS="th_sub">Tablespace</TH><TH CLASS="th_sub">'||
                'Datafile</TH><TH CLASS="th_sub">Status</TH><TH CLASS="th_sub">';
      print(L_LINE);
      L_LINE := 'Enabled</TH><TH CLASS="th_sub">Size (kB)</TH><TH CLASS="th_sub">'||
                'Free (kB)</TH><TH CLASS="th_sub">Used (%)</TH><TH CLASS="th_sub">'||
                'Phys.Reads</TH><TH CLASS="th_sub">Phys.Writes</TH>';
      print(L_LINE);
      L_LINE := '<TH CLASS="th_sub">Avg.I/O Time</TH></TR>';
      print(L_LINE);
      FOR Rec_FILE IN C_FILE LOOP
        L_LINE := ' <TR><TD>'||Rec_FILE.tablespace||'</TD><TD>'||Rec_FILE.datafile||
                  '</TD><TD>'||Rec_FILE.status||'</TD><TD>'||Rec_FILE.enabled||
                  '</TD><TD ALIGN="right">'||Rec_FILE.kbytes||'</TD><TD ALIGN="right">'||
                  Rec_FILE.freekbytes;
        print(L_LINE);
        L_LINE := '</TD><TD ALIGN="right">'||Rec_FILE.usedpct||'</TD><TD ALIGN="right">'||
                  Rec_FILE.phyrds||'</TD><TD ALIGN="right">'||Rec_FILE.phywrts||
                  '</TD><TD ALIGN="right">'||Rec_FILE.avgiotim||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;
