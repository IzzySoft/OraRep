
  PROCEDURE dba_prof IS
    CURSOR C_Prof IS
      SELECT profile,resource_name,resource_type,
	     DECODE(limit,'UNLIMITED','Unlimited',
	            'DEFAULT','Default',
		    'NULL','Null',
	            TO_CHAR(limit,'999,999,990')) limit
        FROM dba_profiles
       ORDER BY profile,resource_name;

    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="4"><A NAME="profiles">Profiles'||
                '</A></TH></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">Profile</TH><TH CLASS="th_sub">'||
                'Resource</TH><TH CLASS="th_sub">Type</TH>'||
		'<TH CLASS="th_sub">Limit</TH></TR>';
      print(L_LINE);
      FOR rec IN C_Prof LOOP
        L_LINE := ' <TR><TD>'||rec.profile||'</TD><TD>'||rec.resource_name||
	          '</TD><TD ALIGN="center">'||rec.resource_type||
		  '</TD><TD ALIGN="center">'||rec.limit||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

