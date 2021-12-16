%undefine _disable_source_fetch
Name: bob
Version: 2.2.1
Release: 0
License: Apache-2.0
Summary: Better Object Builder for IBM i
Url: https://github.com/IBM/ibmi-bob/


BuildRequires: make-gnu
BuildRequires: tar-gnu
BuildRequires: gzip
BuildRequires: bash >= 4.4-6
Requires: bash >= 4.4-6
Requires: coreutils-gnu
Requires: jq
Requires: db2util
Requires: sed-gnu
Requires: grep-gnu
Requires: gawk
Requires: make-gnu
Requires: python3 >= 3.4

Source0: https://github.com/IBM/ibmi-bob/archive/refs/tags/v%{version}.tar.gz
Source1: https://github.com/BrianGarland/CRTFRMSTMF/archive/119536521de4ee905dcf8e65271ea98d40186c6e.tar.gz

%description
Better Object Builder, or Bob, is a free and open source build system for the IBM i platform that is used to build native "QSYS" objects.
Here's what makes Bob different.
- Speed. Bob only compiles objects that need recompiling, like from new or changed source code.
- Reliability. Bob understands the relationships between your objects, so if an item changes, then it and everything depending on it will be rebuilt.
- Industry standard. Object dependencies are specified using standard makefile syntax, and the actual build engine is GNU Make -- exactly like tens of thousands of Linux and Unix software projects.
- Flexibility. Most objects defined to Bob typically build using your default values. Have a program that requires a custom activation group or a data area that needs to be created with a certain value? No problem, overriding compile parameters is trivial, and writing custom recipes for special objects is very straightforward. If you can code it, you can build it.
- Ease of use. Invoking a build of an entire codebase is done with just a single command. Or, if the Rational Developer for i integration pieces are installed, a single button click.

%prep

%setup -n ibmi-bob-%{version}

%build
echo "skipping build"

%install
tar xzvf %{SOURCE1} -C CRTFRMSTMF --strip-components=1

rm -fr sample-project test shunit2 shelic

mkdir -p %{buildroot}%{_libdir}/bob
mkdir -p %{buildroot}%{_bindir}/
cp -r ./* %{buildroot}%{_libdir}/bob
ln -sf %{_libdir}/bob/makei %{buildroot}%{_bindir}/makei
ln -sf %{_libdir}/bob/launch %{buildroot}%{_bindir}/launch

%post -p %{_bindir}/bash
if [ ! -d "/QSYS.LIB/CRTFRMSTMF.LIB" ]
then
    cl "CRTLIB LIB(CRTFRMSTMF) TEXT('Library for CRTFRMSTMF command')"
else
    rm -rf /QSYS.LIB/CRTFRMSTMF.LIB/*
fi

cd %{_libdir}/bob/CRTFRMSTMF && %{_bindir}/gmake && cd ..

%files
%defattr(-, qsys, *none)
%{_libdir}/bob
%{_bindir}/launch
%{_bindir}/makei
%changelog
