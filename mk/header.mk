# Clear vars used by this make system
define HEADER
CLEAN :=
TARGETS = $(PFs) $(LFs) $(DSPFs) $(PRTFs) $(CMDs) $(MODULEs) $(SRVPGMs) $(PGMs) $(MENUs) $(PNLGRPs) $(QMQRYs) $(WSCSTs)
SUBDIRS :=


PFs :=
LFs :=
DSPFs :=
PRTFs :=
CMDs :=
MODULEs :=
SRVPGMs :=
PGMs :=
MENUs :=
PNLGRPs :=
QMQRYs :=
WSCSTs :=

# Clear user vars
$(foreach v,$(VERB_VARS) $(OBJ_VARS) $(DIR_VARS),$(eval $(v) := ))
endef
