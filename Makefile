#
# This is a test Makefile to build objects in XP303MAKE from source in ~/home/jberman/Source/xp303make.
# Invoke by typing `make`.
#
# Note: When using the IFS, path case sensitivity needs to match the actual item
# in the file system or things will break.
#
# To invoke:
#   o ADDLIBLE <object_lib>
#   o CALL QP2TERM
#   o cd /qsys.lib/<object_lib>.lib
#   o make all -f <location of makefile>
#
# Work around for C compiler bug:
#   o ADDLIBLE <object_lib>
#   o CALL QP2TERM
#   o cd /some/path/that's/not/QSYS.LIB
#   o make all INCLUDEMAKEFILES:='/path/to/project-specific/makefile.mak' OBJPATH:='/QSYS.LIB/<object_lib>.LIB' -f /location/of/this/Makefile
#   o Use `--warn-undefined-variables` while testing to see if any variables have been used without being set.
#

# Define some Makefile variables for the compiler.
# To use variables later in the Makefile, reference $(variable_name)
#

# These variables are swapped into the compile commands.  They can be overridden on a
# per-object basis by setting target-specific variables, e.g. `SO1001: TGTRLS = V7R1M0`.
# They can also be overridden on a per-object-type basis by setting pattern-specific
# variables, e.g. `%.SRVPGM: private ACTGRP = $(SRVPGM_ACTGRP)` (A variable is used in
# the assignment instead of a constant so that all settings are defined in one place,
# at the top.)
# tl;dr: If you want to customize a compile setting for an object, change these variables
# in your TARGET (not here).
TGTRLS := V6R1M0
DFTACTGRP := *NO
ACTGRP := E_PRODUCT
AUT := *EXCLUDE
DETAIL := *EXTENDED
OPTION := *EVENTF
COMMIT := *NONE
DBGVIEW := *ALL
TEXT :=
RSTDSP := *YES
PGM :=
VLDCKR := *NONE
PMTFILE := *NONE
HLPPNLGRP = $*
HLPID = $*
OBJTYPE :=
TERASPACE :=
STGMDL := *SNGLVL
BNDDIR :=

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
BNDRPG_DBGVIEW := $(DBGVIEW)
BNDRPG_DFTACTGRP := $(DFTACTGRP)
BNDRPG_OPTION := $(OPTION)

CMD_AUT := $(AUT)

CMOD_AUT := $(AUT)
CMOD_DBGVIEW := $(DBGVIEW)
CMOD_OPTION := *EVENTF *SHOWUSR *XREF *AGR
CMOD_TGTRLS := $(TGTRLS)
CMOD_TERASPACE := *YES *NOTSIFC
CMOD_STGMDL := *INHERIT

CLMOD_AUT := $(AUT)
CLMOD_DBGVIEW := $(DBGVIEW)
CLMOD_OPTION := $(OPTION)
CLMOD_TGTRLS := $(TGTRLS)

DSPF_AUT := $(AUT)
DSPF_OPTION := *EVENTF *SRC *LIST

PGM_ACTGRP := $(ACTGRP)
PGM_AUT := $(AUT)
PGM_DETAIL := $(DETAIL)
PGM_OPTION := $(OPTION)
PGM_STGMDL := *SNGLVL
PGM_TGTRLS := $(TGTRLS)

RPGMOD_AUT := $(AUT)
RPGMOD_DBGVIEW := $(DBGVIEW)
RPGMOD_OPTION := $(OPTION)
RPGMOD_TGTRLS := $(TGTRLS)

SQLCIMOD_DBGVIEW := *SOURCE
SQLCIMOD_OBJTYPE := *MODULE
SQLCIMOD_OPTION := $(OPTION)
SQLCIMOD_TGTRLS := $(TGTRLS)

SQLCIPGM_DBGVIEW := *SOURCE
SQLCIPGM_OBJTYPE := *PGM
SQLCIPGM_OPTION := $(OPTION)
SQLCIPGM_TGTRLS := $(TGTRLS)

SQLRPGIMOD_DBGVIEW := *SOURCE
SQLRPGIMOD_OBJTYPE := *MODULE
SQLRPGIMOD_OPTION := $(OPTION)
SQLRPGIMOD_TGTRLS := $(TGTRLS)

