  PROCEDURE userinfo IS
    CURSOR C_USER IS
      SELECT username,replace(account_status,'&','&amp;') account_status,
             NVL(to_char(lock_date,'DD.MM.YYYY'),'-') locked,
	     NVL(to_char(expiry_date,'DD.MM.YYYY'),'-') expires,
             default_tablespace dts,temporary_tablespace tts,
             to_char(created,'DD.MM.YYYY') created,profile,
             initial_rsrc_consumer_group resource_group
        FROM dba_users;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="9">User Information'||
                '&nbsp;<A HREF="JavaScript:popup('||CHR(39)||'userinfo'||CHR(39)||
	        ')"><IMG SRC="help/help.gif" BORDER="0" HEIGHT="16" '||
	        'ALIGN="top" ALT="Help"></A></TH></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">Username</TH><TH CLASS="th_sub">Account'||
                ' Status</TH><TH CLASS="th_sub">Lock Date</TH><TH CLASS="th_sub">';
      print(L_LINE);
      L_LINE := 'Expiry Date</TH><TH CLASS="th_sub">Default TS</TH><TH CLASS="th_sub">'||
                'Temporary TS</TH><TH CLASS="th_sub">Created</TH><TH CLASS="th_sub">'||
                'Profile</TH><TH CLASS="th_sub">Init.ResourceGroup</TH></TR>';
      print(L_LINE);
      FOR Rec_USER IN C_USER LOOP
        L_LINE := ' <TR><TD>'||Rec_USER.username||'</TD><TD>'||Rec_USER.account_status||
                  '</TD><TD>'||Rec_USER.locked||'</TD><TD>'||Rec_USER.expires||
                  '</TD><TD>'||Rec_USER.dts||'</TD><TD>'||Rec_USER.tts||'</TD><TD>'||
                  Rec_USER.created;
        print(L_LINE);
        L_LINE := '</TD><TD>'||Rec_USER.profile||'</TD><TD>'||Rec_USER.resource_group||
                  '</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

  PROCEDURE admininfo IS
    CURSOR C_ADM IS
      SELECT grantee,admin_option FROM dba_role_privs WHERE granted_role='DBA';
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="2">Admins</TH></TR>'||CHR(10)||
                ' <TR><TH CLASS="th_sub">User</TH><TH CLASS="th_sub">Admin '||
                'Option</TH></TR>';
      print(L_LINE);
      FOR Rec_ADM IN C_ADM LOOP
        L_LINE := ' <TR><TD>'||Rec_ADM.grantee||'</TD><TD ALIGN="center">'||
                  Rec_ADM.admin_option||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

