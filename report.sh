#!/bin/bash
# $Id$
#
# =============================================================================
# Simple Database Analysis Report      (c) 2003 by IzzySoft (devel@izzysoft.de)
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
version='0.1.8'
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
  echo "Syntax: ${SCRIPT} <ORACLE_SID> [StartDir]"
  echo ============================================================================
  echo
  exit 1
fi
# =================================================[ Configuration Section ]===
BINDIR=${0%/*}
. $BINDIR/config $*
SQLSET=$TMPDIR/orarep_sqlset_$1.$$
TMPOUT=$TMPDIR/orarep_tmpout_$1.$$

# If called from another script, we may have to change to another directory
# before generating the reports
if [ -n "$2" ]; then
  cd $2
fi

# --------------------------------[ Get the Oracle version of the DataBase ]---
cat >$SQLSET<<ENDSQL
CONNECT $user/$password@$1
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
  WAITHEAD=$BINDIR/plugins/92wait_head.pls
  WAITBODY=$BINDIR/plugins/92wait_body.pls
  SPADVHEAD=$BINDIR/plugins/92spadv_head.pls
  SPADVBODY=$BINDIR/plugins/92spadv_body.pls
else
  WAITHEAD=$BINDIR/plugins/81wait_head.pls
  WAITBODY=$BINDIR/plugins/81wait_body.pls
  SPADVHEAD=$BINDIR/plugins/dummy.pls
  SPADVBODY=$BINDIR/plugins/dummy.pls
fi
if [ $DBVER -gt 89 ]; then
  ENQHEAD=$BINDIR/plugins/90enq_head.pls
  ENQBODY=$BINDIR/plugins/90enq_body.pls
else
  ENQHEAD=$BINDIR/plugins/dummy.pls
  ENQBODY=$BINDIR/plugins/dummy.pls
fi

cat >$SQLSET<<ENDSQL
CONNECT $user/$password@$1
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
BEGIN
  :CSS         := '$CSS';
  :SCRIPTVER   := '$version';
  :TOP_N_WAITS := $TOP_N_WAITS;
  :TOP_N_TABLES := $TOP_N_TABLES;
END;
/
SPOOL $REPDIR/${ORACLE_SID}.html
ENDSQL

# ====================================================[ Script starts here ]===
#$ORACLE_HOME/bin/sqlplus -s $user/$password <<EOF
#$ORACLE_HOME/bin/sqlplus -s /NOLOG <<EOF

#cat $SQLSET $BINDIR/rephead.pls $WAITHEAD $ENQHEAD $SPADVHEAD $BINDIR/repopen.pls $SPADVBODY $BINDIR/repmiddle.pls $WAITBODY $ENQBODY $BINDIR/repclose.pls >rep.out
cat $SQLSET $BINDIR/rephead.pls $WAITHEAD $ENQHEAD $SPADVHEAD $BINDIR/repopen.pls $SPADVBODY $BINDIR/repmiddle.pls $WAITBODY $ENQBODY $BINDIR/repclose.pls | $ORACLE_HOME/bin/sqlplus -s /NOLOG
rm $SQLSET
rm $TMPOUT
