  FUNCTION dbstat(first IN VARCHAR2) RETURN NUMBER IS
    erg NUMBER;
    BEGIN
      SELECT value INTO erg
        FROM v$sysstat
         WHERE name=first;
      RETURN erg;
    EXCEPTION
      WHEN OTHERS THEN RETURN 0;
    END;

  FUNCTION dbstats(first IN VARCHAR2, last IN VARCHAR2) RETURN NUMBER IS
    erg NUMBER;
    BEGIN
      SELECT ( a.value / b.value ) INTO erg
        FROM v$sysstat a, v$sysstat b
         WHERE a.name=first
           AND b.name=last
           AND b.value > 0;
      RETURN erg;
    EXCEPTION
      WHEN OTHERS THEN RETURN 0;
    END;

  FUNCTION parameter(name IN VARCHAR2) RETURN VARCHAR2 IS
    wert VARCHAR2(200);
    BEGIN
      EXECUTE IMMEDIATE 'SELECT value FROM v$parameter WHERE name='''||name||'''' INTO wert;
      RETURN wert;
    EXCEPTION
      WHEN OTHERS THEN wert := ''; RETURN wert;
    END;

  PROCEDURE eventstat(eventname IN VARCHAR2, average OUT NUMBER, totals OUT NUMBER,
                     waittime OUT NUMBER, timeouts OUT NUMBER) IS
    BEGIN
       SELECT total_waits,
              time_waited,
	      DECODE(NVL(total_waits,0),0,0,1000*time_waited/total_waits),
	      total_timeouts
	 INTO totals,waittime,average,timeouts
         FROM v$system_event
        WHERE event=eventname;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
       average := 0; totals := 0; waittime := 0; timeouts := 0;
    END;

  PROCEDURE get_wait(eventname IN VARCHAR2, avgwait OUT VARCHAR2, total_waits OUT VARCHAR2,
                     time_waited OUT VARCHAR2, total_timeouts OUT VARCHAR2) IS
    average NUMBER; totals NUMBER; waittime NUMBER; timeouts NUMBER;
    BEGIN
      eventstat(eventname,average,totals,waittime,timeouts);
      total_waits    := numformat(totals);
      time_waited    := format_stime(waittime,1);
      total_timeouts := numformat(timeouts);
      avgwait        := format_stime(average,1000);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

