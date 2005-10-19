
 PROCEDURE sp_advice IS
  CURSOR csp IS
   SELECT shared_pool_size_for_estimate*1024*1024 estsize,
          TO_CHAR((-1)*(100-(100*shared_pool_size_factor)),'9,990.0') size_factor,
          estd_lc_size*1024*1024 lc_size,
          TO_CHAR(estd_lc_memory_objects,'9,999,990') lc_objects,
          estd_lc_time_saved time_saved,
          TO_CHAR((-1)*(100-(100*estd_lc_time_saved_factor)),'9,990.0') time_factor,
          TO_CHAR(estd_lc_memory_object_hits,'999,999,999,990') object_hits
     FROM v$shared_pool_advice;
  FUNCTION have_advice RETURN BOOLEAN IS
    LS NUMBER; LO NUMBER; LT NUMBER; OH NUMBER;
    BEGIN
      SELECT COUNT(DISTINCT estd_lc_size),COUNT(DISTINCT estd_lc_memory_objects),
             COUNT(DISTINCT estd_lc_time_saved),
             COUNT(DISTINCT estd_lc_memory_object_hits)
        INTO LS,LO,LT,OH FROM v$shared_pool_advice;
      IF LS > 1 OR LO > 1 OR LT > 1 OR OH > 1 THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN RETURN FALSE;
    END;
  BEGIN
   IF have_spadvice() THEN
     print(TABLE_OPEN||' <TR><TH COLSPAN="7">Shared Pool Advice</TH></TR>');
     L_LINE := ' <TR><TD COLSPAN="7"><DIV ALIGN="center">The following values '||
               'are an estimation how changes to the shared pool size would '||
               'affect the Library Cache (LC).</DIV></TD></TR>';
     print(L_LINE);
     L_LINE := ' <TR><TH CLASS="th_sub">Size</TH><TH CLASS="th_sub">SizeFactor'||
               '</TH><TH CLASS="th_sub">LC Size</TH><TH CLASS="th_sub">Objects'||
               '</TH><TH CLASS="th_sub">LC Time Saved</TH>';
     print(L_LINE);
     L_LINE := '<TH CLASS="th_sub">TimeFactor</TH><TH CLASS="th_sub">'||
               'Object Hits</TH></TR>';
     print(L_LINE);
     FOR rec IN csp LOOP
       L_LINE := ' <TR><TD ALIGN="right">'||format_fsize(rec.estsize)||'</TD><TD ALIGN="right">'||
                 rec.size_factor||'%</TD><TD ALIGN="right">'||format_fsize(rec.lc_size)||
                 '</TD><TD ALIGN="right">'||rec.lc_objects||'</TD>';
       print(L_LINE);
       L_LINE := '<TD ALIGN="right">'||format_stime(rec.time_saved,1)||'</TD><TD ALIGN="right">'||
                 rec.time_factor||'%</TD><TD ALIGN="right">'||rec.object_hits||
                 '</TD></TR>';
       print(L_LINE);
     END LOOP;
     print(TABLE_CLOSE);
   END IF;
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;

 PROCEDURE pt_advice IS
  CURSOR cpt IS
    SELECT pga_target_for_estimate pga_size,
           TO_CHAR((-1)*(100-(100*pga_target_factor)),'9,990.0') size_factor,
           bytes_processed bytes,
	   estd_extra_bytes_rw extra_bytes,
	   TO_CHAR(estd_pga_cache_hit_percentage,'9,990.0') pct_hits,
	   TO_CHAR(estd_overalloc_count,'999,999,999') over
      FROM v$pga_target_advice;
  CURSOR warea IS
    SELECT name,value
      FROM v$sysstat
     WHERE name LIKE 'workarea executions%';
  FUNCTION have_advice RETURN BOOLEAN IS
    LS NUMBER; LO NUMBER; LT NUMBER; OH NUMBER;
    BEGIN
      SELECT COUNT(DISTINCT estd_extra_bytes_rw),
             COUNT(DISTINCT estd_pga_cache_hit_percentage),
             COUNT(DISTINCT estd_overalloc_count)
        INTO LS,LO,LT FROM v$pga_target_advice;
      IF LS > 1 OR LO > 1 OR LT > 1 THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN RETURN FALSE;
    END;
  BEGIN
   IF have_ptadvice() THEN
     print(TABLE_OPEN||' <TR><TH COLSPAN="6">PGA Target Advice</TH></TR>');
     L_LINE := ' <TR><TD COLSPAN="6"><DIV ALIGN="center">The following values '||
               'are an estimation how changes to the PGA size would '||
               'affect the performance.<BR>';
     print(L_LINE);
     L_LINE := 'A nonzero value for <I>OverAlloc</I> means that <I>Size</I> for '||
               '<CODE>PGA_TARGET_FOR_ESTIMATE</CODE> is not large enough to run '||
               'the work area workload.</DIV></TD></TR>';
     print(L_LINE);
     L_LINE := ' <TR><TH CLASS="th_sub">Size</TH><TH CLASS="th_sub">SizeFactor'||
               '</TH><TH CLASS="th_sub">BytesProcessed</TH><TH CLASS="th_sub">'||
	       'XtraBytesRW</TH>';
     print(L_LINE);
     L_LINE := '<TH CLASS="th_sub">CacheHits</TH><TH CLASS="th_sub">OverAlloc</TH></TR>';
     print(L_LINE);
     FOR rec IN cpt LOOP
       L_LINE := ' <TR><TD ALIGN="right">'||format_fsize(rec.pga_size)||
                 '</TD><TD ALIGN="right">'||rec.size_factor||
                 '%</TD><TD ALIGN="right">'||format_fsize(rec.bytes)||
		 '</TD><TD ALIGN="right">'||format_fsize(rec.extra_bytes);
       print(L_LINE);
       L_LINE := '</TD><TD ALIGN="right">'||rec.pct_hits||'%</TD><TD ALIGN="right">'||
                 rec.over||'</TD></TR>';
       print(L_LINE);
     END LOOP;
     print(TABLE_CLOSE);
     print(TABLE_OPEN||' <TR><TH COLSPAN="2">PGA Workarea Usage</TH></TR>');
     L_LINE := ' <TR><TD COLSPAN="2"><DIV ALIGN="center">Target is, if possible, to have only '||
               'optimal executions (i.e. process everything in memory) or at least eliminate '||
               'the multipass executions.<BR>Crosscheck with the PGA Target Advices above '||
               '(especially to minimize OverAlloc).</DIV></TD></TR>';
     print(L_LINE);
     print(' <TR><TH CLASS="th_sub">Statistic</TH><TH CLASS="th_sub">Value</TH></TR>');
     FOR wa IN warea LOOP
       print('  <TD>'||wa.name||'</TD><TD ALIGN="right">'||numformat(wa.value)||'</TD></TR>');
     END LOOP;
     print(TABLE_CLOSE);
   END IF;
  EXCEPTION
    WHEN OTHERS THEN print(TABLE_CLOSE);
  END;
