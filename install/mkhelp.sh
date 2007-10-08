#!/bin/bash
# $Id$
#
# =============================================================================
# Simple Database Analysis Report (c) 2003-2007 by IzzySoft (devel@izzysoft.de)
# -----------------------------------------------------------------------------
# This script creates the help files based on your configuration file. You need
# to run it for the first time installation and whenever certain variables in
# your configuration change (see "Uses:" below)
# -----------------------------------------------------------------------------
# Uses: CSS
# =============================================================================

. ../config

HCSS=`echo $CSS|sed 's/\.\./\\\.\\\./g'|sed 's/\//\\\\\//g'`
CYEAR="2003-2007"
SEDC="s/{css}/$HCSS/g"
SED2="s/{copy}/$CYEAR/g"
for i in *.tpl; do
  TARGET=$REPDIR/help/${i%%.*}.html
  sed $SEDC $i | sed $SED2 >$TARGET
  chmod o+r $TARGET
done
cp help.gif $REPDIR/help/
chmod o+r $REPDIR/help/help.gif
cp w3c.jpg $REPDIR
cp islogo.gif $REPDIR
cp iceage.css $REPDIR
chmod o+r $REPDIR/w3c.jpg $REPDIR/islogo.gif $REPDIR/iceage.css
