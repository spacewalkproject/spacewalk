#!/bin/sh

# perl 5.8 utf crap
unset LANG
DICT=$1
[ -z "$DICT" ] && DICT=production/production.satcon.dict

rm -vRf /tmp/satcon-local-deploy
satcon-deploy-tree.pl $DICT . /tmp/satcon-local-deploy '[[' ']]'

