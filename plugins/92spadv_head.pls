
 PROCEDURE sp_advice IS
  CURSOR csp IS
   SELECT TO_CHAR(shared_pool_size_for_estimate,'9,999,990') estsize,
          TO_CHAR((-1)*(100-(100*shared_pool_size_factor)),'9,990.0') size_factor,
          TO_CHAR(estd_lc_size,'9,990') lc_size,
          TO_CHAR(estd_lc_memory_objects,'9,999,990') lc_objects,
          TO_CHAR(estd_lc_time_saved,'999,999,990') time_saved,
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
   IF have_advice() THEN
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
       L_LINE := ' <TR><TD ALIGN="right">'||rec.estsize||' M</TD><TD ALIGN="right">'||
                 rec.size_factor||'%</TD><TD ALIGN="right">'||rec.lc_size||
                 '</TD><TD ALIGN="right">'||rec.lc_objects||'</TD>';
       print(L_LINE);
       L_LINE := '<TD ALIGN="right">'||rec.time_saved||'</TD><TD ALIGN="right">'||
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
    SELECT TO_CHAR(pga_target_for_estimate,'99,999,999,990') pga_size,
           TO_CHAR((-1)*(100-(100*pga_target_factor)),'9,990.0') size_factor,
           TO_CHAR(bytes_processed,'9,999,999,999,990') bytes,
	   TO_CHAR(estd_extra_bytes_rw,'999,999,999,990') extra_bytes,
	   TO_CHAR(estd_pga_cache_hit_percentage,'9,990.0') pct_hits,
	   TO_CHAR(estd_overalloc_count,'99,999') over
      FROM v$pga_target_advice;
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
   IF have_advice() THEN
     print(TABLE_OPEN||' <TR><TH COLSPAN="6">PGA Target Advice</TH></TR>');
     L_LINE := ' <TR><TD COLSPAN="6"><DIV ALIGN="center">The following values '||
               'are an estimation how changes to the PGA size would '||
               'affect the performance.</DIV></TD></TR>';
     print(L_LINE);
     L_LINE := ' <TR><TH CLASS="th_sub">Size</TH><TH CLASS="th_sub">SizeFactor'||
               '</TH><TH CLASS="th_sub">BytesProcessed</TH><TH CLASS="th_sub">'||
	       'XtraBytesRW</TH>';
     print(L_LINE);
     L_LINE := '<TH CLASS="th_sub">CacheHits</TH><TH CLASS="th_sub">OverAlloc</TH></TR>';
     print(L_LINE);
     FOR rec IN cpt LOOP
       L_LINE := ' <TR><TD ALIGN="right">'||rec.pga_size||'</TH><TD ALIGN="right">'||
                 rec.size_factor||'%</TD><TD ALIGN="right">'||rec.bytes||
		 '</TD><TD ALIGN="right">'||rec.extra_bytes;
       print(L_LINE);
       L_LINE := '</TD><TD ALIGN="right">'||rec.pct_hits||'%</TD><TD ALIGN="right">'||
                 rec.over||'</TD></TR>';
       print(L_LINE);
     END LOOP;
     print(TABLE_CLOSE);
   END IF;
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;