SQLRPGIPGM_DBGVIEW := *SOURCE
SQLRPGIPGM_OBJTYPE := *PGM
SQLRPGIPGM_OPTION := $(OPTION)
SQLRPGIPGM_TGTRLS := $(TGTRLS)

SRVPGM_ACTGRP := *CALLER
SRVPGM_AUT := $(AUT)
SRVPGM_BNDDIR := *NONE
SRVPGM_DETAIL := $(DETAIL)
SRVPGM_STGMDL := $(STGMDL)
SRVPGM_TGTRLS := $(TGTRLS)

# Creation command parameters with variables (the ones listed at the top) for the most common ones.
CRTBNDCLFLAGS = AUT($(AUT)) DBGVIEW($(DBGVIEW)) TGTRLS($(TGTRLS)) DFTACTGRP($(DFTACTGRP)) ACTGRP($(ACTGRP)) OPTION($(OPTION))
CRTCMDFLAGS = PGM($(PGM)) VLDCKR($(VLDCKR)) PMTFILE($(PMTFILE)) HLPPNLGRP($(HLPPNLGRP)) HLPID($(HLPID)) AUT($(AUT))
CRTCMODFLAGS = TERASPACE($(TERASPACE)) STGMDL($(STGMDL)) OUTPUT(*PRINT) OPTION($(OPTION)) DBGVIEW($(DBGVIEW)) \
               SYSIFCOPT(*IFSIO) AUT($(AUT)) TGTRLS($(TGTRLS)) MAKEDEP('$(DEPDIR)/$*.Td')
CRTDSPFFLAGS = ENHDSP(*YES) RSTDSP($(RSTDSP)) DFRWRT(*YES) AUT($(AUT)) OPTION($(OPTION)) TEXT($(TEXT))
CRTLFFLAGS = AUT($(AUT)) OPTION(*EVENTF *SRC *LIST)
CRTPFFLAGS = AUT($(AUT)) OPTION(*EVENTF *SRC *LIST) SIZE(*NOMAX) TEXT($(TEXT))
CRTPGMFLAGS = ACTGRP($(ACTGRP)) USRPRF(*USER) TGTRLS($(TGTRLS)) AUT($(AUT)) DETAIL($(DETAIL)) OPTION($(OPTION)) STGMDL($(STGMDL))
CRTRPGMODFLAGS = DBGVIEW($(DBGVIEW)) TGTRLS($(TGTRLS)) OUTPUT(*PRINT) AUT($(AUT)) OPTION($(OPTION))
CRTSQLCIFLAGS =
CRTSQLRPGIFLAGS = COMMIT($(COMMIT)) OBJTYPE($(OBJTYPE)) OUTPUT(*PRINT) TGTRLS($(TGTRLS)) OPTION($(OPTION)) DBGVIEW($(DBGVIEW))
CRTSRVPGMFLAGS = EXPORT(*ALL) ACTGRP($(ACTGRP)) TGTRLS($(TGTRLS)) AUT($(AUT)) DETAIL($(DETAIL)) STGMDL($(STGMDL))

# Extra command strings for adhoc addition of extra parameters to the creation commands.
CRTBNDCLFLAGS =
CRTPFFLAGS2 =
CRTLFFLAGS2 =
CRTDSPFFLAGS2 =
CRTRPGMODFLAGS2 =
CRTSQLRPGIFLAGS2 =
CRTSRVPGMFLAGS2 =
CRTPGMFLAGS2 =

# Miscellaneous variables
INCLUDEMAKEFILES :=
SRCPATH := /home/jberman/Source/xp303make
OBJPATH := $(CURDIR)
OBJLIB := $(basename $(notdir $(OBJPATH)))
SDEPATH := /home/jberman/Source/SDE
SDELIB := SDE
runDate := $(shell date +"%F_%H.%M.%S-%a")
LOGPATH := $(SRCPATH)/Logs/$(runDate)
$(shell mkdir -p $(LOGPATH))
DEPDIR := $(SRCPATH)/.deps
$(shell mkdir -p $(DEPDIR) >/dev/null)

