# Clear vars used by this make system
define HEADER
CLEAN :=
TARGETS = $(TRGs) $(DTAs) $(SQLs) $(BNDs) $(PFs) $(LFs) $(DSPFs) $(PRTFs) $(CMDs) $(SQLs) $(MODULEs) $(SRVPGMs) $(PGMs) $(MENUs) $(PNLGRPs) $(QMQRYs) $(WSCSTs) $(MSGs)
SUBDIRS :=

TRGs :=
DTAs :=
SQLs :=
BNDDs :=
PFs :=
LFs :=
DSPFs :=
PRTFs :=
CMDs :=
SQLs :=
MODULEs :=
SRVPGMs :=
PGMs :=
MENUs :=
PNLGRPs :=
QMQRYs :=
WSCSTs :=
MSGs :=

# Clear user vars
$(foreach v,$(VERB_VARS) $(OBJ_VARS) $(DIR_VARS),$(eval $(v) := ))
endef
