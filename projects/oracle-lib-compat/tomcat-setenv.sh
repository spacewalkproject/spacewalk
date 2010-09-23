
# To address bug 623115/627859, we need to override the ldap_* symbols
# in libclntsh.so* upon tomcat5 startup with those from standard library.
for i in /lib64/security/pam_ldap.so /lib/security/pam_ldap.so ; do
	if [ -f $i ] ; then
		export LD_PRELOAD=`ldd $i | perl -lne '/^\s+libldap\S+\s+=>\s+(\S+)/ and print $1 and exit'`
		break
	fi
done