# cleanCDeps removes from the CRTCMOD-generated dependency file any header files located in /QIBM/, plus the
# original .C file that is included for some reason, and adds the correct suffix to the target (SO1001 -> SO1001.MODULE).
cleanCDeps = awk '$$2 !~ /^\/QIBM\// && $$2 !~ /$(notdir $<)$$/ { sub("^.*/","",$$2); sub("^$*","$@",$$1); print $$1 " " toupper($$2) }'

# This defines the steps taken after a C compile to massage the auto-generated dependencies into a useable form.
# See http://make.mad-scientist.net/papers/advanced-auto-dependency-generation/#tldr
define POSTCCOMPILE =
iconv -f IBM-037 -t ISO8859-1 $(DEPDIR)/$*.Td | tr -d '\r' > $(DEPDIR)/$*.T2d
$(cleanCDeps) <$(DEPDIR)/$*.T2d >$(DEPDIR)/$*.d
touch -cr $(OBJPATH)/$@ $(DEPDIR)/$*.d
rm $(DEPDIR)/$*.Td $(DEPDIR)/$*.T2d
endef

# These variables allow pattern-specific variables to be used when multiple source patterns exist for one object pattern (like with *FILEs).
# The pattern-specific variable will set itself to a variable below, which will then be evaluated
# from the context of that pattern-matched rule. This can be used to set specific compile parameters
# for each type of, for example, file object (PF, LF, DSPF, etc.).
# The advantage of this approach over simply hard-coding values in the recipe is that individual targets (compiled objects)
# will be able to override these values with their own, thereby overriding these defaults.
# This elaborate construct is to work around a limitation in Make (`%.object: %.source variable=value` does not work).
#
# Determine default settings for the various source types that can make a module ojbect.
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
moduleSTGMDL = $(strip \
	$(if $(filter %.C,$<),$(CMOD_STGMDL), \
	UNKNOWN_FILE_TYPE))
moduleTGTRLS = $(strip \
	$(if $(filter %.C,$<),$(CMOD_TGTRLS), \
	$(if $(filter %.CLLE,$<),$(CLMOD_TGTRLS), \
	$(if $(filter %.RPGLE,$<),$(RPGMOD_TGTRLS), \
	$(if $(filter %.SQLC,$<),$(SQLCIMOD_TGTRLS), \
	$(if $(filter %.SQLRPGLE,$<),$(SQLRPGIMOD_TGTRLS), \
	UNKNOWN_FILE_TYPE))))))

# Determine default settings for the various source types that can make a program ojbect.
programACTGRP = $(strip \
	$(if $(filter %.CLLE,$<),$(BNDCL_ACTGRP), \
	$(if $(filter %.MODULE,$<),$(PGM_ACTGRP), \
	UNKNOWN_FILE_TYPE)))
programAUT = $(strip \
	$(if $(filter %.CLLE,$<),$(BNDCL_AUT), \
	$(if $(filter %.MODULE,$<),$(PGM_AUT), \
	UNKNOWN_FILE_TYPE)))
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
	UNKNOWN_FILE_TYPE))))))
programSTGMDL = $(strip \
	$(if $(filter %.MODULE,$<),$(PGM_STGMDL), \
	UNKNOWN_FILE_TYPE))))))
programTGTRLS = $(strip \
	$(if $(filter %.CLLE,$<),$(BNDCL_TGTRLS), \
	$(if $(filter %.SQLC,$<),$(SQLCIPGM_TGTRLS), \
	$(if $(filter %.SQLRPGLE,$<),$(SQLRPGIPGM_TGTRLS), \
	$(if $(filter %.MODULE,$<),$(PGM_TGTRLS), \
	UNKNOWN_FILE_TYPE)))))

CRTFRMSTMFLIB := CRTFRMSTMF
VPATH := $(OBJPATH):$(SRCPATH)

### Implicit rules
%.CMD: private AUT = $(CMD_AUT)
%.CMD: %.CMD
	@echo "\n\n***"
	@echo "*** Creating command [$*]"
	@echo "***"
	$(eval crtcmd := $(CRTFRMSTMFLIB)/crtfrmstmf obj($(OBJLIB)/$*) cmd(CRTCMD) stmf('$<') parms('$(CRTCMDFLAGS)'))
	@system -v "$(SDELIB)/EXECWTHLIB LIB($(OBJLIB)) CMD($(crtcmd))" > $(LOGPATH)/$(notdir $<).log


