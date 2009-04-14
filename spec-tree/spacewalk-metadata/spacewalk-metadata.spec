Summary: Spacewalk Metadata for developer workstation.
Name: spacewalk-metadata
Source0: %{name}-version
Version: %(echo `awk '{ print $1 }' %{SOURCE0}`)
Release: %(echo `awk '{ print $2 }' %{SOURCE0}`)%{?dist}
License: GPL
Group: Development
URL: http://fedorahosted.org/gitme
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
BuildArch: noarch

%description
Spacewalk Metadata for developer workstation.  All dev packages
for a working development workstation are required by this package.

%package legacy-workstation
Group: Development
Summary: Spacewalk Metadata for legacy (perl/python) developer workstation.
Requires: httpd
Requires: httpd-devel
Requires: mod_perl
Requires: mod_ssl
Requires: libapreq2
Requires: mod_jk-ap20
Requires: spacewalk-metadata
Requires: oracle-lib-compat

Requires: perl-Algorithm-Diff
Requires: perl-Bit-Vector
Requires: perl-Cache-Cache
Requires: perl-Carp-Clan
Requires: perl-Class-ErrorHandler
Requires: perl-Class-Loader
Requires: perl-Class-Singleton
Requires: perl-Convert-ASCII-Armour
Requires: perl-Crypt-Blowfish
Requires: perl-Crypt-CAST5_PP
Requires: perl-Crypt-CBC
Requires: perl-Crypt-DES
Requires: perl-Crypt-DES_EDE3
Requires: perl-Crypt-DSA
Requires: perl-Crypt-IDEA
Requires: perl-Crypt-Primes
Requires: perl-Crypt-Random
Requires: perl-Crypt-Rijndael
Requires: perl-Crypt-RSA
Requires: perl-Crypt-Twofish
Requires: perl-Crypt-SSLeay
Requires: perl-DBD-Oracle
Requires: perl-Data-Buffer
Requires: perl-Date-Calc
Requires: perl-DateManip
Requires: perl-DateTime
Requires: perl-DateTime-Format-Mail
Requires: perl-DateTime-Format-W3CDTF
Requires: perl-Devel-Symdump
Requires: perl-Digest-MD2
Requires: perl-Error
Requires: perl-Frontier-RPC
Requires: perl-IPC-ShareLite
Requires: perl-libxml-perl
Requires: perl-Mail-RFC822-Address
Requires: perl-MailTools
Requires: perl-Math-Pari
Requires: perl-MIME-Lite
Requires: perl-Params-Validate
Requires: perl-Parse-Yapp
Requires: perl-Proc-Daemon
Requires: perl-RPM2
Requires: perl-Schedule-Cron-Events
Requires: perl-Set-Crontab
Requires: perl-SOAP-Lite
Requires: perl-Sort-Versions
Requires: perl-TermReadKey
Requires: perl-Test-Manifest
Requires: perl-Text-Diff
Requires: perl-Tie-EncryptedHash
Requires: perl-TimeDate
Requires: perl-Unix-Syslog
Requires: perl-XML-Dumper
Requires: perl-XML-Grove
Requires: perl-XML-LibXML
Requires: perl-XML-LibXML-Common
Requires: perl-XML-LibXSLT
Requires: perl-XML-NamespaceSupport
Requires: perl-XML-RSS
Requires: perl-XML-SAX
Requires: perl-XML-Simple
Requires: perl-XML-Twig
Requires: perl-XML-Writer
Requires: perl-YAML
Requires: perl-libapreq2
Requires: perl-DBI
Requires: perl-Apache-DBI
Requires: perl-Authen-PAM
Requires: perl-Authen-DigestMD5
Requires: perl-Authen-Krb5
Requires: perl-Digest-SHA
Requires: perl-Digest-HMAC

# python files -- maybe make this a sep rpm
Requires: mod_python
Requires: pyOpenSSL
Requires: cx_Oracle
Requires: rhnlib


