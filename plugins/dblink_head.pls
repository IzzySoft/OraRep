
  PROCEDURE dblinks IS
    CURSOR C_DBLinks IS
      SELECT owner,db_link,username,host,to_char(created,'DD.MM.YYYY') created
        FROM dba_db_links
       ORDER BY owner,db_link;
    PROCEDURE check_dblink(db_link IN VARCHAR2, rval OUT VARCHAR2) IS
      BEGIN
        ROLLBACK;
        S1 := 'SELECT ''>ACTIVE'' FROM DUAL@'||db_link;
        EXECUTE IMMEDIATE S1 INTO rval;
      EXCEPTION
        WHEN OTHERS THEN rval := ' CLASS="alert">INACTIVE';
      END;
    BEGIN
      IF DBLINK_EXIST THEN
        L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="6"><A NAME="dblink">DB Links</A></TH></TR>'||CHR(10)||
                  ' <TR><TH CLASS="th_sub">Owner</TH><TH CLASS="th_sub">DB Link</TH>';
        print(L_LINE);
        L_LINE := '<TH CLASS="th_sub">Username</TH><TH CLASS="th_sub">Host</TH>'||
                  '<TH CLASS="th_sub">Created</TH><TH CLASS="th_sub">Status</TH></TR>';
        print(L_LINE);
        FOR R_Link IN C_DBLinks LOOP
          check_dblink(R_Link.db_link,S1);
          L_LINE := ' <TR><TD>'||R_Link.owner||'</TD><TD>'||R_Link.db_link||
                    '</TD><TD>'||R_Link.username||'</TD><TD>'||R_Link.host||
 	            '</TD><TD>';
          print(L_LINE);
          L_LINE := R_Link.created||'</TD><TD ALIGN="center"'||S1||'</TD></TR>';
          print(L_LINE);
        END LOOP;
        print(TABLE_CLOSE||'<HR>');
      END IF;
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;
