# Macros
%define cvs_package SatConfig/custcfg
%define cfghome      /home/config


# Package specific stuff
Name:		CustomerConfig
Version:	2.18.0
Release:	2
Packager:	Kerry Boomsliter <kboomsli@nocpulse.com>
Summary:	Initial config files for satellite installation
Source:		%name-%version.tar.gz
BuildArch:	noarch
Group:		unsorted
Copyright:	NOCpulse (c) 2000
Vendor:		NOCpulse
Requires:	Config-IniFiles >= 2.19
Requires:	perl >= 5.005
BuildRoot:	/tmp/%name-%version
Prereq:       NPusers

%description

Provides an account and program for the customer to configure
a satellite for operation on their network.

The system administrator must create a config user account with
%cfghome/provclt as it's shell, and either 'kill -1 1' or reboot the system to
%start the server.


%prep
# Prep for build. This is entirely abstract - you should not need to change it.
rm -rf %name-%version
cvs checkout $RPM_TAG_PARAM %cvs_package
mv %cvs_package %name-%version
tar -cvzf $RPM_SOURCE_DIR/%name-%version.tar.gz %name-%version

%build
echo "Nothing to build"

%install
rm -rf          %buildroot
mkdir -p        %buildroot/%cfghome/tmp
mkdir -p	%buildroot/etc/ha.d/{rc.d,resource.d}
cd %name-%version
cp prov*        %buildroot/%cfghome

%files
%attr(755,root,root)	 %dir	%cfghome/
%attr(700,root,root)		%cfghome/provsrv
%attr(755,root,root)		%cfghome/provclt
%attr(755,config,config) %dir	%cfghome/tmp
%attr(600,root,root)		%cfghome/provtmpl

%clean
rm -rf %buildroot
rm -rf %name-%version

#
# End of build

# Start install instructions
#
%pre

%post
grep "^cf:" /etc/inittab
if [ $? -eq 0 ] && [ -f /etc/inittab ] ; then
  sed -e 's,^cf:.*$,cf:2345:respawn:%cfghome/provsrv,' /etc/inittab > /tmp/$$inittab
else
  echo 'cf:2345:respawn:%cfghome/provsrv' >> /etc/inittab
fi

# ref bug id 2689, this value should only come from /etc/ppp/options
perl -an -i.bak -e 'print unless /^EXTERNAL_IP/' /etc/sysconfig/network

killall provsrv

exit 0

%preun
%postun