#Requires: perl-Algorithm-Diff
#Requires: perl-Archive-Tar
#Requires: perl-Array-RefElem
#Requires: perl-Authen-PAM
#Requires: perl-BSD-Resource
#Requires: perl-Bit-Vector
#Requires: perl-Business-CreditCard
#Requires: perl-Cache-Cache
#Requires: perl-Class-Loader
#Requires: perl-Compress-Zlib
#Requires: perl-Convert-ASCII-Armour
#Requires: perl-Convert-ASN1
#Requires: perl-Convert-PEM
#Requires: perl-Crypt-CAST5_PP
#Requires: perl-Crypt-RSA
#Requires: perl-Crypt-Rijndael
#Requires: perl-DBD-Oracle
#Requires: perl-DBI
#Requires: perl-Data-Buffer
#Requires: perl-Date-Calc
#Requires: perl-DateManip
#Requires: perl-Devel-Symdump
#Requires: perl-Digest-HMAC
#Requires: perl-Digest-MD2
#Requires: perl-Digest-SHA1
#Requires: perl-Error
#Requires: perl-Filter
#Requires: perl-Frontier-RPC
#Requires: perl-HTML-Parser
#Requires: perl-HTML-Tagset
#Requires: perl-IO-Zlib
#Requires: perl-IPC-ShareLite
#Requires: perl-MIME-Lite
#Requires: perl-Mail-RFC822-Address
#Requires: perl-Math-FFT
#Requires: perl-Math-Pari
#Requires: perl-Params-Validate
#Requires: perl-Parse-Yapp
#Requires: perl-Proc-Daemon
#Requires: perl-RPM2
#Requires: perl-SGMLSpm
#Requires: perl-Satcon
#Requires: perl-Schedule-Cron-Events
#Requires: perl-Set-Crontab
#Requires: perl-SOAP-Lite
#Requires: perl-Sort-Versions
#Requires: perl-Term-ReadLine-Gnu
#Requires: perl-TermReadKey
#Requires: perl-Test-Manifest
#Requires: perl-Text-Diff
#Requires: perl-Tie-EncryptedHash
#Requires: perl-Time-HiRes
#Requires: perl-TimeDate
#Requires: perl-URI
#Requires: perl-Unix-Syslog
#Requires: perl-XML-Dumper
#Requires: perl-XML-Encoding
#Requires: perl-XML-Grove
#Requires: perl-XML-LibXML
#Requires: perl-XML-LibXML-Common
#Requires: perl-XML-LibXSLT
#Requires: perl-XML-NamespaceSupport
#Requires: perl-XML-Parser
#Requires: perl-XML-RSS
#Requires: perl-XML-SAX
#Requires: perl-XML-Simple
#Requires: perl-XML-Twig
#Requires: perl-XML-Writer
#Requires: perl-YAML
#Requires: perl-libapreq2
#Requires: perl-libwww-perl
#Requires: perl-libxml-enno
#Requires: perl-libxml-perl
#Requires: perl-DateTime


%description legacy-workstation
Spacewalk Metadata for legacy developer workstation.  All dev packages
for a working development workstation are required by this package.
Supports the perl and python Spacewalk codebase.


%package java-workstation
Group: Spacewalk/Development
Summary: Spacewalk Metadata for java workstation.
Requires: java-devel >= 0:1.6.0
Requires: ant
Requires: ant-contrib
Requires: ant-junit
Requires: ant-jdepend
Requires: ant-apache-regexp
Requires: ant-nodeps
Requires: ant-jsch
#Requires: antlr
#Requires: bcel
Requires: checkstyle
Requires: ivy >= 1.4.1
#Requires: jakarta-commons-lang
#Requires: jakarta-commons-codec
#Requires: jakarta-commons-logging
#Requires: jakarta-commons-fileupload
Requires: jpam
#Requires: jsch
#Requires: jzlib
#Requires: log4j
#Requires: logdriver 
#Requires: servletapi5
#Requires: struts
Requires: tanukiwrapper
Requires: tomcat5 >= 0:5.5.26
#Requires: tomcat5-admin-webapps
#Requires: xalan-j2
#Requires: xerces-j2

Requires: spacewalk-metadata

%description java-workstation
Spacewalk Metadata for developer workstation.  All dev packages
for a working development workstation are required by this package.
Supports the Spacewalk JAVA codebase.

%prep
mkdir -p $RPM_BUILD_ROOT

%build

%install
rm -rf $RPM_BUILD_ROOT

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%doc

%files legacy-workstation
%defattr(-,root,root,-)
%doc

%files java-workstation
%defattr(-,root,root,-)
%doc

%changelog
* Fri Jul 11 2008 John Matthews <jmatthew@redhat.com> 1.1-11
- Getting devel env setup on Fedora 9
* Tue Jun 03 2008 Jesus Rodriguez <jesusr@redhat.com> 1.1-1
- Initial release based on rhn-metadata spec
