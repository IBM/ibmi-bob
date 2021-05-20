%undefine _disable_source_fetch
Name: bob
Version: 2.0.0
Release: 0
License: Apache-2.0
Summary: Better Object Builder for IBM i
Url: https://github.com/edmundreinhardt/Bob/


BuildRequires: make-gnu
BuildRequires: tar-gnu
BuildRequires: gzip
Requires: bash
Requires: coreutils-gnu
Requires: jq
Requires: sed-gnu
Requires: grep-gnu
Requires: gawk
Requires: make-gnu

Source0: https://github.com/edmundreinhardt/Bob/archive/refs/tags/v%{version}.tar.gz
Source1: https://github.com/BrianGarland/CRTFRMSTMF/archive/16db76aba5c94243396297f022a0dfc39dd4f8ee.tar.gz

%description
Trust me, good stuff.

%prep

%setup -n Bob-%{version}

%build
ls -la
echo "skipping build"

%install
rm -fr CRTFRMSTMF/*
tar xzvf %{SOURCE1} -C CRTFRMSTMF --strip-components=1
mkdir -p %{buildroot}%{_libdir}/bob
cp -r ./* %{buildroot}%{_libdir}/bob

%post -p %{_bindir}/bash
echo "post processing"

%files
%defattr(-, qsys, *none)
%{_libdir}/bob

%changelog
