DECLARE
  CSS VARCHAR2(255);
  SCRIPTVER VARCHAR2(20);
  TOP_N_WAITS NUMBER;
  L_LINE VARCHAR(4000);
  R_TITLE VARCHAR(200);
  TABLE_OPEN VARCHAR(100); -- Table Attributes
  TABLE_CLOSE VARCHAR(100);
  S1 VARCHAR(200);
  S2 VARCHAR(200);
  S3 VARCHAR(200);
  S4 VARCHAR(200);
  S5 VARCHAR(200);
  I1 NUMBER;
  I2 NUMBER;
  I3 NUMBER;

  CURSOR C_USER IS
    SELECT username,account_status,NVL(to_char(lock_date,'DD.MM.YYYY'),'-')
           locked,NVL(to_char(expiry_date,'DD.MM.YYYY'),'-') expires,
           default_tablespace dts,temporary_tablespace tts,
           to_char(created,'DD.MM.YYYY') created
      FROM dba_users;
  CURSOR C_ADM IS
    SELECT grantee,admin_option FROM dba_role_privs WHERE granted_role='DBA';
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
  CURSOR C_RBS IS
    SELECT d.segment_name,d.status,to_char(r.rssize/1024,'99,999,999.00') rssize,
           to_char(nvl(r.optsize/1024,'0'),'99,999,999.00') optsize,
           to_char(r.hwmsize/1024,'99,999,999.00') hwmsize,r.xacts,
           to_char(r.waits,'9,999,990') waits,
	   to_char(r.shrinks,'9,999,990') shrinks,
	   to_char(r.wraps,'9,999,990') wraps,
	   to_char(r.aveshrink,'9,999,999,990') aveshrink,
	   to_char(r.aveactive,'9,999,999,990') aveactive
      FROM dba_rollback_segs d,v$rollstat r
     WHERE d.segment_id=r.usn
     ORDER BY d.segment_name;
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
  CURSOR C_MEM IS
    SELECT name,to_char(nvl(value,0)/1024,'999,999,990.00') value FROM v$sga;
  CURSOR C_MEMPOOL IS
    SELECT name,DECODE(
            SIGN( LENGTH(value) - LENGTH(TRANSLATE(value,'0123456789GMKgmk','0123456789')) ),
            0,to_char(nvl(value,0)/1024,'999,999,990.00')||' kB',1,value,'0 kB') value
      FROM v$parameter WHERE name LIKE '%pool%';
  CURSOR C_POOL IS
    SELECT pool,to_char(bytes/1024,'99,999,999.00') kbytes
      FROM v$sgastat WHERE name='free memory';
  CURSOR C_BUF IS
    SELECT name,
           to_char(physical_reads,'9,999,999,990') physical_reads,
	   to_char(consistent_gets,'9,999,999,990') consistent_gets,
	   to_char(db_block_gets,'9,999,999,990') db_block_gets,
           to_char(physical_reads/(consistent_gets+db_block_gets),'990.00') ratio
      FROM v$buffer_pool_statistics
     WHERE consistent_gets+db_block_gets>0;
  CURSOR C_SCAN IS
    SELECT name,TO_CHAR(value,'9,999,999,990') value
      FROM v$sysstat
     WHERE name like '%table scans%';
  CURSOR C_EXT IS
    SELECT owner,table_name,
           to_char(100*empty_blocks/(blocks+empty_blocks),'990.00') freepct
      FROM dba_tables
     WHERE 0.1>DECODE(SIGN(blocks+empty_blocks),1,empty_blocks/(blocks+empty_blocks),1);
  CURSOR C_INVOBJ IS
    SELECT owner,object_name,object_type,to_char(created,'dd.mm.yyyy hh:mi') created,
           to_char(last_ddl_time,'dd.mm.yyyy hh:mi') last_ddl_time
      FROM dba_objects
     WHERE status='INVALID'
     ORDER BY owner;
  CURSOR C_DBLinks IS
    SELECT owner,db_link,username,host,to_char(created,'DD.MM.YYYY') created
      FROM dba_db_links
     ORDER BY owner,db_link;

  PROCEDURE get_wait(eventname IN VARCHAR2, S04 OUT VARCHAR, S01 OUT VARCHAR2,
                     S02 OUT VARCHAR2, S03 OUT VARCHAR2) IS
    BEGIN
       SELECT TO_CHAR(total_waits,'9,999,999,990') totals,
              TO_CHAR(time_waited,'9,999,999,990') timew,
	      TO_CHAR(DECODE(NVL(total_waits,0),0,0,1000*time_waited/total_waits),
	              '9,999,990.0') average,
	      TO_CHAR(total_timeouts,'9,999,999,990') timeouts
	 INTO S01,S02,S04,S03
         FROM v$system_event WHERE event=eventname;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
       S04 := '0.0'; S01 := '0'; S02 := '0'; S03 := '0';
    END;

  PROCEDURE sysstat_per(aval IN VARCHAR2, bval IN VARCHAR2, rval OUT VARCHAR2) IS
    BEGIN
      SELECT value INTO I1 FROM v$sysstat WHERE name=aval;
      SELECT value INTO I2 FROM v$sysstat WHERE name=bval;
      IF NVL(I2,0) = 0
      THEN
        rval := '&nbsp;';
      ELSE
        rval := TO_CHAR(I1/I2,'999,999,990.99');
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN rval := '&nbsp;';
    END;

  PROCEDURE poolsize(aval IN VARCHAR2, rval OUT VARCHAR2) IS
    BEGIN
      SELECT DECODE(SIGN( LENGTH(value) - LENGTH(TRANSLATE(value,'0123456789GMKgmk','0123456789')) ),
             0,to_char(value/1024,'999,999,990.00')||' kB','&nbsp;')
        INTO rval
	FROM v$parameter
       WHERE name=aval;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN rval := '&nbsp;';
    END;

  PROCEDURE check_dblink(db_link IN VARCHAR2, rval OUT VARCHAR2) IS
    BEGIN
      ROLLBACK;
      S1 := 'SELECT ''>ACTIVE'' FROM DUAL@'||db_link;
      EXECUTE IMMEDIATE S1 INTO rval;
    EXCEPTION
      WHEN OTHERS THEN rval := ' CLASS="alert">INACTIVE';
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
             TO_CHAR(100*estd_physical_read_factor,'990.0') estrf,
             TO_CHAR(estd_physical_reads,'999,999,999,990') estread
        FROM v$db_cache_advice
       WHERE estd_physical_reads IS NOT NULL
         AND estd_physical_read_factor IS NOT NULL;
    BEGIN
      SELECT COUNT(name) INTO CI FROM v$db_cache_advice
       WHERE estd_physical_reads IS NOT NULL
         AND estd_physical_read_factor IS NOT NULL;
      IF CI > 0
      THEN
        L_LINE := TABLE_OPEN||' <TR><TH COLSPAN="5">DB Cache Advice</TH></TR>';
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
      END IF;
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;