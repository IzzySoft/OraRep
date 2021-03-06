
  PROCEDURE pool IS
    CURSOR C_LIB IS
      SELECT namespace,
             to_char(gets,'9,999,999,990') gets,
	     to_char(pins,'9,999,999,990') pins,
	     to_char(reloads,'9,999,999,990') reloads,
             to_char(gethitratio*100,'990.00') ratio,
	     to_char(DECODE(NVL(pins,0),0,0,100*reloads/pins),'990.00') rratio
        FROM v$librarycache;
    CURSOR C_ROW IS
      SELECT parameter,
             to_char(gets,'9,999,999,990') gets,
	     to_char(getmisses,'9,999,999,990') getmisses,
	     to_char((getmisses/gets)*100,'990.00') ratio
        FROM v$rowcache WHERE gets>0;
    CURSOR C_POOL IS
      SELECT pool,bytes
        FROM v$sgastat WHERE name='free memory';
    CURSOR C_BUF IS
      SELECT name,
             to_char(physical_reads,'9,999,999,990') physical_reads,
	     to_char(consistent_gets,'9,999,999,990') consistent_gets,
	     to_char(db_block_gets,'9,999,999,990') db_block_gets,
             physical_reads/(consistent_gets+db_block_gets) numratio,
             to_char(physical_reads/(consistent_gets+db_block_gets),'990.00') ratio
        FROM v$buffer_pool_statistics
       WHERE consistent_gets+db_block_gets>0;

    PROCEDURE poolsize(aval IN VARCHAR2, rval OUT VARCHAR2) IS
      BEGIN
        SELECT DECODE(SIGN( LENGTH(value) - LENGTH(TRANSLATE(value,'0123456789GMKgmk','0123456789')) ),
              0,DECODE(SIGN(LENGTH(ROUND(value/1000))-1),
                0,to_char(nvl(value,0)/1024,'999,999,990.00')||' K',
                to_char(nvl(value,0)/1024/1024,'999,999,990.00')||' M'),
              1,value,'&nbsp;')
          INTO rval
	  FROM v$parameter
         WHERE name=aval;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN rval := '&nbsp;';
      END;

    BEGIN
    -- Pool Sizes
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="2"><A NAME="poolsize">Pool Sizes</A></TH></TR>'||CHR(10)||
                ' <TR><TH CLASS="th_sub">Pool</TH><TH CLASS="th_sub">Space</TH></TR>';
      print(L_LINE);
      poolsize('shared_pool_size',S1);
      L_LINE := ' <TR><TD>Shared_Pool_Size</TD><TD ALIGN="right">'||S1||'</TD></TR>'||CHR(10);
      poolsize('shared_pool_reserved_size',S1);
      L_LINE := L_LINE||' <TR><TD>Shared_Pool_Reserved_Size</TD><TD ALIGN="right">'||S1||'</TD></TR>'||CHR(10);
      poolsize('large_pool_size',S1);
      L_LINE := L_LINE||' <TR><TD>Large_Pool_Size</TD><TD ALIGN="right">'||S1||'</TD></TR>'||CHR(10);
      print(L_LINE);
      poolsize('java_pool_size',S1);
      L_LINE := ' <TR><TD>Java_Pool_Size</TD><TD ALIGN="right">'||S1||'</TD></TR>'||CHR(10);
      poolsize('sort_area_size',S1);
      L_LINE := L_LINE||' <TR><TD>Sort_Area_Size</TD><TD ALIGN="right">'||S1||'</TD></TR>'||CHR(10);
      poolsize('sort_area_retained_size',S1);
      L_LINE := L_LINE||' <TR><TD>Sort_Area_Retained_Size</TD><TD ALIGN="right">'||S1||'</TD></TR>'||CHR(10);
      print(L_LINE);

      L_LINE := ' <TR><TH CLASS="th_sub">Pool</TH><TH CLASS="th_sub">Free Space</TH></TR>';
      print(L_LINE);
      FOR Rec_POOL IN C_POOL LOOP
        L_LINE := ' <TR><TD>'||Rec_POOL.pool||'</TD><TD ALIGN="right">'||
                  format_fsize(Rec_POOL.bytes)||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);

    -- Shared Pool Information
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="6"><A NAME="sharedpool">Shared Pool Information</A></TH></TR>'||CHR(10)||
                ' <TR><TH COLSPAN="6" CLASS="th_sub">Library Cache</TH></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TD COLSPAN="6">The following cases are indicators '||
                'that <CODE>SHARED_POOL_SIZE</CODE> may have to be increased:';
      print(L_LINE);
      L_LINE := ' <BR><UL><LI>RPP (100*reloads/pins) &gt; 1</LI><LI>gethitratio &lt; 90%</LI></UL></TD></TR>'||
                ' <TR><TD CLASS="td_name">NameSpace</TD><TD CLASS="td_name">Gets</TD>';
      print(L_LINE);
      L_LINE := ' <TD CLASS="td_name">Pins</TD><TD CLASS="td_name">Reloads</TD>'||
                '<TD CLASS="td_name">RPP</TD>'||
                '<TD CLASS="td_name">GetHitRatio</TD></TR>';
      print(L_LINE);
      FOR Rec_LIB IN C_LIB LOOP
        L_LINE := ' <TR><TD>'||Rec_LIB.namespace||'</TD><TD ALIGN="right">'||
                  Rec_LIB.gets||'</TD>'||'<TD ALIGN="right">'||Rec_LIB.pins||
                  '</TD><TD ALIGN="right">'||Rec_LIB.reloads||
                  '</TD><TD ALIGN="right">'||Rec_LIB.rratio||
	          '</TD><TD ALIGN="right">'||Rec_LIB.ratio||'%</TD></TR>';
        print(L_LINE);
      END LOOP;

      L_LINE := ' <TR><TD COLSPAN="6">'||CHR(38)||'nbsp;</TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH COLSPAN="6" CLASS="th_sub">Row Cache</TH></TR>'||
                ' <TR><TD COLSPAN="6">If Ratio = (getmisses/gets)*100 > 15,'||
                ' <CODE>SHARED_POOL_SIZE</CODE> may have to be increased:</TD></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TD COLSPAN="3" CLASS="td_name">Parameter</TD><TD CLASS="td_name">Gets</TD>'||
                '<TD CLASS="td_name">GetMisses</TD><TD CLASS="td_name">Ratio</TD></TR>';
      print(L_LINE);
      FOR Rec_ROW IN C_ROW LOOP
        L_LINE := ' <TR><TD COLSPAN="3">'||Rec_ROW.parameter||'</TD><TD ALIGN="right">'||
                  Rec_ROW.gets||'</TD><TD ALIGN="right">'||Rec_ROW.getmisses||
                  '</TD><TD ALIGN="right">'||Rec_ROW.ratio||'%</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);

    -- Buffer Pool Statistics
      IF MK_BUFFP THEN
        L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5"><A NAME="bufferpool">Buffer Pool Statistics</A></TH></TR>';
        print(L_LINE);
        L_LINE := ' <TR><TD COLSPAN="5">Ratio = physical_reads/(consistent_gets+db_block_gets)'||
                  ' should be &lt; 0.9:';
        print(L_LINE);
        L_LINE := ' <TR><TH CLASS="th_sub">Pool</TH><TH CLASS="th_sub">'||
                  'physical_reads</TH><TH CLASS="th_sub">consistent_gets</TH>'||
                  '<TH CLASS="th_sub">db_block_gets</TH><TH CLASS="th_sub">Ratio</TH></TR>';
        print(L_LINE);
        FOR Rec_BUF IN C_BUF LOOP
	  IF Rec_BUF.numratio > AR_BUFF THEN
	    S1 := ' CLASS="alert"';
	  ELSIF Rec_BUF.numratio > WR_BUFF THEN
	    S1 := ' CLASS="warn"';
	  ELSE
	    S1 := '';
	  END IF;
          L_LINE := ' <TR><TD>'||Rec_BUF.name||'</TD><TD ALIGN="right">'||
                    Rec_BUF.physical_reads||'</TD><TD ALIGN="right">'||
                    Rec_BUF.consistent_gets||'</TD><TD ALIGN="right">'||
                    Rec_BUF.db_block_gets||'</TD><TD ALIGN="right"'||S1||'>'||
                    Rec_BUF.ratio||'</TD></TR>';
          print(L_LINE);
        END LOOP;
        print(TABLE_CLOSE);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

