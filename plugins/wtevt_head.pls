  PROCEDURE get_wait(eventname IN VARCHAR2, S04 OUT VARCHAR, S01 OUT VARCHAR2,
                     S02 OUT VARCHAR2, S03 OUT VARCHAR2) IS
    t1 NUMBER; t2 NUMBER;
    BEGIN
       SELECT TO_CHAR(total_waits,'9,999,999,990') totals,
              time_waited,
	      DECODE(NVL(total_waits,0),0,0,1000*time_waited/total_waits) average,
	      TO_CHAR(total_timeouts,'9,999,999,990') timeouts
	 INTO S01,t1,t2,S03
         FROM v$system_event WHERE event=eventname;
         S02 := format_stime(t1,1);
         S04 := format_stime(t2,1000);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
       S04 := '0.0'; S01 := '0'; S02 := '0'; S03 := '0';
    END;

