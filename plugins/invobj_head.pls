
  PROCEDURE invobj IS
    CURSOR C_INVOBJ IS
      SELECT owner,object_name,object_type,to_char(created,'dd.mm.yyyy hh:mi') created,
             to_char(last_ddl_time,'dd.mm.yyyy hh:mi') last_ddl_time
        FROM dba_objects
       WHERE status='INVALID'
       ORDER BY owner;
    BEGIN
      IF MK_INVALIDS THEN
        L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="5"><A NAME="invobj">Invalid Objects</A></TH></TR>'||CHR(10)||
                  ' <TR><TD COLSPAN="5">The following objects may need your investigation. These are not';
        print(L_LINE);
        print(' necessarily problem indicators (e.g. an invalid view may automatically re-compile), but could be:</TH></TR>');
        L_LINE := ' <TR><TH CLASS="th_sub">Owner</TH><TH CLASS="th_sub">Object</TH><TH CLASS="th_sub">Type</TH>'||
                  '<TH CLASS="th_sub">Created</TH><TH CLASS="th_sub">Last DDL</TH></TR>';
        print(L_LINE);
        FOR Rec_INVOBJ IN C_INVOBJ LOOP
          L_LINE := ' <TR><TD>'||Rec_INVOBJ.owner||'</TD><TD>'||Rec_INVOBJ.object_name||
                    '</TD><TD>'||Rec_INVOBJ.object_type||'</TD><TD>'||Rec_INVOBJ.created||
 	            '</TD><TD>'||Rec_INVOBJ.last_ddl_time||'</TD></TR>';
          print(L_LINE);
        END LOOP;
        print(TABLE_CLOSE||'<HR>');
      END IF;
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;
