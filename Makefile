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
#   o make all INCLUDEMAKEFILES:='/path/to/project-specific/makefile.mak' OBJPATH:='/QSYS.LIB/<object_lib>.LIB' -f /location/of/Makefile
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
ACTGRP := E_PRODUCT
AUT := *EXCLUDE
DETAIL := *EXTENDED
OPTION := *EVENTF
COMMIT := *NONE
DBGVIEW := *ALL
TEXT := TEST
RSTDSP := *YES

# Object-type-specific defaults.  Not used directly, but copied to the standard ones above and then
# inserted into the compile commands.  Change these to alter compile defaults for an entire type of
# objects.
PGM_TGTRLS := $(TGTRLS)
PGM_ACTGRP := E_PRODUCT
PGM_AUT := $(AUT)
PGM_DETAIL := $(DETAIL)

SRVPGM_TGTRLS := $(TGTRLS)
SRVPGM_ACTGRP := *CALLER
SRVPGM_AUT := $(AUT)
SRVPGM_DETAIL := $(DETAIL)

RPGMOD_TGTRLS := $(TGTRLS)
RPGMOD_AUT := $(AUT)
RPGMOD_OPTION := $(OPTION)

CMOD_TGTRLS := $(TGTRLS)
CMOD_AUT := $(AUT)
CMOD_OPTION := *EVENTF *SHOWUSR *XREF *AGR

DSPF_AUT := $(AUT)
DSPF_OPTION := *EVENTF *SRC *LIST

# Creation command parameters with variables (the ones listed at the top) for the most common ones.
CRTPFFLAGS = AUT($(AUT)) OPTION(*EVENTF *SRC *LIST) SIZE(*NOMAX) TEXT($(TEXT))
CRTLFFLAGS = AUT($(AUT)) OPTION(*EVENTF *SRC *LIST)
CRTDSPFFLAGS = ENHDSP(*YES) RSTDSP($(RSTDSP)) DFRWRT(*YES) AUT($(AUT)) OPTION($(OPTION)) TEXT($(TEXT))
CRTCMODFLAGS = TERASPACE(*YES *NOTSIFC) STGMDL(*INHERIT) OUTPUT(*PRINT) OPTION($(OPTION)) DBGVIEW($(DBGVIEW)) \
               SYSIFCOPT(*IFSIO) AUT($(AUT)) TGTRLS($(TGTRLS)) MAKEDEP('$(DEPDIR)/$*.Td')
CRTRPGMODFLAGS = DBGVIEW($(DBGVIEW)) TGTRLS($(TGTRLS)) OUTPUT(*PRINT) AUT($(AUT)) OPTION($(OPTION))
CRTSQLRPGIFLAGS = COMMIT($(COMMIT)) OBJTYPE(*MODULE) OUTPUT(*PRINT) TGTRLS($(TGTRLS)) OPTION($(OPTION))
CRTSRVPGMFLAGS = EXPORT(*ALL) ACTGRP($(ACTGRP)) TGTRLS($(TGTRLS)) AUT($(AUT)) DETAIL($(DETAIL))
CRTPGMFLAGS = ACTGRP($(ACTGRP)) USRPRF(*USER) TGTRLS($(TGTRLS)) AUT($(AUT)) DETAIL($(DETAIL))

# Extra command strings for adhoc addition of extra parameters to the creation commands.
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

# Example of setting pattern-specific variable when multiple source patterns exist (like with files).
# The pattern-specific variable would set itself to the variable below, which will then be evaluated
# from the context of that pattern-matched rule. This can be used to set specific compile parameters
# for each type of file object (PF, LF, DSPF, etc.).
#fileParm = $(if $(filter %.PF,$<),PF_value,$(if $(filter %.LF,$<),LF-value,$(if $(filter %.DSPF,$<),DSPF-value,UNKNOWN_FILE_TYPE)))
moduleTGTRLS = $(if $(filter %.C,$<),$(CMOD_TGTRLS),$(if $(filter %.RPGLE,$<),$(RPGMOD_TGTRLS),UNKNOWN_FILE_TYPE))
moduleAUT = $(if $(filter %.C,$<),$(CMOD_AUT),$(if $(filter %.RPGLE,$<),$(RPGMOD_AUT),UNKNOWN_FILE_TYPE))
moduleOPTION = $(if $(filter %.C,$<),$(CMOD_OPTION),$(if $(filter %.RPGLE,$<),$(RPGMOD_OPTION),UNKNOWN_FILE_TYPE))

