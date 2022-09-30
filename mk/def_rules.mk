COLOR := \033[33;40m
ERROR_COLOR := \033[31;49;1m
SUCCESS_COLOR := \033[32;49;1m
NOCOLOR := \033[0m
ifndef COLOR_TTY
COLOR_TTY := $(shell [ -t 1 ] && echo true)
endif

SYS_ENCODING := $(shell  /QOpenSys/pkgs/bin/python3.6  -c "import sys;print(sys.getdefaultencoding())")
ifndef UTF8_SUPPORT
	ifneq (,$(findstring utf-8,$(SYS_ENCODING)))
		UTF8_SUPPORT := true
	else
		UTF8_SUPPORT := false
	endif
endif

ifeq ($(UTF8_SUPPORT),true)
SUCCESSMARKER = ✓
FAILMARKER = ✕
else
SUCCESSMARKER = [SUCCESS]
FAILMARKER = [FAIL]
endif

ifneq ($(VERBOSE),true)
ifneq ($(strip $(TOP_BUILD_DIR)),)
  strip_top = $(subst $(TOP)/,,$(subst $(TOP_BUILD_DIR)/,,$(1)))
else
  strip_top = $(subst $(TOP)/,,$(1))
endif
ifeq ($(COLOR_TTY),true)
echo_prog := $(shell if echo -e | grep -q -- -e; then echo echo; else echo echo -e; fi)
echo_cmd = $(echo_prog) "$(COLOR)$(call strip_top,$(1))$(NOCOLOR)";
echo_success_cmd = ($(echo_prog) "$(SUCCESS_COLOR)$(SUCCESSMARKER) $(call strip_top,$(1))$(NOCOLOR)" && echo)
echo_error_cmd = ($(echo_prog) "$(ERROR_COLOR)$(FAILMARKER) $(call strip_top,$(1))$(NOCOLOR)" && echo)
else
echo_cmd = @echo "$(call strip_top,$(1))";
echo_success_cmd = (echo "$(SUCCESSMARKER) $(call strip_top,$(1))" && echo)
echo_error_cmd = (echo "$(FAILMARKER) $(call strip_top,$(1))" && echo)
endif
else # Verbose output
echo_cmd =
endif

empty :=
space :=$(empty) $(empty)
uniq = $(if $1,$(firstword $1) $(call uniq,$(filter-out $(firstword $1),$1)))

# The extractName and extractTextDescriptor are used to decompose the long filename into module name and
# the text descriptor.
# e.g. CUSTOME1-Customer_file.LF has `CUSTOME1` as the module name and `Customer file` as the text descriptor


# The following logs to stdout is parsed and used by the makei program. Check makei.BuildEnv.make before making changes!
define logSuccess =
$(call echo_success_cmd,"$1 was created successfully!")
endef
define logFail =
$(call echo_error_cmd,"Failed to create $1!")
endef

define extractName = 
echo '$(notdir $<)' | awk -F- '{ print $$1 }'
endef
define extractTextDescriptor =
if [[ "$(notdir $<)" == *"-"* ]]; then
	echo '$(notdir $<)' | awk -F- '{ i = index($$0,"-");print substr($$0,i+1)}' | sed -e 's/\.[^.]*$$//' -e 's/_/\ /g';
fi
endef

define genDep
$(eval d = $($(1)_d))$(eval tmpName = $(wildcard $d/$2-*.$3))$(if $(tmpName),$(tmpName),$d/$2.$3)
endef

define getLibPath
 $(addsuffix .LIB,$(addprefix /QSYS.LIB/,$(1)))
endef

# define inheritValue
# $(eval k = $1)$(eval d = $2)$(if $($(k)_$(d)),$($(k)_$(d)),$(call inheritValue,$(k),$(realpath $(dir $(d)))))
# endef


# These variables are swapped into the compile commands.  Their values also serve as
# global defaults that can be overridden on a per-object basis by setting target-specific
# variables, e.g. `MYPGM.PGM: private TGTRLS = V7R1M0`.  They can also be overridden on a
# per-object-type basis by setting pattern-specific variables, e.g.
# `%.SRVPGM: private ACTGRP = $(SRVPGM_ACTGRP)` (A variable is used in the assignment
# instead of a constant so that all settings are defined in one place, at the top.)
# tl;dr: If you want to customize a compile setting for an object, change these variables
# in your TARGET (not here).
ACTGRP := 
AUT := 
BNDDIR :=
COMMIT := *NONE
CURLIB :=
DBGVIEW := *ALL
DETAIL := *EXTENDED
DFTACTGRP := *NO
DLTPCT := *NONE
HLPID =
HLPPNLGRP =
OBJTYPE :=
OPTION := *EVENTF
PAGESIZE :=
PGM :=
PMTFILE :=
PRDLIB :=
REUSEDLT := *NO
RPGPPOPT :=
RSTDSP :=
SIZE :=
STGMDL := *SNGLVL
SYSIFCOPT :=
TERASPACE :=
TEXT = $(shell $(extractTextDescriptor))
TYPE :=
TGTCCSID = $(TGTCCSID_$(d))
TGTRLS := 
VLDCKR :=

# Object-type-specific defaults.  Not used directly, but copied to the standard ones above and then
# inserted into the compile commands.  Each variable here should also precede its corresponding pattern
# rule as a pattern-specific variable. Change these to alter compile defaults for an entire type of
# object.
BNDCL_ACTGRP := $(ACTGRP)
BNDCL_AUT := $(AUT)
BNDCL_DBGVIEW := $(DBGVIEW)
BNDCL_DFTACTGRP := $(DFTACTGRP)
BNDCL_OPTION := $(OPTION)
BNDCL_TGTRLS := $(TGTRLS)

BNDRPG_ACTGRP := $(ACTGRP)
BNDRPG_AUT := $(AUT)
BNDRPG_DBGVIEW := $(DBGVIEW)
BNDRPG_DFTACTGRP := $(DFTACTGRP)
BNDRPG_OPTION := $(OPTION)
BNDRPG_TGTRLS := $(TGTRLS)

CMD_AUT := $(AUT)
CMD_HLPID = $(basename $@)
CMD_HLPPNLGRP = $(basename $@)
CMD_PGM = $(basename $@)
CMD_PMTFILE := *NONE
CMD_VLDCKR := *NONE

CMOD_AUT := $(AUT)
CMOD_DBGVIEW := $(DBGVIEW)
CMOD_OPTION := *EVENTF *SHOWUSR *XREF *AGR
CMOD_INCDIR := $(INCDIR)
CMOD_STGMDL := *INHERIT
CMOD_SYSIFCOPT := *IFS64IO
CMOD_TERASPACE := *YES *NOTSIFC
CMOD_TGTRLS := $(TGTRLS)

CRTPGM_OPTION := $(OPTION)
ifeq ($(COMPATIBILITYMODE), true)
CRTPGM_OPTION :=
endif

CLMOD_AUT := $(AUT)
CLMOD_DBGVIEW := $(DBGVIEW)
CLMOD_OPTION := $(OPTION)
CLMOD_INCDIR := $(INCDIR)
CLMOD_TGTRLS := $(TGTRLS)

DSPF_AUT := $(AUT)
DSPF_OPTION := *EVENTF *SRC *LIST
DSPF_RSTDSP := *YES

LF_AUT := $(AUT)
LF_OPTION := *EVENTF *SRC *LIST

MNU_AUT := $(AUT)
MNU_CURLIB := *NOCHG
MNU_OPTION := *EVENTF *SRC
MNU_PRDLIB := *NOCHG
MNU_TYPE := *UIM

PNLGRP_AUT := $(AUT)
PNLGRP_OPTION := *EVENTF *SRC

PF_AUT := $(AUT)
PF_DLTPCT := $(DLTPCT)
PF_OPTION := *EVENTF *SRC *LIST
PF_REUSEDLT := $(REUSEDLT)
PF_SIZE :=

PGM_ACTGRP := $(ACTGRP)
PGM_AUT := $(AUT)
PGM_DETAIL := $(DETAIL)
PGM_OPTION := *EVENTF
PGM_STGMDL := *SNGLVL
PGM_TGTRLS := $(TGTRLS)

CBL_OPTION := *SRCDBG
CBL_INCDIR := $(INCDIR)
RPG_OPTION := *SRCDBG

PRTF_AUT := $(AUT)
PRTF_OPTION := *EVENTF *SRC *LIST
PRTF_PAGESIZE := 66 132

QMQRY_AUT := $(AUT)

RPGMOD_AUT := $(AUT)
RPGMOD_DBGVIEW := $(DBGVIEW)
RPGMOD_OPTION := $(OPTION)
RPGMOD_TGTRLS := $(TGTRLS)

SQLCIMOD_DBGVIEW := *SOURCE
SQLCIMOD_OBJTYPE := *MODULE
SQLCIMOD_OPTION := $(CMOD_OPTION)
SQLCIMOD_INCDIR := $(INCDIR)
SQLCIMOD_STGMDL := $(CMOD_STGMDL)
SQLCIMOD_SYSIFCOPT := $(CMOD_SYSIFCOPT)
SQLCIMOD_TERASPACE := *YES *TSIFC
SQLCIMOD_TGTRLS := $(TGTRLS)

SQLCIPGM_DBGVIEW := *SOURCE
SQLCIPGM_OBJTYPE := *PGM
SQLCIPGM_OPTION := $(OPTION)
SQLCIPGM_TGTRLS := $(TGTRLS)

SQLRPGIMOD_DBGVIEW := *SOURCE
SQLRPGIMOD_OBJTYPE := *MODULE
SQLRPGIMOD_OPTION := $(RPGMOD_OPTION)
SQLRPGIMOD_RPGPPOPT := *LVL2
SQLRPGIMOD_TGTRLS := $(TGTRLS)

SQLRPGIPGM_DBGVIEW := *SOURCE
SQLRPGIPGM_OBJTYPE := *PGM
SQLRPGIPGM_OPTION := $(OPTION)
SQLRPGIPGM_RPGPPOPT := *LVL2
SQLRPGIPGM_TGTRLS := $(TGTRLS)

SRVPGM_ACTGRP := *CALLER
SRVPGM_AUT := $(AUT)
SRVPGM_BNDDIR := *NONE
SRVPGM_DETAIL := *BASIC
SRVPGM_STGMDL := $(STGMDL)
SRVPGM_TGTRLS := $(TGTRLS)

WSCST_AUT := $(AUT)

# Creation command parameters with variables (the ones listed at the top) for the most common ones.
CRTCLMODFLAGS = AUT($(AUT)) DBGVIEW($(DBGVIEW)) OPTION($(OPTION)) TEXT('$(TEXT)') TGTRLS($(TGTRLS)) INCDIR($(INCDIR))
CRTCMDFLAGS = PGM($(PGM)) VLDCKR($(VLDCKR)) PMTFILE($(PMTFILE)) HLPPNLGRP($(HLPPNLGRP)) HLPID($(HLPID)) AUT($(AUT)) TEXT('$(TEXT)')
CRTCMODFLAGS = TERASPACE($(TERASPACE)) STGMDL($(STGMDL)) OUTPUT(*PRINT) OPTION($(OPTION)) DBGVIEW($(DBGVIEW)) \
               SYSIFCOPT($(SYSIFCOPT)) AUT($(AUT)) TEXT('$(TEXT)') TGTCCSID($(TGTCCSID)) TGTRLS($(TGTRLS)) INCDIR($(INCDIR))
CRTDSPFFLAGS = ENHDSP(*YES) RSTDSP($(RSTDSP)) DFRWRT(*YES) AUT($(AUT)) OPTION($(OPTION)) TEXT('$(TEXT)')
CRTLFFLAGS = AUT($(AUT)) OPTION($(OPTION)) TEXT('$(TEXT)')
CRTMNUFLAGS = AUT($(AUT)) OPTION($(OPTION)) CURLIB($(CURLIB)) PRDLIB($(PRDLIB)) TEXT('$(TEXT)') TYPE($(TYPE))
CRTPFFLAGS = AUT($(AUT)) DLTPCT($(DLTPCT)) OPTION($(OPTION)) REUSEDLT($(REUSEDLT)) SIZE($(SIZE)) TEXT('$(TEXT)')
CRTPGMFLAGS = ACTGRP($(ACTGRP)) USRPRF(*USER) TGTRLS($(TGTRLS)) AUT($(AUT)) DETAIL($(DETAIL)) OPTION($(CRTPGM_OPTION)) STGMDL($(STGMDL)) TEXT('$(TEXT)')
CRTPNLGRPFLAGS = AUT($(AUT)) OPTION($(OPTION)) TEXT('$(TEXT)')
CRTCBLPGMFLAGS = OPTION($(OPTION)) TEXT('$(TEXT)')
CRTPRTFFLAGS = AUT($(AUT)) OPTION($(OPTION)) PAGESIZE($(PAGESIZE)) TEXT('$(TEXT)')
CRTRPGMODFLAGS = AUT($(AUT)) DBGVIEW($(DBGVIEW)) OPTION($(OPTION)) OUTPUT(*PRINT) TEXT('$(TEXT)') \
                 TGTCCSID($(TGTCCSID)) TGTRLS($(TGTRLS))
CRTQMQRYFLAGS = AUT($(AUT)) TEXT('$(TEXT)')
CRTSQLCIFLAGS = COMMIT($(COMMIT)) OBJTYPE($(OBJTYPE)) OUTPUT(*PRINT) TEXT('$(TEXT)') TGTRLS($(TGTRLS)) DBGVIEW($(DBGVIEW)) \
                COMPILEOPT('INCDIR(''$(INCDIR)'') OPTION($(OPTION)) STGMDL($(STGMDL)) SYSIFCOPT($(SYSIFCOPT)) \
                            TGTCCSID($(TGTCCSID)) TERASPACE($(TERASPACE)) INCDIR($(INCDIR))
CRTSQLRPGIFLAGS = COMMIT($(COMMIT)) OBJTYPE($(OBJTYPE)) OPTION($(OPTION)) OUTPUT(*PRINT) TEXT('$(TEXT)') \
                  TGTRLS($(TGTRLS)) DBGVIEW($(DBGVIEW)) RPGPPOPT($(RPGPPOPT)) \
                  COMPILEOPT('TGTCCSID($(TGTCCSID))')
CRTSRVPGMFLAGS = ACTGRP($(ACTGRP)) TEXT('$(TEXT)') TGTRLS($(TGTRLS)) AUT($(AUT)) DETAIL($(DETAIL)) STGMDL($(STGMDL))
CRTWSCSTFLAGS = AUT($(AUT)) TEXT('$(TEXT)')
CRTBNDRPGFLAGS:= DBGVIEW($(DBGVIEW)) TGTCCSID($(TGTCCSID)) OPTION($(OPTION)) TEXT('$(TEXT)') INCDIR($(INCDIR))
CRTBNDCFLAGS:=TGTCCSID($(TGTCCSID)) OPTION($(OPTION)) TEXT('$(TEXT)')
RUNSQLFLAGS:= DBGVIEW(*SOURCE) TGTRLS($(TGTRLS)) OUTPUT(*PRINT) MARGINS(1024)

# Extra command string for adhoc addition of extra parameters to a creation command.
ADHOCCRTFLAGS =

# Miscellaneous variables
SRCPATH := $(TOP)
OBJPATH = $(OBJPATH_$(d))
CURLIB :=
# IBMiEnvCmd :=
# override OBJPATH = $(shell echo "$(OBJPATH)" | tr '[:lower:]' '[:upper:]')
OBJLIB = $(basename $(notdir $(OBJPATH)))
LIBL = $(OBJLIB)
# preUsrlibl :=
# postUsrlibl :=
TOOLSPATH := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
TOOLSLIB := BOBTOOLS
runDate := $(shell date +"%F_%H.%M.%S-%a")
LOGPATH := $(TOP)/.logs
LOGFILE := $(LOGPATH)/output.log
JOBLOGFILE := $(LOGPATH)/joblog.json
$(shell mkdir -p $(LOGPATH))
# $(info IBMiMake log directory: $(LOGPATH))
DEPDIR := $(SRCPATH)/.deps
$(shell mkdir -p $(DEPDIR) >/dev/null)
EVTDIR := $(SRCPATH)/.evfevent
$(shell mkdir -p $(EVTDIR) >/dev/null)
CRTFRMSTMFLIB := CRTFRMSTMF
ICONV := /QOpenSys/usr/bin/iconv
ICONV_EBCDIC := IBM-037
ICONV_ASCII := UTF-8
SETCCSID_ASCII := 1208
PREUSRLIBLPATH = $(call getLibPath,$(preUsrlibl))
POSTUSRLIBLPATH = $(call getLibPath,$(postUsrlibl))
CURLIBPATH = $(call getLibPath,$(curlib))

VPATH = $(subst $(space),:,$(strip $(call uniq,$(INCDIR) $(PREUSRLIBLPATH) $(CURLIBPATH) $(POSTUSRLIBLPATH) $(OBJPATH) $(SRCPATH))))
define PRESETUP = 
echo -e "$(crtcmd)"; \
curlib="$(curlib)" \
preUsrlibl="$(preUsrlibl)" \
postUsrlibl="$(postUsrlibl)" \
IBMiEnvCmd="$(IBMiEnvCmd)"
endef

define SETCURLIBTOOBJLIB = 
tmpCurlib="${OBJLIB}"
endef

# cleanCDeps removes from the CRTCMOD-generated dependency file any header files located in /QIBM/, plus the
# original .C file that is included for some reason, and adds the correct suffix to the target (SO1001 -> SO1001.MODULE).
cleanCDeps = awk '$$2 !~ /^\/QIBM\// && $$2 !~ /$(notdir $<)$$/ && $$2 !~ /$(basename $(notdir $<)).MBR$$/ { sub("^.*/","",$$2); sub("^$*","$@",$$1); print $$1 " " toupper($$2) }'

# This defines the steps taken after a C compile to massage the auto-generated dependencies into a useable form.
# See http://make.mad-scientist.net/papers/advanced-auto-dependency-generation/#tldr
define POSTCCOMPILE =

endef

# cleanRPGDeps removes from the CRTRPGMOD- and CRTSQLRPGI-generated events file any system header files
# plus any SQL precompiler-generated source member, and returns what's left.
cleanRPGDeps = awk '$$1 == "FILEID" && $$6 !~ /^QTEMP/ && toupper($$6) !~ /QSYS/ && $$6 !~ /EVFTEMPF0[12]/ && $$6 !~ /$(basename $(notdir $<)).MBR$$/ { print toupper($$6) }'

# This defines the steps taken after an RPG compile to scrape dependencies from the EVFEVENT file and turn them
# into a useable form.
# See http://make.mad-scientist.net/papers/advanced-auto-dependency-generation/#tldr
# In a nutshell, retrieve the flattened list of include files from the EVFEVENT file, then for each one discover
# if any externally-described files are declared.  If so, isolate the actual source file name from its path,
# convert everything to upper case, format in makefile dependency format, and output all these dependencies
# to a file that will be included by Make.
define EVFEVENT_DOWNLOAD =
system "CPYTOSTMF FROMMBR('$(OBJPATH)/EVFEVENT.FILE/$(basename $@).MBR') TOSTMF('$(EVTDIR)/$1') STMFCCSID(*STDASCII) ENDLINFMT(*LF) CVTDTA(*AUTO) STMFOPT(*REPLACE)" >/dev/null
endef
# define POSTRPGCOMPILE =
# $(call EVFEVENT_DOWNLOAD,$*.evfevent.evfevent);
# endef

# Deletes .d dependency file if it's empty.
define removeEmptyDep =
if [ ! -s $(DEPDIR)/$(basename $@).d ]; then \
  rm $(DEPDIR)/$(basename $@).d; \
fi
endef

# Commands to generate typedef structure for *FILE objects (for use by C code)
# Create struct via GENCSRC command, then strip out comments and compare with existing struct; only replace existing file if something has changed.
define TYPEDEF_SCRIPT =
if [ "$(suffix $<)" = '.PRTF' ]; then SLTFLD='*OUTPUT'; else SLTFLD='*BOTH *KEY'; fi; system -v "GENCSRC OBJ('$(OBJPATH)/$@') SRCSTMF('$<.TH') SLTFLD($$SLTFLD) TYPEDEFPFX('$(basename $@)')" > /dev/null
(file=$(subst .,_,$(notdir $<))_H; echo "#ifndef $${file}"; echo "   #define $${file}"; $(ICONV) -f $(ICONV_EBCDIC) -t $(ICONV_ASCII) $<.TH | tr -d '\r' | sed -e '/^ *int/ s/;     /;/' -e '/^ *int/ s/int/long int/'; echo "#endif  /* $${file} */") > $<.H1
rm $<.TH
if [ -f "$<.H" ]; then sed -e '/^\/\//d' $<.H >$<.H-old; fi
sed -e '/^\/\//d' $<.H1 >$<.H-new
if ! cmp $<.H-new $<.H-old >/dev/null 2>&1; then mv -f $<.H1 $<.H; echo "*** Created new typedef file $<.H for file [$(tgt)]"; fi
if [ -f "$<.H-old" ]; then rm "$<.H-old"; fi
if [ -f "$<.H-new" ]; then rm "$<.H-new"; fi
if [ -f "$<.H1" ]; then rm "$<.H1"; fi
endef

# Can't specify our default ACTGRP value if DFTACTGRP(*YES) is specified.
derive_ACTGRP = $(if $(filter *YES,$(DFTACTGRP)),,$(ACTGRP))

# Insure that the CCSID attribute of a source file matches what we know its encoding to be.  This attribute
# gets reset to a default value each time a file is placed into the IFS.  The attribute must match the actual
# encoding in order for compile commands that support stream files to work.  Only attempt setting IFS files.
define set_STMF_CCSID =
-setccsid $(SETCCSID_ASCII) $(filter-out /QSYS.LIB/%,$(realpath $^))
endef

# These variables allow pattern-specific variables to be used when multiple source patterns exist for one object pattern (like with *FILEs, which can be PFs, LFs, DSPFs, etc.).
# The pattern-specific variable will set itself to a variable below, which will then be evaluated
# from the context of that pattern-matched rule. This can be used to set specific compile parameters
# for each type of, for example, file object (PF, LF, DSPF, etc.).
# The advantage of this approach over simply hard-coding values in the recipe is that individual targets (compiled objects)
# will be able to override these values with their own, thereby overriding these defaults.
# This elaborate construct is to work around a limitation in Make (`%.object: %.source variable=value` does not work; it
# effectively resolves to `%.object: variable=value`).
#
# Determine default settings for the various source types that can make a file object.
fileAUT = $(strip \
	$(if $(filter %.DSPF,$<),$(DSPF_AUT), \
	$(if $(filter %.LF,$<),$(LF_AUT), \
	$(if $(filter %.PF,$<),$(PF_AUT), \
	$(if $(filter %.PRTF,$<),$(PRTF_AUT), \
	UNKNOWN_FILE_TYPE)))))
fileDLTPCT = $(strip \
	$(if $(filter %.PF,$<),$(PF_DLTPCT), \
	UNKNOWN_FILE_TYPE))
fileOPTION = $(strip \
	$(if $(filter %.DSPF,$<),$(DSPF_OPTION), \
	$(if $(filter %.LF,$<),$(LF_OPTION), \
	$(if $(filter %.PF,$<),$(PF_OPTION), \
	$(if $(filter %.PRTF,$<),$(PRTF_OPTION), \
	UNKNOWN_FILE_TYPE)))))
filePAGESIZE = $(strip \
	$(if $(filter %.PRTF,$<),$(PRTF_PAGESIZE), \
	UNKNOWN_FILE_TYPE))
fileREUSEDLT = $(strip \
	$(if $(filter %.PF,$<),$(PF_REUSEDLT), \
	UNKNOWN_FILE_TYPE))
fileRSTDSP = $(strip \
	$(if $(filter %.DSPF,$<),$(DSPF_RSTDSP), \
	UNKNOWN_FILE_TYPE))
fileSIZE = $(strip \
	$(if $(filter %.PF,$<),$(PF_SIZE), \
	UNKNOWN_FILE_TYPE))

# Determine default settings for the various source types that can make a module object.
moduleAUT = $(strip \
	$(if $(filter %.C,$<),$(CMOD_AUT), \
	$(if $(filter %.CLLE,$<),$(CLMOD_AUT), \
	$(if $(filter %.RPGLE,$<),$(RPGMOD_AUT), \
	UNKNOWN_FILE_TYPE))))
moduleDBGVIEW = $(strip \
	$(if $(filter %.C,$<),$(CMOD_DBGVIEW), \
	$(if $(filter %.CLLE,$<),$(CLMOD_DBGVIEW), \
	$(if $(filter %.RPGLE,$<),$(RPGMOD_DBGVIEW), \
	$(if $(filter %.SQLC,$<),$(SQLCIMOD_DBGVIEW), \
	$(if $(filter %.SQLRPGLE,$<),$(SQLRPGIMOD_DBGVIEW), \
	UNKNOWN_FILE_TYPE))))))
moduleOBJTYPE = $(strip \
	$(if $(filter %.SQLC,$<),$(SQLCIMOD_OBJTYPE), \
	$(if $(filter %.SQLRPGLE,$<),$(SQLRPGIMOD_OBJTYPE), \
	UNKNOWN_FILE_TYPE)))
moduleOPTION = $(strip \
	$(if $(filter %.C,$<),$(CMOD_OPTION), \
	$(if $(filter %.CLLE,$<),$(CLMOD_OPTION), \
	$(if $(filter %.RPGLE,$<),$(RPGMOD_OPTION), \
	$(if $(filter %.SQLC,$<),$(SQLCIMOD_OPTION), \
	$(if $(filter %.SQLRPGLE,$<),$(SQLRPGIMOD_OPTION), \
	UNKNOWN_FILE_TYPE))))))
moduleINCDIR = $(strip \
	$(if $(filter %.C,$<),$(CMOD_INCDIR), \
	$(if $(filter %.CLLE,$<),$(CLMOD_INCDIR), \
	$(if $(filter %.CBLLE,$<),$(CBLMOD_INCDIR), \
	$(if $(filter %.SQLC,$<),$(SQLCIMOD_INCDIR), \
	UNKNOWN_FILE_TYPE)))))
moduleRPGPPOPT = $(strip \
	$(if $(filter %.SQLRPGLE,$<),$(SQLRPGIMOD_RPGPPOPT), \
	UNKNOWN_FILE_TYPE))
moduleSTGMDL = $(strip \
	$(if $(filter %.C,$<),$(CMOD_STGMDL), \
	$(if $(filter %.SQLC,$<),$(SQLCIMOD_STGMDL), \
	UNKNOWN_FILE_TYPE)))
moduleSYSIFCOPT = $(strip \
	$(if $(filter %.C,$<),$(CMOD_SYSIFCOPT), \
	$(if $(filter %.SQLC,$<),$(SQLCIMOD_SYSIFCOPT), \
	UNKNOWN_FILE_TYPE)))
moduleTERASPACE = $(strip \
	$(if $(filter %.C,$<),$(CMOD_TERASPACE), \
	$(if $(filter %.SQLC,$<),$(SQLCIMOD_TERASPACE), \
	UNKNOWN_FILE_TYPE)))
moduleTGTRLS = $(strip \
	$(if $(filter %.C,$<),$(CMOD_TGTRLS), \
	$(if $(filter %.CLLE,$<),$(CLMOD_TGTRLS), \
	$(if $(filter %.RPGLE,$<),$(RPGMOD_TGTRLS), \
	$(if $(filter %.SQLC,$<),$(SQLCIMOD_TGTRLS), \
	$(if $(filter %.SQLRPGLE,$<),$(SQLRPGIMOD_TGTRLS), \
	UNKNOWN_FILE_TYPE))))))

# Determine default settings for the various source types that can make a program object.
programACTGRP = $(strip \
	$(if $(filter %.CLLE,$<),$(BNDCL_ACTGRP), \
	$(if $(filter %.RPGLE,$<),$(BNDRPG_ACTGRP), \
	$(if $(filter %.MODULE,$<),$(PGM_ACTGRP), \
	UNKNOWN_FILE_TYPE))))
programAUT = $(strip \
	$(if $(filter %.CLLE,$<),$(BNDCL_AUT), \
	$(if $(filter %.RPGLE,$<),$(BNDRPG_AUT), \
	$(if $(filter %.MODULE,$<),$(PGM_AUT), \
	UNKNOWN_FILE_TYPE))))
programDBGVIEW = $(strip \
	$(if $(filter %.CLLE,$<),$(BNDCL_DBGVIEW), \
	$(if $(filter %.RPGLE,$<),$(BNDRPG_DBGVIEW), \
	$(if $(filter %.SQLC,$<),$(SQLCIPGM_DBGVIEW), \
	$(if $(filter %.SQLRPGLE,$<),$(SQLRPGIPGM_DBGVIEW), \
	UNKNOWN_FILE_TYPE)))))
programDETAIL = $(strip \
	$(if $(filter %.MODULE,$<),$(PGM_DETAIL), \
	UNKNOWN_FILE_TYPE))
programDFTACTGRP = $(strip \
	$(if $(filter %.CLLE,$<),$(BNDCL_DFTACTGRP), \
	$(if $(filter %.RPGLE,$<),$(BNDRPG_DFTACTGRP), \
	UNKNOWN_FILE_TYPE)))
programOBJTYPE = $(strip \
	$(if $(filter %.SQLC,$<),$(SQLCIPGM_OBJTYPE), \
	$(if $(filter %.SQLRPGLE,$<),$(SQLRPGIPGM_OBJTYPE), \
	UNKNOWN_FILE_TYPE)))
programOPTION = $(strip \
	$(if $(filter %.CLLE,$<),$(BNDCL_OPTION), \
	$(if $(filter %.RPGLE,$<),$(BNDRPG_OPTION), \
	$(if $(filter %.SQLC,$<),$(SQLCIPGM_OPTION), \
	$(if $(filter %.SQLRPGLE,$<),$(SQLRPGIPGM_OPTION), \
	$(if $(filter %.MODULE,$<),$(PGM_OPTION), \
	$(if $(filter %.CBL,$<),$(CBL_OPTION), \
	$(if $(filter %.RPG,$<),$(RPG_OPTION), \
	UNKNOWN_FILE_TYPE))))))))
programRPGPPOPT = $(strip \
	$(if $(filter %.SQLRPGLE,$<),$(SQLRPGIPGM_RPGPPOPT), \
	UNKNOWN_FILE_TYPE))
programSTGMDL = $(strip \
	$(if $(filter %.MODULE,$<),$(PGM_STGMDL), \
	UNKNOWN_FILE_TYPE))
programTGTRLS = $(strip \
	$(if $(filter %.CLLE,$<),$(BNDCL_TGTRLS), \
	$(if $(filter %.RPGLE,$<),$(BNDRPG_TGTRLS), \
	$(if $(filter %.SQLC,$<),$(SQLCIPGM_TGTRLS), \
	$(if $(filter %.SQLRPGLE,$<),$(SQLRPGIPGM_TGTRLS), \
	$(if $(filter %.MODULE,$<),$(PGM_TGTRLS), \
	UNKNOWN_FILE_TYPE))))))


#    ____ __  __ ____    ____           _                 
#   / ___|  \/  |  _ \  |  _ \ ___  ___(_)_ __   ___  ___ 
#  | |   | |\/| | | | | | |_) / _ \/ __| | '_ \ / _ \/ __|
#  | |___| |  | | |_| | |  _ <  __/ (__| | |_) |  __/\__ \
#   \____|_|  |_|____/  |_| \_\___|\___|_| .__/ \___||___/
#                                        |_|              

define CMDSRC_TO_CMD_RECIPE = 
	$(eval AUT = $(CMD_AUT))
	$(eval HLPID = $(CMD_HLPID))
	$(eval HLPPNLGRP = $(CMD_HLPPNLGRP))
	$(eval PGM = $(CMD_PGM))
	$(eval PMTFILE = $(CMD_PMTFILE))
	$(eval VLDCKR = $(CMD_VLDCKR))
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Creating command [$(notdir $<)]")
	@$(set_STMF_CCSID)
	$(eval crtcmd := CRTCMD CMD($(OBJLIB)/$(basename $(@F))) srcstmf('$<') $(CRTCMDFLAGS))
	@$(PRESETUP) \
	$(SCRIPTSPATH)/launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@);
endef




#   _____ ___ _     _____   ____           _                 
#  |  ___|_ _| |   | ____| |  _ \ ___  ___(_)_ __   ___  ___ 
#  | |_   | || |   |  _|   | |_) / _ \/ __| | '_ \ / _ \/ __|
#  |  _|  | || |___| |___  |  _ <  __/ (__| | |_) |  __/\__ \
#  |_|   |___|_____|_____| |_| \_\___|\___|_| .__/ \___||___/
#                                           |_|              
                                            
define FILE_VARIABLES = 
	$(eval AUT = $(fileAUT))\
	$(eval DLTPCT = $(fileDLTPCT))\
	$(eval OPTION = $(fileOPTION))\
	$(eval PAGESIZE = $(filePAGESIZE))\
	$(eval REUSEDLT = $(fileREUSEDLT))\
	$(eval RSTDSP = $(fileRSTDSP))\
	$(eval SIZE = $(fileSIZE))\
	$(eval TYPEDEF = $(if $(filter YES,$(CREATE_TYPEDEF)),$(TYPEDEF_SCRIPT),))
endef

define DSPF_TO_FILE_RECIPE =
	$(FILE_VARIABLES)
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Creating DSPF [$(notdir $<)]")
	@$(set_STMF_CCSID)
	$(eval crtcmd := "$(SCRIPTSPATH)/crtfrmstmf --ccsid $(TGTCCSID)  -f $< -o $(basename $(@F)) -l $(OBJLIB) -c "CRTDSPF" -p '"$(CRTDSPFFLAGS)"'")
	@$(PRESETUP) \
	$(SCRIPTSPATH)/crtfrmstmf --ccsid $(TGTCCSID)  -f $< -o $(basename $(@F)) -l $(OBJLIB) -c "CRTDSPF" -p "$(CRTDSPFFLAGS)" --save-joblog "$(JOBLOGFILE)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
	@$(call EVFEVENT_DOWNLOAD,$*.evfevent)
endef

define LF_TO_FILE_RECIPE =
	$(FILE_VARIABLES)
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Creating LF [$(notdir $<)]")
	@$(set_STMF_CCSID)
	$(eval crtcmd := "$(SCRIPTSPATH)/crtfrmstmf --ccsid $(TGTCCSID)  -f $< -o $(basename $(@F)) -l $(OBJLIB) -c "CRTLF" -p '"$(CRTLFFLAGS)"'")
	@$(PRESETUP) \
	$(SCRIPTSPATH)/crtfrmstmf --ccsid $(TGTCCSID)  -f $< -o $(basename $(@F)) -l $(OBJLIB) -c "CRTLF" -p "$(CRTLFFLAGS)" --save-joblog "$(JOBLOGFILE)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
	@$(call EVFEVENT_DOWNLOAD,$*.evfevent)
	@$(TYPEDEF)
endef

define PF_TO_FILE_RECIPE =
	$(FILE_VARIABLES)
	@$(call echo_cmd,"=== Creating PF [$(notdir $<)]")
	$(eval crtcmd := "$(SCRIPTSPATH)/crtfrmstmf --ccsid $(TGTCCSID) -f $< -o $(basename $(@F)) -l $(OBJLIB) -c "CRTPF" -p '"$(CRTPFFLAGS)"'")
	@$(PRESETUP) \
	$(SCRIPTSPATH)/crtfrmstmf --ccsid $(TGTCCSID) -f $< -o $(basename $(@F)) -l $(OBJLIB) -c "CRTPF" -p "$(CRTPFFLAGS)" --save-joblog "$(JOBLOGFILE)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
	@$(call EVFEVENT_DOWNLOAD,$(basename $@).evfevent)
	@$(TYPEDEF)
endef

define PRTF_TO_FILE_RECIPE = 
	$(FILE_VARIABLES)
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Creating PRTF [$(notdir $<)]")
	@$(set_STMF_CCSID)
	$(eval crtcmd := "$(SCRIPTSPATH)/crtfrmstmf --ccsid $(TGTCCSID)  -f $< -o $(basename $(@F)) -l $(OBJLIB) -c "CRTPRTF" -p '"$(CRTPRTFFLAGS)"'")
	@$(PRESETUP) \
	$(SCRIPTSPATH)/crtfrmstmf --ccsid $(TGTCCSID)  -f $< -o $(basename $(@F)) -l $(OBJLIB) -c "CRTPRTF" -p "$(CRTPRTFFLAGS)" --save-joblog "$(JOBLOGFILE)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
	@$(call EVFEVENT_DOWNLOAD,$*.evfevent)
	@$(TYPEDEF)
endef

# @$(TOOLSPATH)/checkObjectAlreadyExists $@ $(OBJLIB)
# @$(TOOLSPATH)/checkIfBuilt $@ $(OBJLIB)
define TABLE_TO_FILE_RECIPE = 
	$(FILE_VARIABLES)
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Creating SQL TABLE from Sql statement [$(notdir $<)]")
	$(eval crtcmd := RUNSQLSTM srcstmf('$<') $(RUNSQLFLAGS))
	@$(PRESETUP) \
	$(SETCURLIBTOOBJLIB) \
	$(SCRIPTSPATH)/launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
endef

# @$(TOOLSPATH)/checkObjectAlreadyExists $@ $(OBJLIB)
# @$(TOOLSPATH)/checkIfBuilt $@ $(OBJLIB)
define VIEW_TO_FILE_RECIPE = 
	$(FILE_VARIABLES)
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Creating SQL VIEW from Sql statement [$(notdir $<)]")
	$(eval crtcmd := RUNSQLSTM srcstmf('$<') $(RUNSQLFLAGS))
	@$(PRESETUP) \
	$(SETCURLIBTOOBJLIB) \
	$(SCRIPTSPATH)/launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
endef

define SQLUDT_TO_FILE_RECIPE = 
	$(FILE_VARIABLES)
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Creating SQL UDT from Sql statement [$(notdir $<)]")
	$(eval crtcmd := RUNSQLSTM srcstmf('$<') $(RUNSQLFLAGS))
	@$(PRESETUP) \
	$(SETCURLIBTOOBJLIB) \
	$(SCRIPTSPATH)/launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
endef

define SQLALIAS_TO_FILE_RECIPE =
	$(FILE_VARIABLES)
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Creating SQL ALIAS from Sql statement [$(notdir $<)]")
	$(eval crtcmd := RUNSQLSTM srcstmf('$<') $(RUNSQLFLAGS))
	@$(PRESETUP) \
	$(SETCURLIBTOOBJLIB) \
	$(SCRIPTSPATH)/launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
endef


#   ____ _____  _        _    ____      _      ____           _                 
#  |  _ \_   _|/ \      / \  |  _ \    / \    |  _ \ ___  ___(_)_ __   ___  ___ 
#  | | | || | / _ \    / _ \ | |_) |  / _ \   | |_) / _ \/ __| | '_ \ / _ \/ __|
#  | |_| || |/ ___ \  / ___ \|  _ <  / ___ \  |  _ <  __/ (__| | |_) |  __/\__ \
#  |____/ |_/_/   \_\/_/   \_\_| \_\/_/   \_\ |_| \_\___|\___|_| .__/ \___||___/
#                                                              |_|              

define SQLSEQ_TO_DTARRA_RECIPE =
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Creating SQL SEQUENCE from Sql statement [$(notdir $<)]")
	$(eval crtcmd := RUNSQLSTM srcstmf('$<') $(RUNSQLFLAGS))
	@$(PRESETUP) \
	$(SETCURLIBTOOBJLIB) \
	$(SCRIPTSPATH)/launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
endef

#   __  __ _____ _   _ _   _   ____           _                 
#  |  \/  | ____| \ | | | | | |  _ \ ___  ___(_)_ __   ___  ___ 
#  | |\/| |  _| |  \| | | | | | |_) / _ \/ __| | '_ \ / _ \/ __|
#  | |  | | |___| |\  | |_| | |  _ <  __/ (__| | |_) |  __/\__ \
#  |_|  |_|_____|_| \_|\___/  |_| \_\___|\___|_| .__/ \___||___/
#                                              |_|              

define MENU_VARIABLES =
	$(eval AUT = $(MNU_AUT))
	$(eval OPTION = $(MNU_OPTION))
	$(eval CURLIB = $(MNU_CURLIB))
	$(eval PRDLIB = $(MNU_PRDLIB))
	$(eval TYPE = $(MNU_TYPE))
endef

define MENUSRC_TO_MENU_RECIPE =
	$(MENU_VARIABLES)
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Creating menu [$(notdir $<)]")
	@$(set_STMF_CCSID)
	$(eval crtcmd := "$(SCRIPTSPATH)/crtfrmstmf --ccsid $(TGTCCSID)  -f $< -o $(basename $(@F)) -l $(OBJLIB) -c "CRTMNU" -p '"$(CRTMNUFLAGS)"'")
	@$(PRESETUP) \
	$(SCRIPTSPATH)/crtfrmstmf --ccsid $(TGTCCSID)  -f $< -o $(basename $(@F)) -l $(OBJLIB) -c "CRTMNU" -p "$(CRTMNUFLAGS)" --save-joblog "$(JOBLOGFILE)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
	@$(call EVFEVENT_DOWNLOAD,$*.evfevent)
endef

#   __  __  ___  ____  _   _ _     _____   ____           _                 
#  |  \/  |/ _ \|  _ \| | | | |   | ____| |  _ \ ___  ___(_)_ __   ___  ___ 
#  | |\/| | | | | | | | | | | |   |  _|   | |_) / _ \/ __| | '_ \ / _ \/ __|
#  | |  | | |_| | |_| | |_| | |___| |___  |  _ <  __/ (__| | |_) |  __/\__ \
#  |_|  |_|\___/|____/ \___/|_____|_____| |_| \_\___|\___|_| .__/ \___||___/
#                                                          |_|              

define MODULE_VARIABLES
	$(eval AUT = $(moduleAUT))\
	$(eval DBGVIEW = $(moduleDBGVIEW))\
	$(eval OBJTYPE = $(moduleOBJTYPE))\
	$(eval OPTION = $(moduleOPTION))\
	$(eval INCDIR = $(moduleINCDIR))\
	$(eval RPGPPOPT = $(moduleRPGPPOPT))\
	$(eval STGMDL = $(moduleSTGMDL))\
	$(eval SYSIFCOPT = $(moduleSYSIFCOPT))\
	$(eval TERASPACE = $(moduleTERASPACE))\
	$(eval TGTRLS = $(moduleTGTRLS))
endef

define C_TO_MODULE_RECIPE = 
	$(MODULE_VARIABLES)
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Creating C module [$(notdir $<)]")
	@$(set_STMF_CCSID)
	$(eval crtcmd := crtcmod module($(OBJLIB)/$(basename $(@F))) srcstmf('$<') $(CRTCMODFLAGS) $(ADHOCCRTFLAGS))
	@$(PRESETUP) \
	$(SCRIPTSPATH)/launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
	@($(call EVFEVENT_DOWNLOAD,$*.evfevent); ret=$$?; rm $(DEPDIR)/$*.Td 2>/dev/null; exit $$ret)
	@$(POSTCCOMPILE)
endef

define RPGLE_TO_MODULE_RECIPE = 
	$(MODULE_VARIABLES)\
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Creating RPG module [$(notdir $<)]")
	@$(set_STMF_CCSID)
	$(eval crtcmd := crtrpgmod module($(OBJLIB)/$(basename $(@F))) srcstmf('$<') $(CRTRPGMODFLAGS))
	@$(PRESETUP) \
	$(SCRIPTSPATH)/launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
	@$(call EVFEVENT_DOWNLOAD,$*.evfevent)
endef

define CLLE_TO_MODULE_RECIPE = 
	$(MODULE_VARIABLES)
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Creating CL module [$(notdir $<)]")
	@$(set_STMF_CCSID)
	$(eval crtcmd := "$(SCRIPTSPATH)/crtfrmstmf --ccsid $(TGTCCSID)  -f $< -o $(basename $(@F)) -l $(OBJLIB) -c "crtclmod" -p '"$(CRTCLMODFLAGS)"'")
	@$(PRESETUP) \
	$(SCRIPTSPATH)/launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
	@$(call EVFEVENT_DOWNLOAD,$*.evfevent)
endef

# Temp: Convert UTF-8 to temporary Windows Latin-1, because SQLC pre-compiler doesn't understand UTF-8
define SQLC_TO_MODULE_RECIPE = 
	$(MODULE_VARIABLES)
	@$(call echo_cmd,"=== Creating SQLC module [$(notdir $<)]")
	@$(set_STMF_CCSID)
	@qsh_out -c "touch -C 1252 $<-1252 && cat $< >$<-1252"
	$(eval crtcmd := crtsqlci obj($(OBJLIB)/$(basename $(@F))) srcstmf('$<-1252') $(CRTSQLCIFLAGS))
	@$(PRESETUP) \
	$(SCRIPTSPATH)/launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
	@($(call EVFEVENT_DOWNLOAD,$*.evfevent); ret=$$?; rm $(DEPDIR)/$*.Td 2>/dev/null; rm "$<-1252" 2>/dev/null; exit $$ret)
	@rm "$<-1252"
endef

define SQLRPGLE_TO_MODULE_RECIPE = 
	$(MODULE_VARIABLES)
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Creating SQLRPGLE module [$(notdir $<)]")
	@$(set_STMF_CCSID)
	$(eval crtcmd := crtsqlrpgi obj($(OBJLIB)/$(basename $(@F))) srcstmf('$<') $(CRTSQLRPGIFLAGS))
	@$(PRESETUP) \
	$(SCRIPTSPATH)/launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
	@$(call EVFEVENT_DOWNLOAD,$*.evfevent)
endef

#   ____   ____ __  __   ____           _                 
#  |  _ \ / ___|  \/  | |  _ \ ___  ___(_)_ __   ___  ___ 
#  | |_) | |  _| |\/| | | |_) / _ \/ __| | '_ \ / _ \/ __|
#  |  __/| |_| | |  | | |  _ <  __/ (__| | |_) |  __/\__ \
#  |_|    \____|_|  |_| |_| \_\___|\___|_| .__/ \___||___/
#                                        |_|              

define PGM_VARIABLES = 
$(eval ACTGRP = $(programACTGRP))
$(eval AUT = $(programAUT))
$(eval DBGVIEW = $(programDBGVIEW))
$(eval DETAIL = $(programDETAIL))
$(eval DFTACTGRP = $(programDFTACTGRP))
$(eval OBJTYPE = $(programOBJTYPE))
$(eval OPTION = $(programOPTION))
$(eval RPGPPOPT = $(programRPGPPOPT))
$(eval STGMDL = $(programSTGMDL))
$(eval TGTRLS = $(programTGTRLS))
$(eval BNDSRVPGMPATH = $(basename $(filter %.SRVPGM,$(notdir $^)) $(externalsrvpgms)))
endef

define SQLPRC_TO_PGM_RECIPE =
	$(PGM_VARIABLES)
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Creating SQL PROCEDURE from Sql statement [$(notdir $<)]")
	$(eval crtcmd := RUNSQLSTM srcstmf('$<') $(RUNSQLFLAGS))
	@$(PRESETUP) \
	$(SETCURLIBTOOBJLIB) \
	$(SCRIPTSPATH)/launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
endef

define SQLTRG_TO_PGM_RECIPE =
	$(PGM_VARIABLES)
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Creating SQL TRIGGER from Sql statement [$(notdir $<)]")
	$(eval crtcmd := RUNSQLSTM srcstmf('$<') $(RUNSQLFLAGS))
	@$(PRESETUP) \
	$(SETCURLIBTOOBJLIB) \
	$(SCRIPTSPATH)/launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
endef


define PGM.RPGLE_TO_PGM_RECIPE =
	$(PGM_VARIABLES)
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Create Bound RPG Program [$(basename $@)]")
	$(eval crtcmd := CRTBNDRPG srcstmf('$<') PGM($(OBJLIB)/$(basename $(@F))) $(CRTBNDRPGFLAGS))
	@$(PRESETUP) \
	$(SCRIPTSPATH)/launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
	@$(call EVFEVENT_DOWNLOAD,$*.PGM.RPGLE.evfevent)
endef

define PGM.SQLRPGLE_TO_PGM_RECIPE =
	$(PGM_VARIABLES)
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Create Bound SQLRPGLE Program [$(basename $@)]")
	$(eval crtcmd := CRTSQLRPGI srcstmf('$<') OBJ($(OBJLIB)/$(basename $(@F))) $(CRTSQLRPGIFLAGS))
	@$(PRESETUP) \
	$(SCRIPTSPATH)/launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
	@$(call EVFEVENT_DOWNLOAD,$*.PGM.SQLRPGLE.evfevent)
endef

define PGM.C_TO_PGM_RECIPE =
	$(PGM_VARIABLES)
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Create Bound RPG Program [$(basename $@)]")
	$(eval crtcmd := CRTBNDC srcstmf('$<') PGM($(OBJLIB)/$(basename $(@F))) $(CRTBNDCFLAGS))
	@$(PRESETUP) \
	$(SCRIPTSPATH)/launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
	@$(call EVFEVENT_DOWNLOAD,$*.PGM.C.evfevent)
endef

define CBL_TO_PGM_RECIPE =
	$(PGM_VARIABLES)
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Create COBOL Program [$(basename $@)]")
	$(eval crtcmd := "$(SCRIPTSPATH)/crtfrmstm --ccsid $(TGTCCSID) -f $< -o $(basename $(@F)) -l $(OBJLIB) -c "CRTPRTF" -p '"$(CRTPRTFFLAGS)"'")
	@$(PRESETUP) \
	$(SCRIPTSPATH)/crtfrmstmf --ccsid $(TGTCCSID)  -f $< -o $(basename $(@F)) -l $(OBJLIB) -c "CRTPRTF" -p "$(CRTPRTFFLAGS)" --save-joblog "$(JOBLOGFILE)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
	@$(call EVFEVENT_DOWNLOAD,$*.evfevent)
endef

define PGM.CLLE_TO_PGM_RECIPE =
	$(PGM_VARIABLES)
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Create ILE CL Program [$(basename $@)]")
	$(eval crtcmd := CRTBNDCL srcstmf('$<') PGM($(OBJLIB)/$(basename $(@F))) $(CRTCLMODFLAGS))
	@$(PRESETUP) \
	$(SCRIPTSPATH)/launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
	@$(call EVFEVENT_DOWNLOAD,$*.evfevent)
endef

define RPG_TO_PGM_RECIPE =
	$(PGM_VARIABLES)
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Create RPG Program [$(basename $@)]")
	$(eval crtcmd := "$(SCRIPTSPATH)/crtfrmstmf --ccsid $(TGTCCSID) -f $< -o $(basename $(@F)) -l $(OBJLIB) -c "CRTRPGPGM" -p '"$(CRTCBLPGMFLAGS)"'")
	@$(PRESETUP) \
	$(SCRIPTSPATH)/crtfrmstmf --ccsid $(TGTCCSID)  -f $< -o $(basename $(@F)) -l $(OBJLIB) -c "CRTRPGPGM" -p "$(CRTCBLPGMFLAGS)" --save-joblog "$(JOBLOGFILE)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
	@$(call EVFEVENT_DOWNLOAD,$*.evfevent)
endef

define ILEPGM_TO_PGM_RECIPE =
	$(PGM_VARIABLES)
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Creating program [$(tgt)] from Pseudo Source [$(basename $(notdir $<))]")
	$(eval crtcmd := $(shell $(SCRIPTSPATH)/extractPseudoSrc $< $(OBJLIB) $(basename $(@F))))
	@$(PRESETUP) \
	$(SCRIPTSPATH)/extractAndLaunch "$(JOBLOGFILE)" "$<" $(OBJLIB) $(basename $(@F)) >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
endef

define MODULE_TO_PGM_RECIPE =
	$(PGM_VARIABLES)
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Creating program [$(tgt)] from modules [$(basename $(filter %.MODULE,$(notdir $^)))] and service programs [$(basename $(filter %.SRVPGM,$(notdir $^$|)))]")
	$(eval externalsrvpgms := $(filter %.SRVPGM,$(subst .LIB,,$(subst /QSYS.LIB/,,$|))))
	$(eval crtcmd := crtpgm pgm($(OBJLIB)/$(basename $(@F))) module($(basename $(filter %.MODULE,$(notdir $^)))) bndsrvpgm($(if $(BNDSRVPGMPATH),$(BNDSRVPGMPATH),*NONE)) $(CRTPGMFLAGS))
	@$(PRESETUP) \
	$(SCRIPTSPATH)/launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
	@$(call EVFEVENT_DOWNLOAD,$*.PGM.evfevent)
endef

#   ____  _   _ _     ____ ____  ____    ____           _                 
#  |  _ \| \ | | |   / ___|  _ \|  _ \  |  _ \ ___  ___(_)_ __   ___  ___ 
#  | |_) |  \| | |  | |  _| |_) | |_) | | |_) / _ \/ __| | '_ \ / _ \/ __|
#  |  __/| |\  | |__| |_| |  _ <|  __/  |  _ <  __/ (__| | |_) |  __/\__ \
#  |_|   |_| \_|_____\____|_| \_\_|     |_| \_\___|\___|_| .__/ \___||___/
#                                                        |_|              

define PNLGRP_VARIABLES = 
	$(eval AUT = $(PNLGRP_AUT))
	$(eval OPTION = $(PNLGRP_OPTION))
endef

define PNLGRPSRC_TO_PNLGRP_RECIPE =
	$(PNLGRP_VARIABLES)
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Create panel group [$(basename $@)]")
	@$(set_STMF_CCSID)
	$(eval crtcmd := "$(SCRIPTSPATH)/crtfrmstmf --ccsid $(TGTCCSID)  -f $< -o $(basename $(@F)) -l $(OBJLIB) -c "CRTPNLGRP" -p '"$(CRTPNLGRPFLAGS)"'")
	@$(PRESETUP) \
	$(SCRIPTSPATH)/crtfrmstmf --ccsid $(TGTCCSID) -f $< -o $(basename $(@F)) -l $(OBJLIB) -c "CRTPNLGRP" -p "$(CRTPNLGRPFLAGS)" --save-joblog "$(JOBLOGFILE)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
endef



#   ____  ______     ______   ____ __  __   ____           _                 
#  / ___||  _ \ \   / /  _ \ / ___|  \/  | |  _ \ ___  ___(_)_ __   ___  ___ 
#  \___ \| |_) \ \ / /| |_) | |  _| |\/| | | |_) / _ \/ __| | '_ \ / _ \/ __|
#   ___) |  _ < \ V / |  __/| |_| | |  | | |  _ <  __/ (__| | |_) |  __/\__ \
#  |____/|_| \_\ \_/  |_|    \____|_|  |_| |_| \_\___|\___|_| .__/ \___||___/
#                                                           |_|              

define SRVPGM_VARIABLES = 
	$(eval ACTGRP = $(SRVPGM_ACTGRP))\
	$(eval AUT = $(SRVPGM_AUT))\
	$(eval DETAIL = $(SRVPGM_DETAIL))\
	$(eval STGMDL = $(SRVPGM_STGMDL))\
	$(eval TGTRLS = $(SRVPGM_TGTRLS))\
	$(eval BNDSRVPGMPATH = $(basename $(filter %.SRVPGM,$(notdir $^)) $(externalsrvpgms)))
endef

define SQLUDF_TO_SRVPGM_RECIPE = 
	$(SRVPGM_VARIABLES)
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Creating SQL UDF from Sql statement [$(notdir $<)]")
	$(eval crtcmd := RUNSQLSTM srcstmf('$<') $(RUNSQLFLAGS))
	@$(PRESETUP) \
	$(SETCURLIBTOOBJLIB) \
	$(SCRIPTSPATH)/launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
endef

define BND_TO_SRVPGM_RECIPE =
	$(SRVPGM_VARIABLES)
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Creating service program [$(tgt)] from modules [$(basename $(filter %.MODULE,$(notdir $^)))] and service programs [$(basename $(filter %.SRVPGM,$(notdir $^$|)))]")
	@$(set_STMF_CCSID)
	$(eval externalsrvpgms := $(filter %.SRVPGM,$(subst .LIB,,$(subst /QSYS.LIB/,,$|))))
	$(eval crtcmd := CRTSRVPGM srcstmf('$<') SRVPGM($(OBJLIB)/$(basename $(@F))) MODULE($(basename $(filter %.MODULE,$(notdir $^)))) BNDSRVPGM($(if $(BNDSRVPGMPATH),$(BNDSRVPGMPATH),*NONE)) $(CRTSRVPGMFLAGS))
	@$(PRESETUP) \
	$(SCRIPTSPATH)/launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
endef

define ILESRVPGM_TO_SRVPGM_RECIPE =
	$(SRVPGM_VARIABLES)
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Creating service program [$(tgt)] from [$(notdir $<)]")
	$(eval crtcmd := $(shell $(SCRIPTSPATH)/extractPseudoSrc $< $(OBJLIB) $(basename $(@F))))
	@$(PRESETUP) \
	$(SCRIPTSPATH)/extractAndLaunch "$(JOBLOGFILE)" "$<" $(OBJLIB) $(basename $(@F)) >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
endef

#    ___ _____ _   _ _____ ____    ____           _                 
#   / _ \_   _| | | | ____|  _ \  |  _ \ ___  ___(_)_ __   ___  ___ 
#  | | | || | | |_| |  _| | |_) | | |_) / _ \/ __| | '_ \ / _ \/ __|
#  | |_| || | |  _  | |___|  _ <  |  _ <  __/ (__| | |_) |  __/\__ \
#   \___/ |_| |_| |_|_____|_| \_\ |_| \_\___|\___|_| .__/ \___||___/
#                                                  |_|              


define BNDDIR_TO_BNDDIR_RECIPE =
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Creating BND from [$(notdir $<)]")
	$(eval crtcmd := $(shell $(SCRIPTSPATH)/extractPseudoSrc $< $(OBJLIB) $(basename $(@F))))
	@$(PRESETUP) \
	$(SCRIPTSPATH)/extractAndLaunch "$(JOBLOGFILE)" "$<" $(OBJLIB) $(basename $(@F)) >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
endef

define DTA_TO_DTA_RECIPE =
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Creating DTA from [$(notdir $<)]")
	$(eval crtcmd := $(shell $(SCRIPTSPATH)/extractPseudoSrc $< $(OBJLIB) $(basename $(@F))))
	@$(PRESETUP) \
	$(SCRIPTSPATH)/extractAndLaunch "$(JOBLOGFILE)" "$<" $(OBJLIB) $(basename $(@F)) >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
endef

define SYSTRG_TO_TRG_RECIPE =
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Creating System TRG from [$(notdir $<)]")
	$(eval crtcmd := $(shell $(SCRIPTSPATH)/extractPseudoSrc $< $(OBJLIB) $(basename $(@F))))
	@$(PRESETUP) \
	$(SCRIPTSPATH)/extractAndLaunch "$(JOBLOGFILE)" "$<" $(OBJLIB) $(basename $(@F)) >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
endef

define SQL_RECIPE =
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Running SQL Statement from [$(notdir $<)]")
	$(eval crtcmd := RUNSQLSTM srcstmf('$<'))
	@$(PRESETUP) \
	$(SETCURLIBTOOBJLIB) \
	$(SCRIPTSPATH)/launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
endef

define MSGF_RECIPE =
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Creating Message from [$(notdir $<)]")
	$(eval crtcmd := $(shell $(SCRIPTSPATH)/extractPseudoSrc $< $(OBJLIB) $(basename $(@F))))
	@$(PRESETUP) \
	$(SCRIPTSPATH)/extractAndLaunch "$(JOBLOGFILE)" "$<" $(OBJLIB) $(basename $(@F)) >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
endef

define WSCST_VARIABLES =
	$(eval AUT = $(WSCST_AUT))
endef

define WSCSTSRC_TO_WSCST_RECIPE =
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Creating work station customizing object [$(tgt)]")
	@$(set_STMF_CCSID)
	$(eval crtcmd := "$(SCRIPTSPATH)/crtfrmstmf --ccsid $(TGTCCSID)  -f $< -o $(basename $(@F)) -l $(OBJLIB) -c "CRTWSCST" -p '"$(CRTWSCSTFLAGS)"'")
	@$(PRESETUP) \
	$(SCRIPTSPATH)/crtfrmstmf  --ccsid $(TGTCCSID) -f $< -o $(basename $(@F)) -l $(OBJLIB) -c "CRTWSCST" -p "$(CRTWSCSTFLAGS)" --save-joblog "$(JOBLOGFILE)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
endef

define QMQRY_VARIABLES =
	$(eval AUT = $(QMQRY_AUT))
endef

define SQL_TO_QMQRY_RECIPE =
	$(QMQRY_VARIABLES)
	$(eval d = $($@_d))
	@$(call echo_cmd,"=== Create QM query [$(basename $@)]")
	@$(set_STMF_CCSID)
	$(eval crtcmd := "$(SCRIPTSPATH)/crtfrmstmf -f $< -o $(basename $(@F)) -l $(OBJLIB) -c "CRTQMQRY" -p '"$(CRTQMQRYFLAGS)"'")
	$(PRESETUP) \
	$(SCRIPTSPATH)/crtfrmstmf --ccsid $(TGTCCSID) -f $< -o $(basename $(@F)) -l $(OBJLIB) -c "CRTQMQRY" -p "$(CRTQMQRYFLAGS)" --save-joblog "$(JOBLOGFILE)" >> $(LOGFILE) 2>&1 && $(call logSuccess,$@) || $(call logFail,$@)
endef

# $(DEPDIR)/%.d: ;
# .PRECIOUS: $(DEPDIR)/%.d

# The *.rebuild file is used as a way of controlling the rebuild of items whose
# rebuild scripts are external to Make.
# Example: 
#    THIRDPARTY.SRVPGM: $(DEPDIR)/THIRDPARTY.SRVPGM.rebuild
#        build_thirdparty.sh
#    MYPGM.PGM: MYPGM.MODULE THIRDPARTY.SRVPGM
# 'THIRDPARTY.SRVPGM' is built outside of our Makefile, so Make has no way of knowing
# when its source code has changed and it should be recompiled.  If we
# executed the recipe every time, it would cause all items dependent on it to
# also be rebuilt.  By making the 3rd-party item dependent on this dummy .rebuild
# file, we can cause its recipe to normally not run, and we can force its recipe
# to run by manually `touch`ing its .rebuild file.
# The following rule causes the initial .rebuild file to be automatically created.
# $(DEPDIR)/%.rebuild:
# 	@touch $@


.PHONY: version
version: ; @echo "Make version: $(MAKE_VERSION)"


.PHONY: test
test:
	@echo "SHELL:			$(SHELL)"; \
	echo ".SHELLFLAGS:		$(.SHELLFLAGS)"; \
	echo "CURDIR:			$(CURDIR)"; \
	echo "SRCPATH:		$(SRCPATH)"; \
	echo "OBJPATH:		$(OBJPATH)"; \
	echo "OBJLIB:			$(OBJLIB)"; \
	echo "LIBL:			$(LIBL)"; \
	echo "IBMiEnvCmd:		$(IBMiEnvCmd)"; \
	echo "IBMiRelease:		$(IBMiRelease)"; \
	echo "COMPATIBILITYMODE:$(COMPATIBILITYMODE)"; \
	echo "INCDIR:           $(INCDIR)"; \
	echo "preUsrlibl:		$(preUsrlibl)"; \
	echo "postUsrlibl:		$(postUsrlibl)"; \
	echo "ScriptPath:		$(SCRIPTPATH)"; \
	echo "TOOLSPATH:		$(TOOLSPATH)"; \
	echo "PROJECTDIR:		$(PROJECTDIR)";

# Definition of variable ${\n} containing just new-line character
define \n


endef
