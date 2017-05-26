#
# This is a project-specific makefile for building Product XYZ, and is to be
# used with Bob, the Better Object Builder for IBM i.  It defines
# object and dependency definitions.  It also `include`s the generic IBM i
# Makefile that specifies how IBM i objects are built.
#
# To invoke from a shell:
#   o cd /some/path/that's/not/in/QSYS.LIB
#   o make all OBJPATH:=/QSYS.LIB/<object_lib>.LIB -f '/path/to/this/makefile'
#


########## BOB HEADER SECTION -- DO NOT MODIFY ##########

### IBMiMake setup
PROJECTDIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# Include generic IBM i makefile.  Its location is stored in an environment variable called IBMIMAKE.
ifeq ($(strip $(IBMIMAKE)),)
$(warning Environment variable 'IBMIMAKE' not set.  Defaulting to $(realpath $(PROJECTDIR)/../../Bob/IBMiMake))
IBMIMAKE := $(PROJECTDIR)/../../Bob/IBMiMake
else
$(info Using IBMiMake file: $(realpath $(IBMIMAKE)))
endif
include $(IBMIMAKE)

### Define type-specific targets and their dependencies
.PHONY: all PFs LFs DSPFs PRTFs CMDs MODULEs SRVPGMs PGMs MENUs PNLGRPs QMQRYs WSCSTs make_post
all: PFs LFs DSPFs PRTFs CMDs MODULEs SRVPGMs PGMs MENUs PNLGRPs QMQRYs WSCSTs make_post

LFs: PFs
DSPFs PRTFs: LFs
MODULEs: PFs LFs DSPFs PRTFs
SRVPGMs: MODULEs
PGMs: SRVPGMs
########## END OF "DO NOT MODIFY" SECTION ##########


########## LIST OF OBJECTS TO BUILD, GROUPED BY TYPE ##########
### Define user objects to type-specific targets so they're compiled in the
### correct order.  This section declares _what_ to build.

PFs: TEST01.FILE

LFs: TEST01A.FILE

DSPFs: 

PRTFs: 

CMDs: BOBTEST.CMD

MODULEs: TEST010.MODULE

SRVPGMs: 

PGMs: TEST010.PGM

MENUs: 

PNLGRPs: 

QMQRYs: 

WSCSTs: 


########## OBJECT RULES, DEPENDENCIES AND CUSTOM COMPILE SETTINGS ##########
### Define dependency information and custom compile settings for each object.
### This section declares _how_ to build.  Please list rules alphabetically.

# TEST01.FILE -- CRTPF
TEST01.FILE: TEST01.PF

# TEST01A.FILE -- CRTLF
TEST01A.FILE: TEST01A.LF TEST01.FILE

# TEST010.MODULE -- CRTRPGMOD
TEST010.MODULE: TEST010.RPGLE TEST01A.FILE

# TEST010.PGM -- CRTPGM
TEST010.PGM: TEST010.MODULE

# BOBTEST.CMD -- CRTCMD
BOBTEST.CMD: BOBTEST.CMDSRC
BOBTEST.CMD: private PGM := BOBTEST/TEST010


########## THIS SECTION MUST BE AT THE END OF THE MAKEFILE ##########

# Include all auto-generated source dependency files. Since we don't have a
# hard-coded list of source files, we will grab everything in the `$DEPDIR`
# directory.
-include $(wildcard $(DEPDIR)/*.d)
