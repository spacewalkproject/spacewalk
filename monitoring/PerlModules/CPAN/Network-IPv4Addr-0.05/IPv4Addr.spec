Summary: Perl modules to manipulates Ipv4 addresses.
Name: Network-IPv4Addr
Version: 0.05
Release: 1i
Source: http://iNDev.iNsu.COM/IPv4Addr/%{name}-%{version}.tar.gz
Copyright: GPL or Artistic License
Group: Development/Libraries/Perl
Prefix: /usr
URL: http://iNDev.iNsu.COM/IPv4Addr/
BuildRoot: /var/tmp/%{name}-%{version}
BuildArchitectures: noarch
Requires: perl 

%description
Network::IPv4Addr provides methods for parsing IPv4
addresses both in traditional address/netmask format and
in the new CIDR format.  There are also methods for
calculating the network and broadcast address and also to
see check if a given address is in a specific network.

%prep
%setup -q
# Update all path to the perl interpreter
find -type f -exec sh -c 'if head -c 100 $0 | grep -q "^#!.*perl"; then \
		perl -p -i -e "s|^#!.*perl|#!/usr/bin/perl|g" $0; fi' {} \;

%build
perl Makefile.PL 
make OPTIMIZE="$RPM_OPT_FLAGS"
make test

%install
rm -fr $RPM_BUILD_ROOT
eval `perl '-V:installarchlib'`
mkdir -p $RPM_BUILD_ROOT/$installarchlib
make 	PREFIX=$RPM_BUILD_ROOT/usr \
	INSTALLMAN1DIR=$RPM_BUILD_ROOT/usr/man/man1 \
   	INSTALLMAN3DIR=$RPM_BUILD_ROOT/`dirname $installarchlib`/man/man3 \
   	pure_install

# Fix packing list
for packlist in `find $RPM_BUILD_ROOT -name '.packlist'`; do
	mv $packlist $packlist.old
	sed -e "s|$RPM_BUILD_ROOT||g" < $packlist.old > $packlist
	rm -f $packlist.old
done

# Make a file list
find $RPM_BUILD_ROOT -type f -o -type l | \
	grep -v perllocal.pod | \
	sed -e "s|$RPM_BUILD_ROOT||g" > %{name}-file-list
perl -n -i -e 'print "%doc " if m!man/man|\.pod!; print; ' %{name}-file-list

%clean
rm -fr $RPM_BUILD_ROOT

%files -f %{name}-file-list
%defattr(-,root,root)
%doc README ChangeLog

%changelog
* Wed Sep 15 1999  Francis J. Lacoste <francis.lacoste@iNsu.COM> 
  [0.05-1i]
- Updated to version 0.05.

* Sun Aug 15 1999  Francis J. Lacoste <francis.lacoste@iNsu.COM> 
  [0.04-1i]
- Updated to version 0.04.

* Mon Jul 05 1999  Francis J. Lacoste <francis.lacoste@iNsu.COM> 
  [0.03-1i]
- Updated to version 0.03.

* Sat May 15 1999  Francis J. Lacoste <francis@iNsu.COM> 
  [0.02-2i]
- Updated to version 0.02.

* Sat May 15 1999  Francis J. Lacoste <francis@iNsu.COM> 
  [0.01-1i]
- First RPM release.

