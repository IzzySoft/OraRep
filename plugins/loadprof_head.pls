-- Load Profile

Procedure loadprofile IS
 TRAN NUMBER;
 ELA NUMBER;
 PROCEDURE writeline (statval IN NUMBER, descript IN VARCHAR2) IS
  BEGIN
    L_LINE := ' <TR><TD CLASS="td_name">'||descript||'</TD><TD ALIGN="right">'||
            decformat(statval/ELA)||
            '</TD><TD ALIGN="right">'||
	    decformat(statval/TRAN)||'</TD></TR>';
    print(L_LINE);
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;
 PROCEDURE singlestat(statname IN VARCHAR2, descript IN VARCHAR2) IS
  BEGIN
    I1 := dbstat(statname);
    writeline(I1,descript);
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;
 PROCEDURE addstat(stat1 IN VARCHAR2, stat2 IN VARCHAR2, descript IN VARCHAR2) IS
  BEGIN
    NULL;
    I1 := dbstat(stat1) + dbstat(stat2);
    writeline(I1,descript);
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;
 
 BEGIN
   TRAN := dbstat('user rollbacks') + dbstat('user commits');
   SELECT (SYSDATE - startup_time)*1440*60 INTO ELA FROM v$instance;
   singlestat('redo size','Redo Size');
   singlestat('session logical reads','Logical Reads');
   singlestat('db block changes','Block Changes');
   singlestat('physical reads','Physical Reads');
   singlestat('physical writes','Physical Writes');
   singlestat('user calls','User Calls');
   singlestat('parse count (total)','Parses');
   singlestat('parse count (hard)','Hard Parses');
   addstat('sorts (memory)','sorts (disk)','Sorts');
   singlestat('logons cumulative','Logons');
   singlestat('execute count','Executes');
   writeline(TRAN,'Transactions');
 EXCEPTION
   WHEN OTHERS THEN NULL;
 END;