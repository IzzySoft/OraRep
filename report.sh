#!/bin/bash
# $Id$
#
# =============================================================================
# Simple Database Analysis Report (c) 2003-2004 by IzzySoft (devel@izzysoft.de)
# -----------------------------------------------------------------------------
# This report script creates a HTML document containing an overview on the
# database, whichs SID you either provide at the command line or configure it
# in the block below. But more than this, it not only reads the usual
# performance indicators out of the usual views, but connects values and gives
# you hints about how to use these results.
# I'ld never claim this report tool to be perfect, complete or "state of the
# art". But it's simple to use and very helpful to those not having a license
# to the expensive AddOns available at Oracle. Any hints on errors or bugs as
# well as recommendations for additions are always welcome.
#                                                              Itzchak Rehberg
# -----------------------------------------------------------------------------
# Don't edit this file (at least not if you don't know what it's all about).
# If you look for the configuration options, this is the wrong place - they
# are kept in the file "config" in the same directory as this script resides.
#
version='0.3.4'
if [ -z "$1" ]; then
  SCRIPT=${0##*/}
  echo
  echo ============================================================================
  echo "OraRep v$version                (c) 2003 by Itzchak Rehberg (devel@izzysoft.de)"
  echo ----------------------------------------------------------------------------
  echo This script is intended to generate a HTML report for a given instance. Look
  echo inside the script header for closer details, and check for the configuration
  echo there as well.
  echo ----------------------------------------------------------------------------
  echo "Syntax: ${SCRIPT} <ORACLE_SID> [Options]"
  echo "  Options:"
  echo "     -c <alternative ConfigFile>"
  echo "     -d <StartDir>"
  echo "     -o <Output Filename>"
  echo "     -p <Password>"
  echo "     -r <ReportDirectory>"
  echo "     -s <ORACLE_SID/Connection String for Target DB>"
  echo "     -u <username>"
  echo ============================================================================
  echo
  exit 1
fi
# =================================================[ Configuration Section ]===
BINDIR=${0%/*}
PLUGINDIR=$BINDIR/plugins
CONFIG=$BINDIR/config
ARGS=$*

# ------------------------------------------[ process command line options ]---
while [ -n "$1" ] ; do
  case "$1" in
    -s) shift; ORACLE_CONNECT=$1;;
    -u) shift; username=$1;;
    -p) shift; passwd=$1;;
    -d) shift; startdir=$1;;
    -c) shift; CONFIG=$1;;
    -r) shift; REPORTDIR=$1;;
    -o) shift; FILENAME=$1;;
  esac
  shift
done
. $CONFIG $ARGS
if [ -z "$ORACLE_CONNECT" ]; then
  ORACLE_CONNECT=$ORACLE_SID
fi
if [ -n "$username" ]; then
  user=$username
fi
if [ -n "$passwd" ]; then
  password=$passwd
fi
if [ -n "$REPORTDIR" ]; then
  REPDIR=$REPORTDIR
fi
if [ -z "$FILENAME" ]; then
  FILENAME="${ORACLE_SID}.html"
fi

SQLSET=$TMPDIR/orarep_sqlset_$ORACLE_SID.$$
TMPOUT=$TMPDIR/orarep_tmpout_$ORACLE_SID.$$
TMPADV=$TMPDIR/orarep_tmpadv_$ORACLE_SID.$$

# If called from another script, we may have to change to another directory
# before generating the reports
if [ -n "$startdir" ]; then
  cd $startdir
fi

# --------------------------------[ Get the Oracle version of the DataBase ]---
cat >$SQLSET<<ENDSQL
CONNECT $user/$password@$ORACLE_CONNECT
Set TERMOUT OFF
Set SCAN OFF
Set SERVEROUTPUT On Size 1000000
Set LINESIZE 300
Set TRIMSPOOL On 
Set FEEDBACK OFF
Set Echo Off
Set PAGESIZE 0
SPOOL $TMPOUT
ENDSQL

cat $SQLSET $BINDIR/getver.sql | $ORACLE_HOME/bin/sqlplus -s /NOLOG >/dev/null
DBVER=`cat $TMPOUT`
if [ $DBVER -gt 91 ]; then
  WAITHEAD=$PLUGINDIR/92wait_head.pls
  WAITBODY=$PLUGINDIR/92wait_body.pls
  SPADVHEAD=$PLUGINDIR/92spadv_head.pls
  SPADVBODY=$PLUGINDIR/92spadv_body.pls
else
  WAITHEAD=$PLUGINDIR/81wait_head.pls
  WAITBODY=$PLUGINDIR/81wait_body.pls
  SPADVHEAD=$PLUGINDIR/dummy.pls
  SPADVBODY=$PLUGINDIR/dummy.pls
fi
if [ $MK_ENQ -eq 1 ]; then
  if [ $DBVER -gt 89 ]; then
    ENQHEAD=$PLUGINDIR/90enq_head.pls
    ENQBODY=$PLUGINDIR/90enq_body.pls
  else
    ENQHEAD=$PLUGINDIR/dummy.pls
    ENQBODY=$PLUGINDIR/dummy.pls
  fi
fi
if [ $DBVER -lt 89 ]; then
  ENQHEAD=$PLUGINDIR/81enq_head.pls
fi
# ----------------------------------[ Include optional Features if defined ]---
if [ $MK_INSTEFF -eq 1 ]; then
  INSTEFF=$PLUGINDIR/insteff.pls
fi
if [ $MK_LOADPROF -eq 1 ]; then
  LOADPROFHEAD=$PLUGINDIR/loadprof_head.pls
  LOADPROFBODY=$PLUGINDIR/loadprof_body.pls
fi
if [ $MK_USER -eq 1 ]; then
  USERHEAD=$PLUGINDIR/user_head.pls
  USERBODY=$PLUGINDIR/user_body.pls
fi
if [ $MK_DBLINK -eq 1 ]; then
  DBLINKHEAD=$PLUGINDIR/dblink_head.pls
  DBLINKBODY=$PLUGINDIR/dblink_body.pls
fi
if [ $MK_RSRC -eq 1 ]; then
  RSRCBODY=$PLUGINDIR/81resource_body.pls
  if [ $DBVER -gt 89 ]; then
    RSRCHEAD=$PLUGINDIR/90resource_head.pls
  else
    RSRCHEAD=$PLUGINDIR/81resource_head.pls
  fi
fi
if [ $MK_TABS -eq 1 ]; then
  TABSHEAD=$PLUGINDIR/tabs_head.pls
  TABSBODY=$PLUGINDIR/tabs_body.pls
fi
if [ $MK_TSQUOT -eq 1 ]; then
  TSQUOTHEAD=$PLUGINDIR/tsquot_head.pls
  TSQUOTBODY=$PLUGINDIR/tsquot_body.pls
fi
if [ $MK_DBAPROF -eq 1 ]; then
  PROFHEAD=$PLUGINDIR/prof_head.pls
  PROFBODY=$PLUGINDIR/prof_body.pls
fi
if [ $MK_FILES -eq 1 ]; then
  FILESHEAD=$PLUGINDIR/files_head.pls
  FILESBODY=$PLUGINDIR/files_body.pls
fi
if [ $MK_RBS -eq 1 ]; then
  RBSHEAD=$PLUGINDIR/rbs_head.pls
  RBSBODY=$PLUGINDIR/rbs_body.pls
fi
if [ $MK_MEMVAL -eq 1 ]; then
  MEMVALHEAD=$PLUGINDIR/memval_head.pls
  MEMVALBODY=$PLUGINDIR/memval_body.pls
fi
if [ $MK_POOL -eq 1 ]; then
  POOLHEAD=$PLUGINDIR/pool_head.pls
  POOLBODY=$PLUGINDIR/pool_body.pls
fi
if [ $MK_BUFFRAT -eq 1 ]; then
  BUFFRATHEAD=$PLUGINDIR/buffrat_head.pls
  BUFFRATBODY=$PLUGINDIR/buffrat_body.pls
fi
if [ $MK_SYSSTAT -eq 1 ]; then
  SYSSTAT=$PLUGINDIR/sysstat.pls
fi
if [ $MK_WTEVT -eq 1 ]; then
  WTEVTBODY=$PLUGINDIR/wtevt_body.pls
fi
if [ $MK_FLC -eq 1 ]; then
  FLCHEAD=$PLUGINDIR/freelist_head.pls
  FLCBODY=$PLUGINDIR/freelist_body.pls
fi
if [ $MK_INVOBJ -eq 1 ]; then
  INVOBJHEAD=$PLUGINDIR/invobj_head.pls
  INVOBJBODY=$PLUGINDIR/invobj_body.pls
fi
if [ $MK_DBWR -eq 1 ]; then
  DBWRHEAD=$PLUGINDIR/dbwr_head.pls
  DBWRBODY=$PLUGINDIR/dbwr_body.pls
fi
if [ $MK_LGWR -eq 1 ]; then
  LGWRHEAD=$PLUGINDIR/lgwr_head.pls
  LGWRBODY=$PLUGINDIR/lgwr_body.pls
fi

if [ "${MK_DBWR}${MK_LGWR}${MK_TABS}" != "000" ]; then
  SYSSTATFUNCS=$PLUGINDIR/sysstats.pls
fi
if [ "${MK_USS}${MK_USSTAT}" != "00" ]; then
  UNDOHEAD=$PLUGINDIR/undo_head.pls
  UNDOBODY=$PLUGINDIR/undo_body.pls
fi
if [ $MK_RLIMS -eq 1 ]; then
  if [ $DBVER -gt 89 ]; then
    RLIMHEAD=$PLUGINDIR/rlim_head.pls
    RLIMBODY=$PLUGINDIR/rlim_body.pls
  fi
fi


cat >$TMPADV<<ENDSQL
  IF MK_ADVICE THEN
    get_dbc_advice();
  END IF;
ENDSQL
cat $SPADVBODY>>$TMPADV
cat >>$TMPADV<<ENDSQL
  IF MK_ADVICE THEN
    print('<HR>');
  END IF;
ENDSQL

cat >$SQLSET<<ENDSQL
CONNECT $user/$password@$ORACLE_CONNECT
Set TERMOUT OFF
Set SCAN OFF
Set SERVEROUTPUT On Size 1000000
Set LINESIZE 300
Set TRIMSPOOL On 
Set FEEDBACK OFF
Set Echo Off
variable CSS VARCHAR2(255);
variable SCRIPTVER VARCHAR2(20);
variable TOP_N_WAITS NUMBER;
variable TOP_N_TABLES NUMBER;
variable MK_USER NUMBER;
variable MK_DBLINK NUMBER;
variable MK_RSRC NUMBER;
variable MK_TSQUOT NUMBER;
variable MK_DBAPROF NUMBER;
variable MK_INSTEFF NUMBER;
variable MK_LOADPROF NUMBER;
variable MK_TABS NUMBER;
variable MK_FILES NUMBER;
variable MK_DBWR NUMBER;
variable MK_LGWR NUMBER;
variable MK_RBS NUMBER;
variable MK_MEMVAL NUMBER;
variable MK_POOL NUMBER;
variable MK_BUFFRAT NUMBER;
variable MK_ENQ NUMBER;
variable MK_USS NUMBER;
variable MK_USSTAT NUMBER;
variable MK_SYSSTAT NUMBER;
variable MK_WTEVT NUMBER;
variable MK_FLC NUMBER;
variable MK_INVOBJ NUMBER;
variable MK_TSCAN NUMBER;
variable MK_NEXT NUMBER;
variable MK_RLIMS NUMBER;
variable TPH_NOLOG NUMBER;
variable WPH_NOLOG NUMBER;
variable WR_BUFF NUMBER;
variable AR_BUFF NUMBER;
variable WR_FILEUSED NUMBER;
variable AR_FILEUSED NUMBER;
variable WR_RWP NUMBER;
variable AR_RWP NUMBER;
variable WR_IE_BUFFNW NUMBER;
variable AR_IE_BUFFNW NUMBER;
variable WR_IE_REDONW NUMBER;
variable AR_IE_REDONW NUMBER;
variable WR_IE_BUFFHIT NUMBER;
variable AR_IE_BUFFHIT NUMBER;
variable WR_IE_IMSORT NUMBER;
variable AR_IE_IMSORT NUMBER;
variable WR_IE_LIBHIT NUMBER;
variable AR_IE_LIBHIT NUMBER;
variable WR_IE_SOFTPRS NUMBER;
variable AR_IE_SOFTPRS NUMBER;
variable WR_IE_LAHIT NUMBER;
variable AR_IE_LAHIT NUMBER;
variable WR_IE_PRSC2E NUMBER;
variable AR_IE_PRSC2E NUMBER;
variable WR_RLIM NUMBER;
variable AR_RLIM NUMBER;
BEGIN
  :CSS         := '$CSS';
  :SCRIPTVER   := '$version';
  :TOP_N_WAITS := $TOP_N_WAITS;
  :TOP_N_TABLES := $TOP_N_TABLES;
  :MK_USER     := $MK_USER;
  :MK_DBLINK   := $MK_DBLINK;
  :MK_RSRC     := $MK_RSRC;
  :MK_DBAPROF  := $MK_DBAPROF;
  :MK_TSQUOT   := $MK_TSQUOT;
  :MK_INSTEFF  := $MK_INSTEFF;
  :MK_LOADPROF := $MK_LOADPROF;
  :MK_TABS     := $MK_TABS;
  :MK_FILES    := $MK_FILES;
  :MK_DBWR     := $MK_DBWR;
  :MK_LGWR     := $MK_LGWR;
  :MK_RBS      := $MK_RBS;
  :MK_MEMVAL   := $MK_MEMVAL;
  :MK_POOL     := $MK_POOL;
  :MK_BUFFRAT  := $MK_BUFFRAT;
  :MK_SYSSTAT  := $MK_SYSSTAT;
  :MK_WTEVT    := $MK_WTEVT;
  :MK_FLC      := $MK_FLC;
  :MK_ENQ      := $MK_ENQ;
  :MK_USS      := $MK_USS;
  :MK_USSTAT   := $MK_USSTAT;
  :MK_INVOBJ   := $MK_INVOBJ;
  :MK_TSCAN    := $MK_TSCAN;
  :MK_NEXT     := $MK_NEXT;
  :MK_RLIMS    := $MK_RLIMS;
  :TPH_NOLOG   := $TPH_NOLOG;
  :WPH_NOLOG   := $WPH_NOLOG;
  :WR_BUFF     := $WR_BUFF;
  :AR_BUFF     := $AR_BUFF;
  :WR_FILEUSED := $WR_FILEUSED;
  :AR_FILEUSED := $AR_FILEUSED;
  :WR_RWP      := $WR_RWP;
  :AR_RWP      := $AR_RWP;
  :WR_IE_BUFFNW  := $WR_IE_BUFFNW;
  :AR_IE_BUFFNW  := $AR_IE_BUFFNW;
  :WR_IE_REDONW  := $WR_IE_REDONW;
  :AR_IE_REDONW  := $AR_IE_REDONW;
  :WR_IE_BUFFHIT := $WR_IE_BUFFHIT;
  :AR_IE_BUFFHIT := $AR_IE_BUFFHIT;
  :WR_IE_IMSORT  := $WR_IE_IMSORT;
  :AR_IE_IMSORT  := $AR_IE_IMSORT;
  :WR_IE_LIBHIT  := $WR_IE_LIBHIT;
  :AR_IE_LIBHIT  := $AR_IE_LIBHIT;
  :WR_IE_SOFTPRS := $WR_IE_SOFTPRS;
  :AR_IE_SOFTPRS := $AR_IE_SOFTPRS;
  :WR_IE_LAHIT   := $WR_IE_LAHIT;
  :AR_IE_LAHIT   := $AR_IE_LAHIT;
  :WR_IE_PRSC2E  := $WR_IE_PRSC2E;
  :AR_IE_PRSC2E  := $AR_IE_PRSC2E;
  :WR_RLIM       := $WR_RLIM;
  :AR_RLIM	 := $AR_RLIM;
END;
/
SPOOL $REPDIR/${FILENAME}
ENDSQL

# ====================================================[ Script starts here ]===
#cat $SQLSET $BINDIR/rephead.pls $PLUGINDIR/formatting.pls $SYSSTATFUNCS $USERHEAD $DBLINKHEAD $LOADPROFHEAD $WAITHEAD $ENQHEAD $UNDOHEAD $SPADVHEAD $RSRCHEAD $PROFHEAD $TSQUOTHEAD $TABSHEAD $FILESHEAD $DBWRHEAD $LGWRHEAD $RBSHEAD $MEMVALHEAD $POOLHEAD $BUFFRATHEAD $FLCHEAD $INVOBJHEAD $RLIMHEAD $BINDIR/repopen.pls $INSTEFF $LOADPROFBODY $USERBODY $DBLINKBODY $RSRCBODY $PROFBODY $TSQUOTBODY $TABSBODY $FILESBODY $DBWRBODY $LGWRBODY $RBSBODY $MEMVALBODY $POOLBODY $TMPADV $SYSSTAT $WTEVTBODY $BUFFRATBODY $FLCBODY $WAITBODY $ENQBODY $UNDOBODY $INVOBJBODY $RLIMBODY $BINDIR/repclose.pls >rep.out
cat $SQLSET $BINDIR/rephead.pls $PLUGINDIR/formatting.pls $SYSSTATFUNCS $USERHEAD $DBLINKHEAD $LOADPROFHEAD $WAITHEAD $ENQHEAD $UNDOHEAD $SPADVHEAD $RSRCHEAD $PROFHEAD $TSQUOTHEAD $TABSHEAD $FILESHEAD $DBWRHEAD $LGWRHEAD $RBSHEAD $MEMVALHEAD $POOLHEAD $BUFFRATHEAD $FLCHEAD $INVOBJHEAD $RLIMHEAD $BINDIR/repopen.pls $INSTEFF $LOADPROFBODY $USERBODY $DBLINKBODY $RSRCBODY $PROFBODY $TSQUOTBODY $TABSBODY $FILESBODY $DBWRBODY $LGWRBODY $RBSBODY $MEMVALBODY $POOLBODY $TMPADV $SYSSTAT $WTEVTBODY $BUFFRATBODY $FLCBODY $WAITBODY $ENQBODY $UNDOBODY $INVOBJBODY $RLIMBODY $BINDIR/repclose.pls | $ORACLE_HOME/bin/sqlplus -s /NOLOG
rm -f $SQLSET $TMPOUT $TMPADV
