TOPDIR=$(cd $(dirname $0) && pwd)

domain="unit-test"
for lang in en ro; do
    msgfmt --statistics --verbose \
        --output-file $TOPDIR/translations/$lang/LC_MESSAGES/$domain.mo $TOPDIR/$domain.$lang
done
