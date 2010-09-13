
# To address bug 623115/627859, we need to override the ldap_* symbols
# in libclntsh.so* upon tomcat5 startup with those from standard library.
if [ -f /usr/lib64/libldap.so ] ; then
	LD_PRELOAD=/usr/lib64/libldap.so
else
	LD_PRELOAD=/usr/lib/libldap.so
fi
export LD_PRELOAD

