Name:		spacewalkproject-java-packages-buildsetup
Version:	2.7
Release:	1%{?dist}
Summary:	Dist override for spacewalkproject/java-packages copr buildroot.

Group:		Applications/Internet
License:	GPLv2
URL:		https://github.com/spacewalkproject/spacewalk
BuildArch:      noarch

%description
%{summary}

%prep
# noop


%build
# noop


%install
for d in %{_prefix}/lib/rpm/macros.d %{_sysconfdir}/rpm ; do
  mkdir -p $RPM_BUILD_ROOT$d
  echo "%%dist .sw" >$RPM_BUILD_ROOT$d/macros.zz-dist-override
done

%files
%defattr(644, root, root)
%{_prefix}/lib/rpm/macros.d/macros.zz-dist-override
%{_sysconfdir}/rpm/macros.zz-dist-override


%changelog
