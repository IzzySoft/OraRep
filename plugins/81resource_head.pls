
  PROCEDURE rsrc_groups IS
    CURSOR C_Groups IS
      SELECT consumer_group,status,mandatory,comments
        FROM dba_rsrc_consumer_groups
       ORDER BY consumer_group;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="4"><A NAME="resource_groups">'||
                'Resource Consumer Groups</A></TH></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">Group Name</TH><TH CLASS="th_sub">'||
                'Status</TH><TH CLASS="th_sub">Mandatory</TH><TH CLASS="th_sub">'||
                'Comments</TH></TR>';
      print(L_LINE);
      FOR rec IN C_Groups LOOP
        L_LINE := ' <TR><TD>'||rec.consumer_group||'</TD><TD>'||rec.status||
                  '</TD><TD ALIGN="center">'||rec.mandatory||'</TD><TD>'||
                  rec.comments||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN print(TABLE_CLOSE);
    END;

  PROCEDURE rsrc_privs IS
    CURSOR C_Privs IS
      SELECT grantee,granted_group,grant_option,initial_group
        FROM dba_rsrc_consumer_group_privs
       ORDER BY grantee,granted_group;
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="4">Consumer Group Members</TH></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">Grantee</TH><TH CLASS="th_sub">'||
                'Group</TH><TH CLASS="th_sub">Grant Option</TH>'||
                '<TH CLASS="th_sub">Initial Group</TH></TR>';
      print(L_LINE);
      FOR rec IN C_Privs LOOP
        L_LINE := ' <TR><TD>'||rec.grantee||'</TD><TD>'||rec.granted_group||
                  '</TD><TD ALIGN="center">'||rec.grant_option||
                  '</TD><TD ALIGN="center">'||rec.initial_group||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN print(TABLE_CLOSE);
    END;

  PROCEDURE rsrc_directives IS
    CURSOR C_Dirs IS
      SELECT plan,group_or_subplan sub,cpu_p1,cpu_p2,cpu_p3,cpu_p4,cpu_p5,cpu_p6,
             cpu_p7,cpu_p8,mandatory,comments
        FROM dba_rsrc_plan_directives
       WHERE type='CONSUMER_GROUP'
         AND status='ACTIVE';
    BEGIN
      L_LINE := TABLE_OPEN||'<TR><TH COLSPAN="13">Resource Plan Directives'||
                '&nbsp;<A HREF="JavaScript:popup('||CHR(39)||
                'rsrc_plan_dirs'||CHR(39)||')"><IMG SRC="help/help.gif" '||
		'BORDER="0" HEIGHT="16" ALIGN="top" ALT="Help" STYLE="margin-right:5"></A></TH></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub" ROWSPAN="2">Plan</TH>'||
                '<TH CLASS="th_sub" ROWSPAN="2">Group</TH>'||
                '<TH CLASS="th_sub" COLSPAN="8">CPU</TH>';
      print(L_LINE);
      L_LINE := '<TH CLASS="th_sub" ROWSPAN="2">Mandatory</TH>'||
                '<TH CLASS="th_sub" ROWSPAN="2">Comments</TH></TR>';
      print(L_LINE);
      L_LINE := ' <TR><TH CLASS="th_sub">Prio 1</TH><TH CLASS="th_sub">Prio 2'||
                '</TH><TH CLASS="th_sub">Prio 3</TH><TH CLASS="th_sub">Prio 4'||
                '</TH><TH CLASS="th_sub">Prio 5</TH>';
      print(L_LINE);
      L_LINE := '<TH CLASS="th_sub">Prio 6</TH><TH CLASS="th_sub">Prio 7</TH>'||
                '<TH CLASS="th_sub">Prio 8</TH></TR>';
      print(L_LINE);
      FOR rec IN C_Dirs LOOP
        L_LINE := ' <TR><TD>'||rec.plan||'</TD><TD>'||rec.sub||
                  '</TD><TD ALIGN="center">'||rec.cpu_p1||
                  '</TD><TD ALIGN="center">'||rec.cpu_p2||
                  '</TD><TD ALIGN="center">'||rec.cpu_p3;
        print(L_LINE);
        L_LINE := '</TD><TD ALIGN="center">'||rec.cpu_p4||
                  '</TD><TD ALIGN="center">'||rec.cpu_p5||
                  '</TD><TD ALIGN="center">'||rec.cpu_p6;
        print(L_LINE);
        L_LINE := '</TD><TD ALIGN="center">'||rec.cpu_p7||
                  '</TD><TD ALIGN="center">'||rec.cpu_p8||
                  '</TD><TD ALIGN="center">'||rec.mandatory;
        print(L_LINE);
        L_LINE := '</TD><TD>'||rec.comments||'</TD></TR>';
        print(L_LINE);
      END LOOP;
      print(TABLE_CLOSE);
    EXCEPTION
      WHEN OTHERS THEN print(TABLE_CLOSE);
    END;
