DECLARE
  CSS VARCHAR2(255);
  SCRIPTVER VARCHAR2(20);
  TOP_N_WAITS NUMBER;
  TOP_N_TABLES NUMBER;
  L_LINE VARCHAR(4000);
  R_TITLE VARCHAR(200);
  TABLE_OPEN VARCHAR(100); -- Table Attributes
  TABLE_CLOSE VARCHAR(100);
  MK_USER NUMBER;
  MK_DBLINK NUMBER;
  DBLINK_EXIST BOOLEAN;
  MK_WAITOBJ BOOLEAN;
  MK_INVALIDS BOOLEAN;
  MK_TABSCAN BOOLEAN;
  MK_EXTNEED BOOLEAN;
  MK_BUFFP BOOLEAN;
  MK_ADVICE BOOLEAN;
  MK_ENQS BOOLEAN;
  MK_RSRC NUMBER;
  MK_DBAPROF NUMBER;
  MK_TSQUOT NUMBER;
  MK_FILES NUMBER;
  MK_RBS NUMBER;
  MK_MEMVAL NUMBER;
  MK_POOL NUMBER;
  MK_BUFFRAT NUMBER;
  MK_SYSSTAT NUMBER;
  MK_WTEVT NUMBER;
  MK_FLC NUMBER;
  MK_ENQ NUMBER;
  MK_INVOBJ NUMBER;
  TPH_NOLOG NUMBER;
  WPH_NOLOG NUMBER;
  WR_BUFF NUMBER;
  AR_BUFF NUMBER;
  WR_FILEUSED NUMBER;
  AR_FILEUSED NUMBER;
  UTH NUMBER;
  S1 VARCHAR(200);
  S2 VARCHAR(500);
  S3 VARCHAR(200);
  S4 VARCHAR(200);
  S5 VARCHAR(200);
  S6 VARCHAR(200);
  I1 NUMBER;
  I2 NUMBER;
  I3 NUMBER;

  CURSOR C_SCAN IS
    SELECT name,TO_CHAR(value,'9,999,999,990') value
      FROM v$sysstat
     WHERE name like '%table scans%';
  CURSOR C_EXT IS
    SELECT owner,table_name,freepct
      FROM ( SELECT owner,table_name,
                    to_char(100*empty_blocks/(blocks+empty_blocks),'990.00') freepct
               FROM dba_tables
              WHERE 0.1>DECODE(SIGN(blocks+empty_blocks),1,empty_blocks/(blocks+empty_blocks),1)
              ORDER BY empty_blocks/(blocks+empty_blocks) )
     WHERE rownum <= TOP_N_TABLES;

  PROCEDURE sysstat_per(aval IN VARCHAR2, bval IN VARCHAR2, alert IN NUMBER, warn IN NUMBER, rval OUT VARCHAR2, tdclass OUT VARCHAR2) IS
    BEGIN
      SELECT value INTO I1 FROM v$sysstat WHERE name=aval;
      SELECT value INTO I2 FROM v$sysstat WHERE name=bval;
      IF NVL(I2,0) = 0
      THEN
        tdclass := '';
	rval := '&nbsp;';
      ELSE
        I3 := I1/I2;
        rval := TO_CHAR(I3,'999,999,990.99');
	IF I3 > NVL(alert,0) THEN
	  tdclass := ' CLASS="alert';
	ELSIF I3 > NVL(warn,0) THEN
	  tdclass := ' CLASS="warn"';
	ELSE
	  tdclass := '';
	END IF;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN rval := '&nbsp;';
    END;

  PROCEDURE print(line IN VARCHAR2) IS
    BEGIN
      dbms_output.put_line(line);
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('*!* Problem in print() *!*');
    END;

  PROCEDURE get_dbc_advice IS
    CI NUMBER;
    CURSOR C_A IS
      SELECT name,
             TO_CHAR(size_for_estimate,'999,990') estsize,
             TO_CHAR(buffers_for_estimate,'999,999,990') estbuff,
             TO_CHAR((-1)*(100-(100*estd_physical_read_factor)),'9,990.0') estrf,
             TO_CHAR(estd_physical_reads,'999,999,999,990') estread
        FROM v$db_cache_advice
       WHERE estd_physical_reads IS NOT NULL
         AND estd_physical_read_factor IS NOT NULL;
    BEGIN
      L_LINE := TABLE_OPEN||' <TR><TH COLSPAN="5"><A NAME="advices">DB Cache Advice</A></TH></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TD COLSPAN="5"><DIV ALIGN="justify">The following values '||
                'are an estimation how changing the size of a given buffer would '||
                'affect the amount of physical reads.</DIV></TD>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">Pool</TH><TH CLASS="th_sub">Size</TH>'||
                '<TH CLASS="th_sub">Buffers</TH><TH CLASS="th_sub">Estd.PhyRd '||
	        'Factor</TH><TH CLASS="th_sub">Estd.PhyRds</TH></TR>';
      print(L_LINE);
      FOR rec IN C_A LOOP
        L_LINE := ' <TR><TD CLASS="td_name">'||rec.name||'</TD><TD ALIGN="right">'||
                  rec.estsize||' M</TD><TD ALIGN="right">'||rec.estbuff||'</TD>';
        print(L_LINE);
        L_LINE := '<TD ALIGN="right">'||rec.estrf||'%</TD><TD ALIGN="right">'||
                  rec.estread||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

  FUNCTION have_xxx (tablename IN VARCHAR2,field IN VARCHAR2, condition IN VARCHAR2) RETURN BOOLEAN IS
    CI NUMBER; statement VARCHAR2(500);
    BEGIN
      statement := 'SELECT COUNT('||field||') FROM '||tablename||
                   ' WHERE '||condition;
      EXECUTE IMMEDIATE statement INTO CI;
      IF CI > 0
      THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN RETURN FALSE;
    END;

  FUNCTION have_invalids RETURN BOOLEAN IS
    BEGIN
      RETURN have_xxx ('dba_objects','owner','status=''INVALID''');
    END;

  FUNCTION have_tablescans RETURN BOOLEAN IS
    BEGIN
      RETURN have_xxx ('v$sysstat','name','name LIKE ''%table scans%''');
    END;

  FUNCTION have_extentneed RETURN BOOLEAN IS
    BEGIN
      RETURN have_xxx ('dba_tables','owner','0.1>DECODE(SIGN(blocks+empty_blocks),1,empty_blocks/(blocks+empty_blocks),1)');
    END;

  FUNCTION have_buffp_stats RETURN BOOLEAN IS
    BEGIN
      RETURN have_xxx('v$buffer_pool_statistics','name','consistent_gets+db_block_gets>0');
    END;

  FUNCTION have_advice RETURN BOOLEAN IS
    BEGIN
      RETURN have_xxx('v$db_cache_advice','name','estd_physical_reads IS NOT NULL AND estd_physical_read_factor IS NOT NULL');
    END;

  FUNCTION have_dblinks RETURN BOOLEAN IS
    BEGIN
      RETURN have_xxx ('dba_db_links','db_link','1=1');
    END;

  FUNCTION have_quotas RETURN BOOLEAN IS
    CI NUMBER;
    BEGIN
      RETURN have_xxx('dba_ts_quotas','*','1=1');
    END;

  FUNCTION str_gt(str IN VARCHAR2, num IN NUMBER) RETURN BOOLEAN IS
    BEGIN
      RETURN NVL(TO_NUMBER(str,'999,999,999,999,999.99'),0)/UTH > num;
    EXCEPTION
      WHEN OTHERS THEN RETURN FALSE;
    END;

  FUNCTION notify_gt(str IN VARCHAR2, num IN NUMBER, level IN STRING) RETURN VARCHAR2 IS
    BEGIN
      IF str_gt(str,num) THEN
        RETURN ' CLASS="'||level||'"';
      ELSE
        RETURN '';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN RETURN '';
    END;

