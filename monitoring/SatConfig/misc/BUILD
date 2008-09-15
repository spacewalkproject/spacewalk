# Macros

%define cvs_package    SatConfig/misc

%define etc            /etc
%define tmp	       /tmp
%define sbin           /sbin
%define localbin       /usr/local/bin
%define sshd           /etc/ssh

# Package specific stuff
Name:         SatConfig-misc
Version:      1.36.1
Release:      1
Packager:     Dave Parker <dparker@nocpulse.com>
Summary:      Satellite Configuration - misc stuff
Source:	      SatConfig-misc-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Group:        unsorted
Copyright:    Red Hat, Inc. (c) 2000-2003
Vendor:       Red Hat, Inc.
Prefix:	      %install_prefix
Buildroot:    %{_tmppath}/%cvs_package
Prereq:       crontabs SysVinit initscripts openssh-server openssh-clients oracle-devel

%description

Contains misc little tweaky things that don't really fit anywhere else

%prep
%entirely_abstract_build_step


%build
echo "Nothing to build"


%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
mkdir -p $RPM_BUILD_ROOT%etc
mkdir -p $RPM_BUILD_ROOT%tmp
mkdir -p $RPM_BUILD_ROOT%sbin
mkdir -p $RPM_BUILD_ROOT%sshd
mkdir -p $RPM_BUILD_ROOT%localbin
install -o root -g root -m 644 bashrc $RPM_BUILD_ROOT%etc/bashrc.nocpulse
install -o root -g root -m 500 nuke_mbr $RPM_BUILD_ROOT%sbin
install -o root -g root -m 500 destroySystemConfiguration $RPM_BUILD_ROOT%sbin
install -o root -g root -m 555 delayRun $RPM_BUILD_ROOT%localbin
install -o root -g root -m 555 download $RPM_BUILD_ROOT%localbin
install -o root -g root -m 644 ssh_config $RPM_BUILD_ROOT%sshd
install -o root -g root -m 644 sshd_config $RPM_BUILD_ROOT%sshd
install -o root -g root -m 644 ssh_config $RPM_BUILD_ROOT%sshd

%point_scripts_to_correct_perl 



%files
%attr(644,root,root) %etc/bashrc.nocpulse
%sbin/nuke_mbr
%sbin/destroySystemConfiguration
%localbin/delayRun
%localbin/download
%sshd/sshd_config
%sshd/ssh_config

%post
# Install our aliases, etc
cp /etc/bashrc.nocpulse /etc/bashrc
# Install serial console getty
if ! grep  ttyS1 /etc/inittab  ; then
	echo "s0:2345:respawn:/sbin/mgetty -r ttyS0 DT9600" >> /etc/inittab
	/sbin/telinit q
fi
# Disable mail from cron jobs
cp /etc/crontab /etc/crontab.orig
sed /MAILTO=root/s//MAILTO=\"\"/g /etc/crontab.orig >  /etc/crontab
cp /etc/rc.d/rc.sysinit /etc/rc.d/rc.sysinit.orig
sed '/fsck -T -a/s//fsck -T -y/g' /etc/rc.d/rc.sysinit.orig > /etc/rc.d/rc.sysinit.1
sed '/fsck -T -R -A -a/s//fsck -T -R -A -y/g' /etc/rc.d/rc.sysinit.1 > /etc/rc.d/rc.sysinit.2
sed '/sulogin/s//fsck -ay/g' /etc/rc.d/rc.sysinit.2 > /etc/rc.d/rc.sysinit
#
#
# DAP NOTE WOAH HELLA EVIL FIXME
#
# ORACLE_HOME is (for well-behaved programs) a function of the contents of 
# NOCpulse.ini which is generated from the database.  In as much as I would break
# the existing DEV environment by changing the DEV database now, I'm including this
# concentrated piece of evil to work around it.  It will need to go, as might a great deal
# of what this package does - I'll deal with it and curse myself once
# I've got everything else working.
#
ln -s /opt/oracle /home/oracle/OraHome1
# Additional evil - in as much as this goes toward configuration it's somewhat less evil
# overall than the previous bit (but it is still evil).  Again - this is mere
# transient evil - it vanishes in a puff of goodness when configured the layered way.
rm /etc/tnsnames.ora

%clean
%abstract_clean_script 
