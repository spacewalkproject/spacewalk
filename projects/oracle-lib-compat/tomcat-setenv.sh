
# To address bug 623115/627859, we need to override the ldap_* symbols
# in libclntsh.so* upon tomcat* startup with those from standard library.
for i in /lib64/security/pam_ldap.so /lib/security/pam_ldap.so ; do
	if [ -f $i ] ; then
		# to force ldd to show the libldap line with => even if LD_PRELOAD was already set
		unset LD_PRELOAD
		export LD_PRELOAD=`ldd $i 2> /dev/null | perl -lne '/^\s+libldap\S+\s+=>\s+(\S+)/ and print $1 and exit'`
		break
	fi
done