%.FILE: %.DSPF
	@echo "\n\n***"
	@echo "*** Creating DSPF [$*]"
	@echo "***"
	$(eval crtcmd := $(CRTFRMSTMFLIB)/crtfrmstmf obj($(OBJLIB)/$*) cmd(CRTDSPF) stmf('$<') parms('$(CRTDSPFFLAGS)'))
	@system -v "$(SDELIB)/EXECWTHLIB LIB($(OBJLIB)) CMD($(crtcmd))" > $(LOGPATH)/$(notdir $<).log

%.FILE: %.LF
	@echo "\n\n***"
	@echo "*** Creating LF [$*]"
	@echo "***"
	$(eval crtcmd := $(CRTFRMSTMFLIB)/crtfrmstmf obj($(OBJLIB)/$*) cmd(CRTLF) stmf('$<') parms('$(CRTLFFLAGS)'))
	@system -v "$(SDELIB)/EXECWTHLIB LIB($(OBJLIB)) CMD($(crtcmd))" > $(LOGPATH)/$(notdir $<).log

%.FILE: %.PF
	@echo "\n\n***"
	@echo "*** Creating PF [$*]"
	@echo "***"
	@$(SDEPATH)/dltpfdeps -p $* $(OBJLIB)
	$(eval crtcmd := $(CRTFRMSTMFLIB)/crtfrmstmf obj($(OBJLIB)/$*) cmd(CRTPF) stmf('$<') parms('$(CRTPFFLAGS)'))
	@system -v "$(SDELIB)/EXECWTHLIB LIB($(OBJLIB)) CMD($(crtcmd))" > $(LOGPATH)/$(notdir $<).log


%.MODULE: private AUT = $(moduleAUT)
%.MODULE: private DBGVIEW = $(moduleDBGVIEW)
%.MODULE: private OBJTYPE = $(moduleOBJTYPE)
%.MODULE: private OPTION = $(moduleOPTION)
%.MODULE: private STGMDL = $(moduleSTGMDL)
%.MODULE: private TGTRLS = $(moduleTGTRLS)

%.MODULE: %.C $(DEPDIR)/%.d
	@echo "\n\n***"
	@echo "*** Creating module [$*]"
	@echo "***"
	$(eval crtcmd := crtcmod module($(OBJLIB)/$*) srcstmf('$<') $(CRTCMODFLAGS))
	@system -v "$(SDELIB)/EXECWTHLIB LIB($(OBJLIB)) CMD($(crtcmd))" > $(LOGPATH)/$(notdir $<).log
	@$(POSTCCOMPILE)

%.MODULE: %.CLLE
	@echo "\n\n***"
	@echo "*** Creating CL module [$*]"
	@echo "***"
	$(eval crtcmd := $(CRTFRMSTMFLIB)/crtfrmstmf obj($(OBJLIB)/$*) cmd(CRTCLMOD) stmf('$<'))
	@system -v "$(SDELIB)/EXECWTHLIB LIB($(OBJLIB)) CMD($(crtcmd))" > $(LOGPATH)/$(notdir $<).log

%.MODULE: %.RPGLE
	@echo "\n\n***"
	@echo "*** Creating module [$*]"
	@echo "***"
	$(eval crtcmd := crtrpgmod module($(OBJLIB)/$*) srcstmf('$<') $(CRTRPGMODFLAGS))
	@system -v "$(SDELIB)/EXECWTHLIB LIB($(OBJLIB)) CMD($(crtcmd))" > $(LOGPATH)/$(notdir $<).log

%.MODULE: %.SQLRPGLE
	@echo "\n\n***"
	@echo "*** Creating SQLRPGLE module [$*]"
	@echo "***"
	$(eval crtcmd := crtsqlrpgi obj($(OBJLIB)/$*) srcstmf('$<') $(CRTSQLRPGIFLAGS))
	@system -v "$(SDELIB)/EXECWTHLIB LIB($(OBJLIB)) CMD($(crtcmd))" > $(LOGPATH)/$(notdir $<).log


