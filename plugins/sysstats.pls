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
