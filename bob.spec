%undefine _disable_source_fetch
Name: bob
Version: 2.4.6
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
Requires: sed-gnu >= 4.4-1
Requires: grep-gnu >= 3.0-2
Requires: gawk >= 4.1.4-2
Requires: make-gnu >= 4.2-2
Requires: python3 >= 3.6
Requires: python3-ibm_db >= 2.0.5.12

Source0: https://github.com/IBM/ibmi-bob/archive/refs/tags/v%{version}.tar.gz

%description
Better Object Builder, or Bob, is a free and open source build system for the
IBM i platform that is used to build native "QSYS" objects.
Here's what makes Bob different.
- Speed. Bob only compiles objects that need recompiling, like from new or 
  changed source code.
- Reliability. Bob understands the relationships between your objects, so if an
  item changes, then it and everything depending on it will be rebuilt.
- Industry standard. Object dependencies are specified using standard makefile
  syntax, and the actual build engine is GNU Make -- exactly like tens of 
  thousands of Linux and Unix software projects.
- Flexibility. Most objects defined to Bob typically build using your default
  values. Have a program that requires a custom activation group or a data area
  that needs to be created with a certain value? No problem, overriding compile
  parameters is trivial, and writing custom recipes for special objects is very
  straightforward. If you can code it, you can build it.
- Ease of use. Invoking a build of an entire codebase is done with just a 
  single command.


%prep
%setup -n ibmi-bob-%{version}


%install
mkdir -p %{buildroot}%{_libdir}/bob
mkdir -p %{buildroot}%{_bindir}/
cp -r ./* %{buildroot}%{_libdir}/bob
ln -sf %{_libdir}/bob/scripts/makei %{buildroot}%{_bindir}/makei
ln -sf %{_libdir}/bob/scripts/crtfrmstmf %{buildroot}%{_bindir}/crtfrmstmf

%files
%defattr(-, qsys, *none)
%{_libdir}/bob
%{_bindir}/makei
%{_bindir}/crtfrmstmf

%changelog
* Mon Nov 14 2022 Edmund Reinhardt <edmund.reinhard@ca.ibm.com> - 2.4.6
- Update bob.spec
* Mon Nov 14 2022 Edmund Reinhardt <edmund.reinhard@ca.ibm.com> - 2.4.5
- BINDDIR source now has the file extension BINDIRSRC to differentiate it from the target object type BINDDIR
- That ability to build a directory or file via the makei compile -f <dir>:<file> to be able to build any arbitrary list of files and directories
- The iproj.json has additional attributes for iasp and sql attributes like current schema, path and sql vs system naming. (These are not yet supported within BOB, but are present for future extensibility and other tooling that will support them.
- Note for CL Pseudo source, make sure that you delete the target object before creating a new version to ensure the timestamps are accurate and the make processing works correctly
* Tue Oct 18 2022 Edmund Reinhardt <edmund.reinhard@ca.ibm.com> - 2.4.4
- evfevent files were missing filenames
- CCSID issues when downloading evfevent files
* Tue Oct 18 2022 Edmund Reinhardt <edmund.reinhard@ca.ibm.com> - 2.4.3
- fix dates in bob.spec
* Fri Oct 14 2022 Edmund Reinhardt <edmund.reinhard@ca.ibm.com> - 2.4.2
- lowercase file names and extensions supported
- support for lowercase filenames mapping to uppercase targets when compiling
- support of TGTCCSID specified by .ibmi.json for all source types
- support for INCDIR for all types including CLLE, CRTSQLxxxI, CRTRPGMOD
* Thu Sep 29 2022 Edmund Reinhardt <edmund.reinhard@ca.ibm.com> - 2.4.1
- Fix regression in building CMD, MENU and BNDDIR objects
* Mon Aug 22 2022 Tongkun Zhang <tongkun.zhang@ibm.com> - 2.4.0
- Use a larger margin for runsqlstmt
- Simplified Rules.mk syntax
- Allow creating target from the source with a different name
- Add indication for custom recipes
- Fix failed to add multiple preUsrLibl/postUsrLibl
- Fix not enabling the CompatibilityMode on IBM i 7.3
- Update code for IBM i documentation
- Set make path to QOpenSys
* Thu May 19 2022 Tongkun Zhang <tongkun.zhang@ibm.com> - 2.3.9
- Fix no authority to read QADBFDEP when getting PF dependencies
* Tue May 17 2022 Tongkun Zhang <tongkun.zhang@ibm.com> - 2.3.8
- Fix terminal color-support by Jesse Gorzinski
* Mon May 09 2022 Tongkun Zhang <tongkun.zhang@ibm.com> - 2.3.7
- Fix UTF-8 handling
* Mon May 09 2022 Tongkun Zhang <tongkun.zhang@ibm.com> - 2.3.6
- New documentation site is availabe at https://ibm.github.io/ibmi-bob/
- Do not generate .ibmi.json when invoking makei cvtsrcpf to avoid
  misleading as to when target CCSID is required
- Fix the encoding issue(#86) on machines without Utf-8 support
* Thu Apr 21 2022 Tongkun Zhang <tongkun.zhang@ibm.com> - 2.3.5
- Replace all the python3.9 shebang to python3.6
* Thu Apr 21 2022 Tongkun Zhang <tongkun.zhang@ibm.com> - 2.3.4
- Temporarily downgrade the Python version to 3.6 due to Ansible issues
- Simplify Makefiles
- Optimize outputs
- Wrap and expose crtsrcpf command in makei
- Fix wrong object mapping for sqltrg file type
- Fix not setting the curlib for RUNSQLSTM commands
* Wed Apr 13 2022 Tongkun Zhang <tongkun.zhang@ibm.com> - 2.3.3
- Fix the error when running makei build
* Thu Apr 07 2022 Tongkun Zhang <tongkun.zhang@ibm.com> - 2.3.2
- Update to 2.3.2
- Allow undefined values for includePath and postUsrLibl in
  iproj.json
- Use python39-ibm_db instead python3-ibm_db
- Fix missing execute permission on getJobLog
* Mon Apr 04 2022 Tongkun Zhang <tongkun.zhang@ibm.com> - 2.3.0
- Update to 2.3.0
- Upgrades to Python 3.9 since 3.6 is out of support
* Tue Mar 29 2022 Tongkun Zhang <tongkun.zhang@ibm.com> - 2.2.9
- Update to 2.2.9
- Rewrite CRTFRMSTMF using Python
- Expose CRTFRMSTMF as a CLI program
- Refactored makei interface
- Fix the issue that includePath is not respected by CRTBNDRPG
- Set the OBJLIB for RUNSQLSTM by temporarily changing the CURLIB
- Refactored code structure
- No longer expose launch program
* Thu Feb 10 2022 Tongkun Zhang <tongkun.zhang@ibm.com> - 2.2.8
- Update to 2.2.8
- Install CRTFRMSTMF by restoring from SAVF instead of compiling
- Suppress errors from jq
- Add include path and user libraries to VPATH
- Include more joblog information
- Set Bash 5.1-2 as the minimum
