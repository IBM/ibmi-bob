%undefine _disable_source_fetch
Name: bob
Version: 2.2.8
Release: 0
License: Apache-2.0
Summary: Better Object Builder for IBM i
Url: https://github.com/IBM/ibmi-bob/


BuildRequires: make-gnu
BuildRequires: tar-gnu
BuildRequires: gzip
BuildRequires: bash >= 5.1-2
Requires: bash >= 5.1-2
Requires: coreutils-gnu >= 8.25-5
Requires: jq >= 1.6-2
Requires: db2util >= 1.0.12-1
Requires: sed-gnu >= 4.4-1
Requires: grep-gnu >= 3.0-2
Requires: gawk >= 4.1.4-2
Requires: make-gnu >= 4.2-2
Requires: python3 >= 3.6

Source0: https://github.com/IBM/ibmi-bob/archive/refs/tags/v%{version}.tar.gz
Source1: https://github.com/BrianGarland/CRTFRMSTMF/archive/master.tar.gz

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
# %setup -q
tar -xzvf %{SOURCE1}

%build
echo "skipping build"

%install
# tar -xzvf %{SOURCE1} -C CRTFRMSTMF-master --strip-components=1

# rm -fr sample-project test shunit2 shelic

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

cd %{_libdir}/bob/CRTFRMSTMF-master && %{_bindir}/gmake && cd ..

%files
%defattr(-, qsys, *none)
%{_libdir}/bob
%{_bindir}/launch
%{_bindir}/makei
%changelog

%changelog
* Thu Feb 10 2022 Tongkun Zhang <tongkun.zhang@ibm.com> - 2.2.8
- Update to 2.2.8
- Suppress errors from jq
- Add include path and user libraries to VPATH
- Include more joblog information
- Set Bash 5.1-2 as the minimum