%.PGM: private ACTGRP = $(programACTGRP)
%.PGM: private AUT = $(programAUT)
%.PGM: private DBGVIEW = $(programDBGVIEW)
%.PGM: private DETAIL = $(programDETAIL)
%.PGM: private DFTACTGRP = $(programDFTACTGRP)
%.PGM: private OBJTYPE = $(programOBJTYPE)
%.PGM: private OPTION = $(programOPTION)
%.PGM: private STGMDL = $(programSTGMDL)
%.PGM: private TGTRLS = $(programTGTRLS)

%.PGM: %.CLLE
	@echo "\n\n***"
	@echo "*** Creating bound CL program [$*]"
	@echo "***"
	$(eval crtcmd := $(CRTFRMSTMFLIB)/crtfrmstmf obj($(OBJLIB)/$*) cmd(CRTBNDCL) stmf('$<') parms('$(CRTBNDCLFLAGS)'))
	@system -v "$(SDELIB)/EXECWTHLIB LIB($(OBJLIB)) CMD($(crtcmd))" > $(LOGPATH)/$@.log

%.PGM: %.SQLC
	@echo "\n\n***"
	@echo "*** Creating bound SQLC program [$*]"
	@echo "***"
	$(eval crtcmd := crtsqlci obj($(OBJLIB)/$*) srcstmf('$<') $(CRTSQLCIFLAGS))
	@system -v "$(SDELIB)/EXECWTHLIB LIB($(OBJLIB)) CMD($(crtcmd))" > $(LOGPATH)/$(notdir $<).log

%.PGM: %.SQLRPGLE
	@echo "\n\n***"
	@echo "*** Creating bound SQLRPGLE program [$*]"
	@echo "***"
	$(eval crtcmd := crtsqlrpgi obj($(OBJLIB)/$*) srcstmf('$<') $(CRTSQLRPGIFLAGS))
	@system -v "$(SDELIB)/EXECWTHLIB LIB($(OBJLIB)) CMD($(crtcmd))" > $(LOGPATH)/$(notdir $<).log

%.PGM: $^
	@echo "\n\n***"
	@echo "*** Creating program [$*] from modules [$^]"
	@echo "***"
	$(eval crtcmd := crtpgm pgm($(OBJLIB)/$*) module($(basename $(filter %.MODULE,$(notdir $^)))) bndsrvpgm($(basename $(filter %.SRVPGM,$(notdir $^)))) $(CRTPGMFLAGS))
	system -v "$(SDELIB)/EXECWTHLIB LIB($(OBJLIB)) CMD($(crtcmd))" > $(LOGPATH)/$@.log


%.SRVPGM: private ACTGRP = $(SRVPGM_ACTGRP)
%.SRVPGM: private AUT = $(SRVPGM_AUT)
%.SRVPGM: private DETAIL = $(SRVPGM_DETAIL)
%.SRVPGM: private STGMDL = $(SRVPGM_STGMDL)
%.SRVPGM: private TGTRLS = $(SRVPGM_TGTRLS)
%.SRVPGM: $^
	@echo "\n\n***"
	@echo "*** Creating service program [$*] from modules [$^]"
	@echo "***"
	$(eval crtcmd := crtsrvpgm srvpgm($(OBJLIB)/$*) module($(basename $(filter %.MODULE,$(notdir $^))))  bndsrvpgm($(basename $(filter %.SRVPGM,$(notdir $^)))) $(CRTSRVPGMFLAGS))
	system -v "$(SDELIB)/EXECWTHLIB LIB($(OBJLIB)) CMD($(crtcmd))" > $(LOGPATH)/$@.log

$(DEPDIR)/%.d: ;
.PRECIOUS: $(DEPDIR)/%.d

### Rules
include $(INCLUDEMAKEFILES)


#.PHONY: make_pre
#make_pre:
#	mkdir -p $(LOGPATH)


.PHONY: make_post
make_post:
	@echo "\n\n***"
	@echo "*** Source directory:\t$(SRCPATH)"
	@echo "*** Target library:\t$(OBJLIB)"
	@echo "*** Compile listings:\t$(LOGPATH)"
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
	echo "INCLUDEMAKEFILES:	$(INCLUDEMAKEFILES)";

# Include all auto-generated source dependency files. Since we don't have a list of source files,
# we have to grab everything in the `$DEPDIR` directory.
-include $(wildcard $(DEPDIR)/*.d)