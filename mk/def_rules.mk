COLOR := \033[33;40m
COLOR_ERROR := \033[0;31m
NOCOLOR := \033[0m

ifndef COLOR_TTY
COLOR_TTY := $(shell [ `tput colors` -gt 2 ] && echo true)
endif

ifneq ($(VERBOSE),true)
ifneq ($(strip $(TOP_BUILD_DIR)),)
  strip_top = $(subst $(TOP)/,,$(subst $(TOP_BUILD_DIR)/,,$(1)))
else
  strip_top = $(subst $(TOP)/,,$(1))
endif
ifeq ($(COLOR_TTY),true)
echo_prog := $(shell if echo -e | grep -q -- -e; then echo echo; else echo echo -e; fi)
echo_cmd = @$(echo_prog) "$(COLOR)$(call strip_top,$(1))$(NOCOLOR)";
echo_error = @$(echo_prog) "$(COLOR_ERROR)$(call strip_top,$(1))$(NOCOLOR)";
else
echo_cmd = @echo "$(call strip_top,$(1))";
echo_error = @echo "$(call strip_top,$(1))";
endif
else # Verbose output
echo_cmd =
endif

# The extractName and extractTextDescriptor are used to decompose the long filename into module name and
# the text descriptor.
# e.g. CUSTOME1-Customer_file.LF has `CUSTOME1` as the module name and `Customer file` as the text descriptor
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
CMD_HLPID = $(notdir $*)
CMD_HLPPNLGRP = $(notdir $*)
CMD_PGM = $(notdir $*)
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
CRTDSPFFLAGS = ENHDSP(*YES) RSTDSP($(RSTDSP)) DFRWRT(*YES) AUT($(AUT)) OPTION($(OPTION)) TEXT(''$(TEXT)'')
CRTLFFLAGS = AUT($(AUT)) OPTION($(OPTION)) TEXT(''$(TEXT)'')
CRTMNUFLAGS = AUT($(AUT)) OPTION($(OPTION)) CURLIB($(CURLIB)) PRDLIB($(PRDLIB)) TEXT(''$(TEXT)'') TYPE($(TYPE))
CRTPFFLAGS = AUT($(AUT)) DLTPCT($(DLTPCT)) OPTION($(OPTION)) REUSEDLT($(REUSEDLT)) SIZE($(SIZE)) TEXT(''$(TEXT)'')
CRTPGMFLAGS = ACTGRP($(ACTGRP)) USRPRF(*USER) TGTRLS($(TGTRLS)) AUT($(AUT)) DETAIL($(DETAIL)) OPTION($(CRTPGM_OPTION)) STGMDL($(STGMDL)) TEXT('$(TEXT)')
CRTPNLGRPFLAGS = AUT($(AUT)) OPTION($(OPTION)) TEXT(''$(TEXT)'')
CRTCBLPGMFLAGS = OPTION($(OPTION)) TEXT(''$(TEXT)'')
CRTPRTFFLAGS = AUT($(AUT)) OPTION($(OPTION)) PAGESIZE($(PAGESIZE)) TEXT(''$(TEXT)'')
CRTRPGMODFLAGS = AUT($(AUT)) DBGVIEW($(DBGVIEW)) OPTION($(OPTION)) OUTPUT(*PRINT) TEXT('$(TEXT)') \
                 TGTCCSID($(TGTCCSID)) TGTRLS($(TGTRLS))
CRTQMQRYFLAGS = AUT($(AUT)) TEXT(''$(TEXT)'')
CRTSQLCIFLAGS = COMMIT($(COMMIT)) OBJTYPE($(OBJTYPE)) OUTPUT(*PRINT) TEXT('$(TEXT)') TGTRLS($(TGTRLS)) DBGVIEW($(DBGVIEW)) \
                COMPILEOPT('INCDIR(''$(INCDIR)'') OPTION($(OPTION)) STGMDL($(STGMDL)) SYSIFCOPT($(SYSIFCOPT)) \
                            TGTCCSID($(TGTCCSID)) TERASPACE($(TERASPACE)) INCDIR($(INCDIR))
CRTSQLRPGIFLAGS = COMMIT($(COMMIT)) OBJTYPE($(OBJTYPE)) OPTION($(OPTION)) OUTPUT(*PRINT) TEXT('$(TEXT)') \
                  TGTRLS($(TGTRLS)) DBGVIEW($(DBGVIEW)) RPGPPOPT($(RPGPPOPT)) \
                  COMPILEOPT('TGTCCSID($(TGTCCSID))')
CRTSRVPGMFLAGS = ACTGRP($(ACTGRP)) TEXT(''$(TEXT)'') TGTRLS($(TGTRLS)) AUT($(AUT)) DETAIL($(DETAIL)) STGMDL($(STGMDL))
CRTWSCSTFLAGS = AUT($(AUT)) TEXT(''$(TEXT)'')
CRTBNDRPGFLAGS:= DBGVIEW($(DBGVIEW)) TGTCCSID($(TGTCCSID)) OPTION($(OPTION)) TEXT('$(TEXT)')
CRTBNDCFLAGS:=TGTCCSID($(TGTCCSID)) OPTION($(OPTION)) TEXT('$(TEXT)')
RUNSQLFLAGS:= DBGVIEW(*SOURCE) TGTRLS($(TGTRLS)) OUTPUT(*PRINT)

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
VPATH = $(OBJPATH):$(SRCPATH)

define PRESETUP = 
echo ">> Adding user libraries to liblist" >> $(LOGFILE); \
[[ ! -z "$(curlib)" ]] && liblist -c $(curlib) >> $(LOGFILE) 2>&1; \
[[ ! -z "$(preUsrlibl)" ]] && liblist -af $(preUsrlibl) >> $(LOGFILE) 2>&1; \
[[ ! -z "$(postUsrlibl)" ]] && liblist -al $(postUsrlibl) >> $(LOGFILE) 2>&1; \
echo ">> Setup IBM i Environment" >> $(LOGFILE); \
echo "$(IBMiEnvCmd)" >> $(LOGFILE); \
[[ ! -z "$(IBMiEnvCmd)" ]] && $(IBMiEnvCmd) ; \
$(echo_prog) "$(crtcmd)\n"
endef

define POSTCLEANUP = 

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
system "CPYTOSTMF FROMMBR('$(OBJPATH)/EVFEVENT.FILE/$*.MBR') TOSTMF('$(EVTDIR)/$*.evfevent') STMFCCSID(*STDASCII) ENDLINFMT(*LF) CVTDTA(*AUTO) STMFOPT(*REPLACE)" >/dev/null
endef
define POSTRPGCOMPILE =
$(EVFEVENT_DOWNLOAD);
endef

# Deletes .d dependency file if it's empty.
define removeEmptyDep =
if [ ! -s $(DEPDIR)/$(notdir $*).d ]; then \
  rm $(DEPDIR)/$(notdir $*).d; \
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
if ! cmp $<.H-new $<.H-old >/dev/null 2>&1; then mv -f $<.H1 $<.H; echo "*** Created new typedef file $<.H for file [$*]"; fi
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
	$(if $(filter %.DSPF %.dspf,$<),$(DSPF_AUT), \
	$(if $(filter %.LF %.lf,$<),$(LF_AUT), \
	$(if $(filter %.PF %.pf,$<),$(PF_AUT), \
	$(if $(filter %.PRTF %.prtf,$<),$(PRTF_AUT), \
	UNKNOWN_FILE_TYPE)))))
fileDLTPCT = $(strip \
	$(if $(filter %.PF %.pf,$<),$(PF_DLTPCT), \
	UNKNOWN_FILE_TYPE))
fileOPTION = $(strip \
	$(if $(filter %.DSPF %.dspf,$<),$(DSPF_OPTION), \
	$(if $(filter %.LF %.lf,$<),$(LF_OPTION), \
	$(if $(filter %.PF %.pf,$<),$(PF_OPTION), \
	$(if $(filter %.PRTF %.prtf,$<),$(PRTF_OPTION), \
	UNKNOWN_FILE_TYPE)))))
filePAGESIZE = $(strip \
	$(if $(filter %.PRTF %.prtf,$<),$(PRTF_PAGESIZE), \
	UNKNOWN_FILE_TYPE))
fileREUSEDLT = $(strip \
	$(if $(filter %.PF %.pf,$<),$(PF_REUSEDLT), \
	UNKNOWN_FILE_TYPE))
fileRSTDSP = $(strip \
	$(if $(filter %.DSPF %.dspf,$<),$(DSPF_RSTDSP), \
	UNKNOWN_FILE_TYPE))
fileSIZE = $(strip \
	$(if $(filter %.PF %.pf,$<),$(PF_SIZE), \
	UNKNOWN_FILE_TYPE))

# Determine default settings for the various source types that can make a module object.
moduleAUT = $(strip \
	$(if $(filter %.C %.c,$<),$(CMOD_AUT), \
	$(if $(filter %.CLLE %.clle,$<),$(CLMOD_AUT), \
	$(if $(filter %.RPGLE %.rpgle,$<),$(RPGMOD_AUT), \
	UNKNOWN_FILE_TYPE))))
moduleDBGVIEW = $(strip \
	$(if $(filter %.C %.c,$<),$(CMOD_DBGVIEW), \
	$(if $(filter %.CLLE %.clle,$<),$(CLMOD_DBGVIEW), \
	$(if $(filter %.RPGLE %.rpgle,$<),$(RPGMOD_DBGVIEW), \
	$(if $(filter %.SQLC %.sqlc,$<),$(SQLCIMOD_DBGVIEW), \
	$(if $(filter %.SQLRPGLE %.sqlrpgle,$<),$(SQLRPGIMOD_DBGVIEW), \
	UNKNOWN_FILE_TYPE))))))
moduleOBJTYPE = $(strip \
	$(if $(filter %.SQLC %.sqlc,$<),$(SQLCIMOD_OBJTYPE), \
	$(if $(filter %.SQLRPGLE %.sqlrpgle,$<),$(SQLRPGIMOD_OBJTYPE), \
	UNKNOWN_FILE_TYPE)))
moduleOPTION = $(strip \
	$(if $(filter %.C %.c,$<),$(CMOD_OPTION), \
	$(if $(filter %.CLLE %.clle,$<),$(CLMOD_OPTION), \
	$(if $(filter %.RPGLE %.rpgle,$<),$(RPGMOD_OPTION), \
	$(if $(filter %.SQLC %.sqlc,$<),$(SQLCIMOD_OPTION), \
	$(if $(filter %.SQLRPGLE %.sqlrpgle,$<),$(SQLRPGIMOD_OPTION), \
	UNKNOWN_FILE_TYPE))))))
moduleINCDIR = $(strip \
	$(if $(filter %.C %.c,$<),$(CMOD_INCDIR), \
	$(if $(filter %.CLLE %.clle,$<),$(CLMOD_INCDIR), \
	$(if $(filter %.CBLLE %.cblle,$<),$(CBLMOD_INCDIR), \
	$(if $(filter %.SQLC %.sqlc,$<),$(SQLCIMOD_INCDIR), \
	UNKNOWN_FILE_TYPE)))))
moduleRPGPPOPT = $(strip \
	$(if $(filter %.SQLRPGLE %.sqlrpgle,$<),$(SQLRPGIMOD_RPGPPOPT), \
	UNKNOWN_FILE_TYPE))
moduleSTGMDL = $(strip \
	$(if $(filter %.C %.c,$<),$(CMOD_STGMDL), \
	$(if $(filter %.SQLC %.sqlc,$<),$(SQLCIMOD_STGMDL), \
	UNKNOWN_FILE_TYPE)))
moduleSYSIFCOPT = $(strip \
	$(if $(filter %.C %.c,$<),$(CMOD_SYSIFCOPT), \
	$(if $(filter %.SQLC %.sqlc,$<),$(SQLCIMOD_SYSIFCOPT), \
	UNKNOWN_FILE_TYPE)))
moduleTERASPACE = $(strip \
	$(if $(filter %.C %.c,$<),$(CMOD_TERASPACE), \
	$(if $(filter %.SQLC %.sqlc,$<),$(SQLCIMOD_TERASPACE), \
	UNKNOWN_FILE_TYPE)))
moduleTGTRLS = $(strip \
	$(if $(filter %.C %.c,$<),$(CMOD_TGTRLS), \
	$(if $(filter %.CLLE %.clle,$<),$(CLMOD_TGTRLS), \
	$(if $(filter %.RPGLE %.rpgle,$<),$(RPGMOD_TGTRLS), \
	$(if $(filter %.SQLC %.sqlc,$<),$(SQLCIMOD_TGTRLS), \
	$(if $(filter %.SQLRPGLE %.sqlrpgle,$<),$(SQLRPGIMOD_TGTRLS), \
	UNKNOWN_FILE_TYPE))))))

# Determine default settings for the various source types that can make a program object.
programACTGRP = $(strip \
	$(if $(filter %.CLLE %.clle,$<),$(BNDCL_ACTGRP), \
	$(if $(filter %.RPGLE %.rpgle,$<),$(BNDRPG_ACTGRP), \
	$(if $(filter %.MODULE %.module,$<),$(PGM_ACTGRP), \
	UNKNOWN_FILE_TYPE))))
programAUT = $(strip \
	$(if $(filter %.CLLE %.clle,$<),$(BNDCL_AUT), \
	$(if $(filter %.RPGLE %.rpgle,$<),$(BNDRPG_AUT), \
	$(if $(filter %.MODULE %.module,$<),$(PGM_AUT), \
	UNKNOWN_FILE_TYPE))))
programDBGVIEW = $(strip \
	$(if $(filter %.CLLE %.clle,$<),$(BNDCL_DBGVIEW), \
	$(if $(filter %.RPGLE %.rpgle,$<),$(BNDRPG_DBGVIEW), \
	$(if $(filter %.SQLC %.sqlc,$<),$(SQLCIPGM_DBGVIEW), \
	$(if $(filter %.SQLRPGLE %.sqlrpgle,$<),$(SQLRPGIPGM_DBGVIEW), \
	UNKNOWN_FILE_TYPE)))))
programDETAIL = $(strip \
	$(if $(filter %.MODULE %.module,$<),$(PGM_DETAIL), \
	UNKNOWN_FILE_TYPE))
programDFTACTGRP = $(strip \
	$(if $(filter %.CLLE %.clle,$<),$(BNDCL_DFTACTGRP), \
	$(if $(filter %.RPGLE %.rpgle,$<),$(BNDRPG_DFTACTGRP), \
	UNKNOWN_FILE_TYPE)))
programOBJTYPE = $(strip \
	$(if $(filter %.SQLC %.sqlc,$<),$(SQLCIPGM_OBJTYPE), \
	$(if $(filter %.SQLRPGLE %.sqlrpgle,$<),$(SQLRPGIPGM_OBJTYPE), \
	UNKNOWN_FILE_TYPE)))
programOPTION = $(strip \
	$(if $(filter %.CLLE %.clle,$<),$(BNDCL_OPTION), \
	$(if $(filter %.RPGLE %.rpgle,$<),$(BNDRPG_OPTION), \
	$(if $(filter %.SQLC %.sqlc,$<),$(SQLCIPGM_OPTION), \
	$(if $(filter %.SQLRPGLE %.sqlrpgle,$<),$(SQLRPGIPGM_OPTION), \
	$(if $(filter %.MODULE %.module,$<),$(PGM_OPTION), \
	$(if $(filter %.CBL %.cbl,$<),$(CBL_OPTION), \
	$(if $(filter %.RPG %.rpg,$<),$(RPG_OPTION), \
	UNKNOWN_FILE_TYPE))))))))
programRPGPPOPT = $(strip \
	$(if $(filter %.SQLRPGLE %.sqlrpgle,$<),$(SQLRPGIPGM_RPGPPOPT), \
	UNKNOWN_FILE_TYPE))
programSTGMDL = $(strip \
	$(if $(filter %.MODULE %.module,$<),$(PGM_STGMDL), \
	UNKNOWN_FILE_TYPE))
programTGTRLS = $(strip \
	$(if $(filter %.CLLE %.clle,$<),$(BNDCL_TGTRLS), \
	$(if $(filter %.RPGLE %.rpgle,$<),$(BNDRPG_TGTRLS), \
	$(if $(filter %.SQLC %.sqlc,$<),$(SQLCIPGM_TGTRLS), \
	$(if $(filter %.SQLRPGLE %.sqlrpgle,$<),$(SQLRPGIPGM_TGTRLS), \
	$(if $(filter %.MODULE %.module,$<),$(PGM_TGTRLS), \
	UNKNOWN_FILE_TYPE))))))

### Implicit rules
%.CMD: private AUT = $(CMD_AUT)
%.CMD: private HLPID = $(CMD_HLPID)
%.CMD: private HLPPNLGRP = $(CMD_HLPPNLGRP)
%.CMD: private PGM = $(CMD_PGM)
%.CMD: private PMTFILE = $(CMD_PMTFILE)
%.CMD: private VLDCKR = $(CMD_VLDCKR)

.ONESHELL:
%.CMD:
	@if [ ! -z "$(filter %.CMDSRC %.cmdsrc, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Creating command [$(notdir $<)]")
		$(set_STMF_CCSID)
		$(eval crtcmd := CRTCMD CMD($(OBJLIB)/$(basename $(@F))) srcstmf('$<') $(CRTCMDFLAGS))
		$(PRESETUP); 
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 ;
		$(POSTCLEANUP)
	else
		$(call echo_error,"Unknown file type when building $(@): $(<)")
	fi


%.FILE: private AUT = $(fileAUT)
%.FILE: private DLTPCT = $(fileDLTPCT)
%.FILE: private OPTION = $(fileOPTION)
%.FILE: private PAGESIZE = $(filePAGESIZE)
%.FILE: private REUSEDLT = $(fileREUSEDLT)
%.FILE: private RSTDSP = $(fileRSTDSP)
%.FILE: private SIZE = $(fileSIZE)
%.FILE: private TYPEDEF = $(if $(filter YES,$(CREATE_TYPEDEF)),$(TYPEDEF_SCRIPT),)

%.FILE:
	@if [ ! -z "$(filter %.DSPF %.dspf, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Creating DSPF [$(notdir $<)]")
		$(set_STMF_CCSID)
		$(eval crtcmd := $(CRTFRMSTMFLIB)/crtfrmstmf obj($(OBJLIB)/$(basename $(@F))) cmd(CRTDSPF) srcstmf('$<') parms('$(CRTDSPFFLAGS)'))
		$(PRESETUP); 
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 ; $(EVFEVENT_DOWNLOAD);
		$(POSTCLEANUP)
	elif [ ! -z "$(filter %.LF %.lf, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Creating LF [$(notdir $<)]")
		$(set_STMF_CCSID)
		@if [ -d $(OBJPATH)/$@ ]; then rm -r $(OBJPATH)/$@; fi
		$(eval crtcmd := $(CRTFRMSTMFLIB)/crtfrmstmf obj($(OBJLIB)/$(basename $(@F))) cmd(CRTLF) srcstmf('$<') parms('$(CRTLFFLAGS)'))
		$(PRESETUP); 
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 ; $(EVFEVENT_DOWNLOAD);
		$(POSTCLEANUP)
		$(TYPEDEF)
	elif [ ! -z "$(filter %.PF %.pf, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Creating PF [$(notdir $<)]")
		$(set_STMF_CCSID)
		$(eval crtcmd := $(CRTFRMSTMFLIB)/crtfrmstmf obj($(OBJLIB)/$(basename $(@F))) cmd(CRTPF) srcstmf('$<') parms('$(CRTPFFLAGS)'))
		$(PRESETUP); 
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 ; $(EVFEVENT_DOWNLOAD);
		$(POSTCLEANUP)
		$(TYPEDEF)
	elif [ ! -z "$(filter %.PRTF %.prtf, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Creating PRTF [$(notdir $<)]")
		$(set_STMF_CCSID)
		$(eval crtcmd := $(CRTFRMSTMFLIB)/crtfrmstmf obj($(OBJLIB)/$(basename $(@F))) cmd(CRTPRTF) srcstmf('$<') parms('$(CRTPRTFFLAGS)'))
		$(PRESETUP); 
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 ; $(EVFEVENT_DOWNLOAD);
		$(POSTCLEANUP)
		$(TYPEDEF)
	elif [ ! -z "$(filter %.TABLE %.table, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Creating SQL TABLE from Sql statement [$(notdir $<)]")
		$(eval crtcmd := RUNSQLSTM srcstmf('$<') $(RUNSQLFLAGS))
		$(PRESETUP); 
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 || true;
		$(POSTCLEANUP)
	elif [ ! -z "$(filter %.VIEW %.view, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Creating SQL VIEW from Sql statement [$(notdir $<)]")
		$(eval crtcmd := RUNSQLSTM srcstmf('$<') $(RUNSQLFLAGS))
		$(PRESETUP); 
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 || true;
		$(POSTCLEANUP)
	elif [ ! -z "$(filter %.SQLUDT %.sqludt, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Creating SQL UDT from Sql statement [$(notdir $<)]")
		$(eval crtcmd := RUNSQLSTM srcstmf('$<') $(RUNSQLFLAGS))
		$(PRESETUP); 
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 || true;
		$(POSTCLEANUP)
	elif [ ! -z "$(filter %.SQLXSR %.sqlxsr, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Creating SQL XSR from Sql statement [$(notdir $<)]")
		$(eval crtcmd := RUNSQLSTM srcstmf('$<') $(RUNSQLFLAGS))
		$(PRESETUP); 
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 || true;
		$(POSTCLEANUP)
	elif [ ! -z "$(filter %.SQLALIAS %.sqlalias, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Creating SQL ALIAS from Sql statement [$(notdir $<)]")
		$(eval crtcmd := RUNSQLSTM srcstmf('$<') $(RUNSQLFLAGS))
		$(PRESETUP); 
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 || true;
		$(POSTCLEANUP)
	elif [ ! -z "$(filter %.SQLMASK %.sqlmask, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Creating SQL MASK from Sql statement [$(notdir $<)]")
		$(eval crtcmd := RUNSQLSTM srcstmf('$<') $(RUNSQLFLAGS))
		$(PRESETUP); 
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 || true;
		$(POSTCLEANUP)
	elif [ ! -z "$(filter %.SQLPERM %.sqlperm, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Creating SQL PERMISSION from Sql statement [$(notdir $<)]")
		$(eval crtcmd := RUNSQLSTM srcstmf('$<') $(RUNSQLFLAGS))
		$(PRESETUP); 
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 || true;
		$(POSTCLEANUP)
	else
		$(call echo_error,"Unknown file type when building $(@): $@ $(<)")
	fi

.ONESHELL:
%.DTAARA:
	@if [ ! -z "$(filter %.SQLSEQ %.sqlseq, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Creating SQL SEQUENCE from Sql statement [$(notdir $<)]")
		$(eval crtcmd := RUNSQLSTM srcstmf('$<') $(RUNSQLFLAGS))
		$(PRESETUP);
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 || true;
		$(POSTCLEANUP)
	else
		$(call echo_error,"Unknown file type when building $(@): $(<)")
	fi


%.MENU: private AUT = $(MNU_AUT)
%.MENU: private OPTION = $(MNU_OPTION)
%.MENU: private CURLIB = $(MNU_CURLIB)
%.MENU: private PRDLIB = $(MNU_PRDLIB)
%.MENU: private TYPE = $(MNU_TYPE)

.ONESHELL:
%.MENU:
	@if [ ! -z "$(filter %.MENU %.menu, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Creating menu [$(notdir $<)]")
		$(set_STMF_CCSID)
		$(eval crtcmd := $(CRTFRMSTMFLIB)/crtfrmstmf obj($(OBJLIB)/$(basename $(@F))) cmd(CRTMNU) srcstmf('$<') parms('$(CRTMNUFLAGS)'))
		$(PRESETUP); 
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 ; $(EVFEVENT_DOWNLOAD);
		$(POSTCLEANUP)
	else
		$(call echo_error,"Unknown file type when building $(@): $(<)")
	fi



%.MODULE: private AUT = $(moduleAUT)
%.MODULE: private DBGVIEW = $(moduleDBGVIEW)
%.MODULE: private OBJTYPE = $(moduleOBJTYPE)
%.MODULE: private OPTION = $(moduleOPTION)
%.MODULE: private INCDIR = $(moduleINCDIR)
%.MODULE: private RPGPPOPT = $(moduleRPGPPOPT)
%.MODULE: private STGMDL = $(moduleSTGMDL)
%.MODULE: private SYSIFCOPT = $(moduleSYSIFCOPT)
%.MODULE: private TERASPACE = $(moduleTERASPACE)
%.MODULE: private TGTRLS = $(moduleTGTRLS)

.ONESHELL:
%.MODULE:
	@if [ ! -z "$(filter %.C %.c, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Creating C module [$(notdir $<)]")
		$(set_STMF_CCSID)
		$(eval crtcmd := crtcmod module($(OBJLIB)/$(basename $(@F))) srcstmf('$<') $(CRTCMODFLAGS) $(ADHOCCRTFLAGS))
		$(PRESETUP); 
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 ; ($(EVFEVENT_DOWNLOAD); ret=$$?; rm $(DEPDIR)/$*.Td 2>/dev/null; exit $$ret);
		$(POSTCLEANUP)
		$(POSTCCOMPILE)
	elif [ ! -z "$(filter %.RPGLE %.rpgle, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Creating RPG module [$(notdir $<)]")
		$(set_STMF_CCSID)
		$(eval crtcmd := crtrpgmod module($(OBJLIB)/$(basename $(@F))) srcstmf('$<') $(CRTRPGMODFLAGS))
		$(PRESETUP);
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 ; $(EVFEVENT_DOWNLOAD);
		$(POSTCLEANUP)
		$(POSTRPGCOMPILE)
	elif [ ! -z "$(filter %.CLLE %.clle, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Creating CL module [$(notdir $<)]")
		$(set_STMF_CCSID) \
		$(eval crtcmd := crtclmod module($(OBJLIB)/$(basename $(@F))) srcstmf('$<') $(CRTCLMODFLAGS))
		$(PRESETUP);
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1;
		$(POSTCLEANUP)
		$(EVFEVENT_DOWNLOAD)
	elif [ ! -z "$(filter %.SQLC %.sqlc, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Creating SQLC module [$(notdir $<)]")
		$(set_STMF_CCSID)
		qsh_out -c "touch -C 1252 $<-1252 && cat $< >$<-1252"
		$(eval crtcmd := crtsqlci obj($(OBJLIB)/$(basename $(@F))) srcstmf('$<-1252') $(CRTSQLCIFLAGS))
		$(PRESETUP);
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 ; ($(EVFEVENT_DOWNLOAD); ret=$$?; rm $(DEPDIR)/$*.Td 2>/dev/null; rm "$<-1252" 2>/dev/null; exit $$ret);
		$(POSTCLEANUP)
		$(POSTCCOMPILE)
		rm "$<-1252"
	elif [ ! -z "$(filter %.SQLRPGLE %.sqlrpgle, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Creating SQLRPGLE module [$(notdir $<)]")
		@$(set_STMF_CCSID)
		$(eval crtcmd := crtsqlrpgi obj($(OBJLIB)/$(basename $(@F))) srcstmf('$<') $(CRTSQLRPGIFLAGS))
		@$(PRESETUP);
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 ; $(EVFEVENT_DOWNLOAD);
		$(POSTCLEANUP)
		$(POSTRPGCOMPILE)
	else
		$(call echo_error,"Unknown file type when building $(@): $(<)")
	fi

%.PGM: private ACTGRP = $(programACTGRP)
%.PGM: private AUT = $(programAUT)
%.PGM: private DBGVIEW = $(programDBGVIEW)
%.PGM: private DETAIL = $(programDETAIL)
%.PGM: private DFTACTGRP = $(programDFTACTGRP)
%.PGM: private OBJTYPE = $(programOBJTYPE)
%.PGM: private OPTION = $(programOPTION)
%.PGM: private RPGPPOPT = $(programRPGPPOPT)
###%.PGM: private PGM = $*
%.PGM: private STGMDL = $(programSTGMDL)
%.PGM: private TGTRLS = $(programTGTRLS)
%.PGM: private BNDSRVPGMPATH = $(basename $(filter %.SRVPGM,$(notdir $^)) $(externalsrvpgms))

.ONESHELL:
%.PGM:
	srcfile=$<
	srcfiletype="${srcfile##*.}"
	if [ ! -z "$(filter %.SQLPRC %.sqlprc, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Creating SQL PROCEDURE from Sql statement [$(notdir $<)]")
		$(eval crtcmd := RUNSQLSTM srcstmf('$<') $(RUNSQLFLAGS))
		$(PRESETUP); 
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 || true;
		$(POSTCLEANUP)
	elif [ ! -z "$(filter %.SQLTRG %.sqltrg, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Creating SQL TRIGGER from Sql statement [$(notdir $<)]")
		$(eval crtcmd := RUNSQLSTM srcstmf('$<') $(RUNSQLFLAGS))
		$(PRESETUP); 
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 || true;
		$(POSTCLEANUP)
	elif [ ! -z "$(filter %.PGM.RPGLE %.pgm.rpgle, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Create Bound RPG Program [$(notdir $*)]")
		$(eval crtcmd := CRTBNDRPG srcstmf('$<') PGM($(OBJLIB)/$(basename $(@F))) $(CRTBNDRPGFLAGS))
		$(eval EVFEVENT_DOWNLOAD_PGM_RPGLE = system "CPYTOSTMF FROMMBR('$(OBJPATH)/EVFEVENT.FILE/$*.MBR') TOSTMF('$(EVTDIR)/$*.PGM.RPGLE.evfevent') STMFCCSID(*STDASCII) ENDLINFMT(*LF) CVTDTA(*AUTO) STMFOPT(*REPLACE)" >/dev/null)
		$(PRESETUP); 
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 ; $(EVFEVENT_DOWNLOAD_PGM_RPGLE);
		$(POSTCLEANUP)
		$(EVFEVENT_DOWNLOAD_PGM_RPGLE)
	elif [ ! -z "$(filter %.PGM.SQLRPGLE %.pgm.sqlrpgle, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Create Bound SQLRPGLE Program [$(notdir $*)]")
		$(eval crtcmd := CRTSQLRPGI srcstmf('$<') OBJ($(OBJLIB)/$(basename $(@F))) $(CRTSQLRPGIFLAGS))
		$(eval EVFEVENT_DOWNLOAD_PGM_RPGLE = system "CPYTOSTMF FROMMBR('$(OBJPATH)/EVFEVENT.FILE/$*.MBR') TOSTMF('$(EVTDIR)/$*.PGM.SQLRPGLE.evfevent') STMFCCSID(*STDASCII) ENDLINFMT(*LF) CVTDTA(*AUTO) STMFOPT(*REPLACE)" >/dev/null)
		$(PRESETUP);
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 ; $(EVFEVENT_DOWNLOAD_PGM_RPGLE);
		$(POSTCLEANUP)
		$(EVFEVENT_DOWNLOAD_PGM_RPGLE)
	elif [ ! -z "$(filter %.PGM.C %.pgm.c, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Create Bound RPG Program [$(notdir $*)]")
		$(eval crtcmd := CRTBNDC srcstmf('$<') PGM($(OBJLIB)/$(basename $(@F))) $(CRTBNDCFLAGS))
		$(eval EVFEVENT_DOWNLOAD_PGM_C = system "CPYTOSTMF FROMMBR('$(OBJPATH)/EVFEVENT.FILE/$*.MBR') TOSTMF('$(EVTDIR)/$*.PGM.C.evfevent') STMFCCSID(*STDASCII) ENDLINFMT(*LF) CVTDTA(*AUTO) STMFOPT(*REPLACE)" >/dev/null)
		$(PRESETUP);
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 ; $(EVFEVENT_DOWNLOAD_PGM_C);
		$(POSTCLEANUP)
		$(EVFEVENT_DOWNLOAD_PGM_C)
	elif [ ! -z "$(filter %.CBL %.cbl, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Create COBOL Program [$(notdir $*)]")
		$(eval crtcmd := $(CRTFRMSTMFLIB)/crtfrmstmf obj($(OBJLIB)/$(basename $(@F))) cmd(CRTCBLPGM) srcstmf('$<') parms('$(CRTCBLPGMFLAGS)'))
		$(PRESETUP);
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 ; $(EVFEVENT_DOWNLOAD);
		$(POSTCLEANUP)
	elif [ ! -z "$(filter %.PGM.CLLE %.pgm.clle, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Create ILE CL Program [$(notdir $*)]")
		$(eval crtcmd := CRTBNDCL srcstmf('$<') PGM($(OBJLIB)/$(basename $(@F))) $(CRTCLMODFLAGS))
		$(PRESETUP);
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 ; $(EVFEVENT_DOWNLOAD);
		$(POSTCLEANUP)
	elif [ ! -z "$(filter %.RPG %.rpg, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Create RPG Program [$(notdir $*)]")
		$(eval crtcmd := $(CRTFRMSTMFLIB)/crtfrmstmf obj($(OBJLIB)/$(basename $(@F))) cmd(CRTRPGPGM) srcstmf('$<') parms('$(CRTCBLPGMFLAGS)'))
		$(PRESETUP);
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 ; $(EVFEVENT_DOWNLOAD);
		$(POSTCLEANUP)
	elif [ ! -z "$(filter %.ILEPGM %.ilepgm, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Creating program [$*] from Pseudo Source [$(basename $(notdir $<))]")
		$(eval crtcmd := $(shell $(MK)/extractPseudoSrc $< $(OBJLIB) $(basename $(@F))))
		$(PRESETUP);
		$(MK)/extractAndLaunch "$(JOBLOGFILE)" "$<" $(OBJLIB) $(basename $(@F)) >> $(LOGFILE) 2>&1 || true;
		$(POSTCLEANUP)
	elif [ ! -z "$(filter %.MODULE %.module, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Creating program [$*] from modules [$(basename $(filter %.MODULE,$(notdir $^)))] and service programs [$(basename $(filter %.SRVPGM,$(notdir $^$|)))]")
		$(eval externalsrvpgms := $(filter %.SRVPGM,$(subst .LIB,,$(subst /QSYS.LIB/,,$|))))
		$(eval crtcmd := crtpgm pgm($(OBJLIB)/$(basename $(@F))) module($(basename $(filter %.MODULE,$(notdir $^)))) bndsrvpgm($(if $(BNDSRVPGMPATH),$(BNDSRVPGMPATH),*NONE)) $(CRTPGMFLAGS))
		$(eval EVFEVENT_DOWNLOAD_PGM = system "CPYTOSTMF FROMMBR('$(OBJPATH)/EVFEVENT.FILE/$*.MBR') TOSTMF('$(EVTDIR)/$*.PGM.evfevent') STMFCCSID(*STDASCII) ENDLINFMT(*LF) CVTDTA(*AUTO) STMFOPT(*REPLACE)" >/dev/null)
		$(PRESETUP);
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 ; $(EVFEVENT_DOWNLOAD_PGM);
		$(POSTCLEANUP)
		$(EVFEVENT_DOWNLOAD_PGM)
	else
		$(call echo_error,"Unknown file type when building $(@): $(<)")
	fi

%.PNLGRP: private AUT = $(PNLGRP_AUT)
%.PNLGRP: private OPTION = $(PNLGRP_OPTION)

.ONESHELL:
%.PNLGRP:
	@if [ ! -z "$(filter %.PNLGRP %.pnlgrp, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Create panel group [$(notdir $*)]")
		$(set_STMF_CCSID)
		$(eval crtcmd := $(CRTFRMSTMFLIB)/crtfrmstmf obj($(OBJLIB)/$(basename $(@F))) cmd(CRTPNLGRP) srcstmf('$<') parms('$(CRTPNLGRPFLAGS)'))
		$(PRESETUP);  \
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 || true; \
		$(POSTCLEANUP)
	else
		$(call echo_error,"Unknown file type when building $(@): $(<)")
	fi

%.QMQRY: private AUT = $(QMQRY_AUT)

.ONESHELL:
%.QMQRY:
	@if [ ! -z "$(filter %.SQL %.sql, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Create QM query [$(notdir $*)]")
		$(set_STMF_CCSID)
		$(eval crtcmd := $(CRTFRMSTMFLIB)/crtfrmstmf obj($(OBJLIB)/$(basename $(@F))) cmd(CRTQMQRY) srcstmf('$<') parms('$(CRTQMQRYFLAGS)'))
		$(PRESETUP) >> $(LOGFILE); \
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 || true; \
		$(POSTCLEANUP)
	else
		$(call echo_error,"Unknown file type when building $(@): $(<)")
	fi


%.SRVPGM: private ACTGRP = $(SRVPGM_ACTGRP)
%.SRVPGM: private AUT = $(SRVPGM_AUT)
%.SRVPGM: private DETAIL = $(SRVPGM_DETAIL)
%.SRVPGM: private STGMDL = $(SRVPGM_STGMDL)
%.SRVPGM: private TGTRLS = $(SRVPGM_TGTRLS)
%.SRVPGM: private BNDSRVPGMPATH = $(basename $(filter %.SRVPGM,$(notdir $^)) $(externalsrvpgms))

.ONESHELL:
%.SRVPGM:
	@if [ ! -z "$(filter %.SQLUDF %.sqludf, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Creating SQL UDF from Sql statement [$(notdir $<)]")
		$(eval crtcmd := RUNSQLSTM srcstmf('$<') $(RUNSQLFLAGS))
		$(PRESETUP);  \
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 || true; \
		$(POSTCLEANUP)
	elif [ ! -z "$(filter %.BND %.bnd, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Creating service program [$*] from modules [$(basename $(filter %.MODULE,$(notdir $^)))] and service programs [$(basename $(filter %.SRVPGM,$(notdir $^$|)))]")
		$(set_STMF_CCSID)
		$(eval externalsrvpgms := $(filter %.SRVPGM,$(subst .LIB,,$(subst /QSYS.LIB/,,$|))))
		$(eval crtcmd := CRTSRVPGM srcstmf('$<') SRVPGM($(OBJLIB)/$(basename $(@F))) MODULE($(basename $(filter %.MODULE,$(notdir $^)))) BNDSRVPGM($(if $(BNDSRVPGMPATH),$(BNDSRVPGMPATH),*NONE)) $(CRTSRVPGMFLAGS))
		$(PRESETUP);  \
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 || true; \
		$(POSTCLEANUP)
	elif [ ! -z "$(filter %.ILESRVPGM %.ilesrvpgm, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Creating service program [$*] from [$(notdir $<)]")
		$(eval crtcmd := $(shell $(MK)/extractPseudoSrc $< $(OBJLIB) $(basename $(@F))))
		$(PRESETUP);  \
		$(MK)/extractAndLaunch "$(JOBLOGFILE)" "$<" $(OBJLIB) $(basename $(@F)) >> $(LOGFILE) 2>&1 || true; \
		$(POSTCLEANUP)
	else
		$(call echo_error,"Unknown file type when building $(@): $(<)")
	fi

.ONESHELL:
%.BNDDIR:
	@if [ ! -z "$(filter %.BNDDIR %.bnddir, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Creating BND from [$(notdir $<)]")
		$(eval crtcmd := $(shell $(MK)/extractPseudoSrc $< $(OBJLIB) $(basename $(@F))))
		$(PRESETUP);  \
		$(MK)/extractAndLaunch "$(JOBLOGFILE)" "$<" $(OBJLIB) $(basename $(@F)) >> $(LOGFILE) 2>&1 || true; \
		$(POSTCLEANUP)
	else
		$(call echo_error,"Unknown file type when building $(@): $(<)")
	fi

.ONESHELL:
%.DTA:
	@if [ ! -z "$(filter %.DTAARA %.dtaara, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Creating DTA from [$(notdir $<)]")
		$(eval crtcmd := $(shell $(MK)/extractPseudoSrc $< $(OBJLIB) $(basename $(@F))))
		$(PRESETUP);  \
		$(MK)/extractAndLaunch "$(JOBLOGFILE)" "$<" $(OBJLIB) $(basename $(@F)) >> $(LOGFILE) 2>&1 || true; \
		$(POSTCLEANUP)
	else
		$(call echo_error,"Unknown file type when building $(@): $(<)")
	fi

.ONESHELL:
%.TRG:
	@if [ ! -z "$(filter %.SYSTRG %.systrg, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Creating System TRG from [$(notdir $<)]")
		$(eval crtcmd := $(shell $(MK)/extractPseudoSrc $< $(OBJLIB) $(basename $(@F))))
		$(PRESETUP);  \
		$(MK)/extractAndLaunch "$(JOBLOGFILE)" "$<" $(OBJLIB) $(basename $(@F)) >> $(LOGFILE) 2>&1 || true; \
		$(POSTCLEANUP)
	else
		$(call echo_error,"Unknown file type when building $(@): $(<)")
	fi


%.SQL:
	@$(eval d = $($@_d))
	$(call echo_cmd,"=== Running SQL Statement from [$(notdir $<)]")
	$(eval crtcmd := RUNSQLSTM srcstmf('$<'))
	$(PRESETUP);  \
	launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 || true; \
	$(POSTCLEANUP)


%.MSGF:
	@$(eval d = $($@_d))
	$(call echo_cmd,"=== Creating Message from [$(notdir $<)]")
	$(eval crtcmd := $(shell $(MK)/extractPseudoSrc $< $(OBJLIB) $(basename $(@F))))
	$(PRESETUP);  \
	$(MK)/extractAndLaunch "$(JOBLOGFILE)" "$<" $(OBJLIB) $(basename $(@F)) >> $(LOGFILE) 2>&1 || true; \
	$(POSTCLEANUP)

%.WSCST: private AUT = $(WSCST_AUT)


.ONESHELL:
%.WSCST:
	@if [ ! -z "$(filter %.WSCSTSRC %.wscstsrc, $<)" ]; then
		$(eval d = $($@_d))
		$(call echo_cmd,"=== Creating work station customizing object [$*]")
		$(set_STMF_CCSID)
		$(eval crtcmd := $(CRTFRMSTMFLIB)/crtfrmstmf obj($(OBJLIB)/$(basename $(@F))) cmd(CRTWSCST) srcstmf('$<') parms('$(CRTWSCSTFLAGS)'))
		$(PRESETUP);  \
		launch "$(JOBLOGFILE)" "$(crtcmd)" >> $(LOGFILE) 2>&1 || true; \
		$(POSTCLEANUP)
	else
		$(call echo_error,"Unknown file type when building $(@): $(<)")
	fi

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

#.PHONY: make_pre
#make_pre:
#	mkdir -p $(LOGPATH)

.PHONY: clean
clean:
	rm -rf ./.deps ./evfevent ./.logs

.PHONY: make_post
make_post:
	@echo
	@echo
	@echo "***"
	@echo "*** Source directory:	$(SRCPATH)"
	@echo "*** Target library:	$(OBJLIB)"
	@echo "*** Compile listings:	$(LOGPATH)"
	@echo "***"
	@echo "***           * * * * *   B u i l d   S u c c e s s f u l !   * * * * *"


.PHONY: version
version: ; @echo "Make version: $(MAKE_VERSION)"


.PHONY: test
test:
	@echo "SHELL:			$(SHELL)"; \
	echo ".SHELLFLAGS:		$(.SHELLFLAGS)"; \
	echo "CURDIR:			$(CURDIR)"; \
	echo "SRCPATH:		$(SRCPATH)"; \
	echo "DEPDIR:			$(DEPDIR)"; \
	echo "OBJPATH:		$(OBJPATH)"; \
	echo "OBJLIB:			$(OBJLIB)"; \
	echo "LIBL:			$(LIBL)"; \
	echo "IBMiEnvCmd:		$(IBMiEnvCmd)"; \
	echo "IBMiRelease:		$(IBMiRelease)"; \
	echo "COMPATIBILITYMODE:$(COMPATIBILITYMODE)"; \
	echo "INCDIR:           $(INCDIR)"; \
	echo "preUsrlibl:		$(preUsrlibl)"; \
	echo "postUsrlibl:		$(postUsrlibl)"; \
	echo "CRTFRMSTFMLIB:		$(CRTFRMSTMFLIB)"; \
	echo "TOOLSPATH:		$(TOOLSPATH)"; \
	echo "PROJECTDIR:		$(PROJECTDIR)";

# Definition of variable ${\n} containing just new-line character
define \n


endef