CRTFRMSTMFLIB = CRTFRMSTMF

VPATH := $(OBJPATH):$(SRCPATH)

### Implicit rules
%.MODULE: private TGTRLS = $(moduleTGTRLS)
%.MODULE: private AUT = $(moduleAUT)
%.MODULE: private OPTION = $(moduleOPTION)

%.MODULE: %.C
%.MODULE: %.C $(DEPDIR)/%.d
	@echo "\n\n***"
	@echo "*** Creating module [$*]"
	@echo "***"
	$(eval crtcmd := crtcmod module($(OBJLIB)/$*) srcstmf('$<') $(CRTCMODFLAGS))
	@system -v "$(SDELIB)/EXECWTHLIB LIB($(OBJLIB)) CMD($(crtcmd))" > $(LOGPATH)/$(notdir $<).log
	@$(POSTCCOMPILE)
	
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

%.FILE: %.PF
	@echo "\n\n***"
	@echo "*** Creating PF [$*]"
	@echo "***"
	@$(SDEPATH)/dltpfdeps -p $* $(OBJLIB)
	$(eval crtcmd := $(CRTFRMSTMFLIB)/crtfrmstmf obj($(OBJLIB)/$*) cmd(CRTPF) stmf('$<') parms('$(CRTPFFLAGS)'))
	@system -v "$(SDELIB)/EXECWTHLIB LIB($(OBJLIB)) CMD($(crtcmd))" > $(LOGPATH)/$(notdir $<).log


%.FILE: %.LF
	@echo "\n\n***"
	@echo "*** Creating LF [$*]"
	@echo "***"
	$(eval crtcmd := $(CRTFRMSTMFLIB)/crtfrmstmf obj($(OBJLIB)/$*) cmd(CRTLF) stmf('$<') parms('$(CRTLFFLAGS)'))
	@system -v "$(SDELIB)/EXECWTHLIB LIB($(OBJLIB)) CMD($(crtcmd))" > $(LOGPATH)/$(notdir $<).log


%.FILE: %.DSPF
	@echo "\n\n***"
	@echo "*** Creating DSPF [$*]"
	@echo "***"
	$(eval crtcmd := $(CRTFRMSTMFLIB)/crtfrmstmf obj($(OBJLIB)/$*) cmd(CRTDSPF) stmf('$<') parms('$(CRTDSPFFLAGS)'))
	@system -v "$(SDELIB)/EXECWTHLIB LIB($(OBJLIB)) CMD($(crtcmd))" > $(LOGPATH)/$(notdir $<).log

%.SRVPGM: private TGTRLS = $(SRVPGM_TGTRLS)
%.SRVPGM: private ACTGRP = $(SRVPGM_ACTGRP)
%.SRVPGM: private AUT = $(SRVPGM_AUT)
%.SRVPGM: private DETAIL = $(SRVPGM_DETAIL)
%.SRVPGM: $^
	@echo "\n\n***"
	@echo "*** Creating service program [$*] from modules [$^]"
	@echo "***"
	$(eval crtcmd := crtsrvpgm srvpgm($(OBJLIB)/$*) module($(basename $^)) $(CRTSRVPGMFLAGS))
	system -v "$(SDELIB)/EXECWTHLIB LIB($(OBJLIB)) CMD($(crtcmd))" > $(LOGPATH)/$@.log

%.PGM: private TGTRLS = $(PGM_TGTRLS)
%.PGM: private ACTGRP = $(PGM_ACTGRP)
%.PGM: private AUT = $(PGM_AUT)
%.PGM: private DETAIL = $(PGM_DETAIL)
%.PGM: $^
	@echo "\n\n***"
	@echo "*** Creating program [$*] from modules [$^]"
	@echo "***"
	$(eval crtcmd := crtpgm pgm($(OBJLIB)/$*) module($(basename $^)) $(CRTPGMFLAGS))
	@system -v "$(SDELIB)/EXECWTHLIB LIB($(OBJLIB)) CMD($(crtcmd))" > $(LOGPATH)/$@.log

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