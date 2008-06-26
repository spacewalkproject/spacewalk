# Package specific stuff
Name:         NPusers
Source9999: version
Version: %(echo `awk '{ print $1 }' %{SOURCE9999}`)
Release: %(echo `awk '{ print $2 }' %{SOURCE9999}`)%{?dist}
Summary:      Adds NOCpulse production users
License:      GPLv2
URL:          https://fedorahosted.org/spacewalk
BuildArch:    noarch
Group:        Applications/System
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Prereq:       /usr/sbin/useradd /bin/chmod /bin/false /usr/bin/passwd /bin/chown /bin/awk
Prereq:       httpd

%description

Installs NOCpulse users

%define build_sub_dir %(echo %{main_source} | sed 's/\.tar\.gz$//')
%setup -n %build_sub_dir
cp %{SOURCE1} %{_builddir}/%build_sub_dir

%install

rm -rf %{buildroot}

# Install the user creation script
install -m 755 -d %buildroot/etc/nocpulse
install -m 755 -d %buildroot/var/log/nocpulse

%pre
if [ $OSTYPE = solaris ] ; then
  SOLARIS=true
  sysacct=
  wheel_group=apache
  oracle_group=dba
  tcsh=/usr/local/bin/tcsh
  orac
else
  SOLARIS=
  sysacct=-r
  wheel_group="-G apache"
  oracle_group=oinstall
  tcsh=/bin/tcsh
fi

# setting users
/usr/sbin/useradd -c 'NOCpulse user' $wheel_group nocpulse
/usr/bin/passwd -l nocpulse

# Setting up nocpulse homedir and ssh key pair
for dir in /etc/nocpulse /var/lib/nocpulse/{,.ssh,var{,/archives}}
do
  if [ ! -d $dir ]
  then
    mkdir -p $dir
  fi
done
/usr/bin/ssh-keygen -q -t dsa -N '' -f /var/lib/nocpulse/.ssh/nocpulse-identity
chown -R nocpulse.nocpulse /var/lib/nocpulse

%files
%defattr(-,nocpulse,nocpulse)
%dir /etc/nocpulse
%dir /var/log/nocpulse

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Thu Jun 19 2008 Miroslav Suchy <msuchy@redhat.com>
- migrating nocpulse home dir (BZ 202614)

* Wed May 21 2008 Miroslav Suchy <msuchy@redhat.com> 1.17.11-6
- migrate to brew / dist-cvs
