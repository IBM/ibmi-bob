# For the reference here are some automatic variables defined by make.
# There are also their D/F variants e.g. $(<D) - check the manual.
#
# $@ - file name of the target of the rule
# $% - target member name when the target is archive member
# $< - the name of the first dependency
# $? - the names of all dependencies that are newer then the target
# $^ - the names of all dependencies


# Kept for backward compatibility - you should stop using these since
# I'm now not dependent on $(OBJDIR)/.fake_file any more
?R = $?
^R = $^

# Where to put the compiled objects.  You can e.g. make it different
# depending on the target platform (e.g. for cross-compilation a good
# choice would be OBJDIR := obj/$(HOST_ARCH)) or debugging being on/off.
OBJDIR := $(obj)

# Convenience function to convert from a build directory back to the
# "real directory" of a target
define build_to_real_dir
$(if $(strip $(TOP_BUILD_DIR)),$(patsubst $(TOP_BUILD_DIR)%/$(OBJDIR),$(TOP)%,$(1)),$(patsubst %/$(OBJDIR),%,$(1)))
endef

# Convenience function to convert from the "real directory" to the build
# directory
define real_to_build_dir
$(if $(strip $(TOP_BUILD_DIR)),$(TOP_BUILD_DIR)$(subst $(TOP),,$(1))/$(OBJDIR),$(1)/$(OBJDIR))
endef

# By default OBJDIR is relative to the directory of the corresponding Rules.mk
# however you can use TOP_BUILD_DIR to build all objects outside of your
# project tree.  This should be an absolute path.  Note that it can be
# also inside your project like example below.
#TOP_BUILD_DIR := $(TOP)/build_dir
OBJPATH = $(call real_to_build_dir,$(d))
CLEAN_DIR = $(call real_to_build_dir,$(subst clean_,,$@))
DIST_CLEAN_DIR = $(patsubst %/$(OBJDIR),%/$(firstword $(subst /, ,$(OBJDIR))),\
				 $(call real_to_build_dir,$(subst dist_clean_,,$@)))

# This variable contains a list of subdirectories where to look for
# sources.  That is if you have some/dir/Rules.mk where you name object
# say client.o this object will be created in some/dir/$(OBJDIR)/ and
# corresponding source file will be searched in some/dir and in
# some/dir/{x,y,z,...} where "x y z ..." is value of this variable.
SRCS_VPATH := src

# Target "real directory" - this is used above already and is most
# reliable way to refer to "per directory flags".  In theory one could
# use automatic variable already defined by make "<D" but this will not
# work well when somebody uses SRCS_VPATH variable.
@RD = $(call build_to_real_dir,$(@D))

# This can be useful.  E.g. if you want to set INCLUDES_$(d) for given
# $(d) to the same value as includes for its parent directory plus some
# add ons then: INCLUDES_$(d) := $(INCLUDES_$(parent_dir)) ...
parent_dir = $(patsubst %/,%,$(dir $(d)))

UC = $(shell echo '$*' | tr '[:lower:]' '[:upper:]')

define include_subdir_rules
dir_stack := $(d) $(dir_stack)
d := $(d)/$(1)
$$(eval $$(value HEADER))
include $(addsuffix /.Rules.mk.build,$$(d))
$$(eval $$(value FOOTER))
d := $$(firstword $$(dir_stack))
dir_stack := $$(wordlist 2,$$(words $$(dir_stack)),$$(dir_stack))
endef


define tgt_rule
abs_deps := $$(foreach dep,$$(DEPS_$(1)),$$(if $$(or $$(filter /%,$$(dep)),$$(filter $$$$%,$$(dep))),$$(dep),$$(addprefix $(OBJPATH)/,$$(dep))))
-include $$(addsuffix .d,$$(basename $$(abs_deps)))
$(1): $$(abs_deps) $(if $(findstring $(OBJDIR),$(1)),| $(OBJPATH),)
	$$(or $$(CMD_$(1)),$$(MAKECMD$$(suffix $$@)),$$(DEFAULT_MAKECMD))
endef

# subtree_tgts is now just a special case of a more general get_subtree
# macro since $(call get_subtree,TARGETS,dir) has the same effect but
# I'm keeping it for backward compatibility
define subtree_tgts
$(TARGETS_$(1)) $(foreach sd,$(SUBDIRS_$(1)),$(call subtree_tgts,$(sd)))
endef

define get_subtree
$($(1)_$(2)) $(foreach sd,$(SUBDIRS_$(2)),$(call get_subtree,$(1),$(sd)))
endef

define get_target_type
$(call UC,$(subst .,,$(suffix $1)))
endef

define get_file_type
$(shell export FILE="$1" && echo "$${FILE#*.}  | tr '[:lower:]' '[:upper:]")
endef

define get_recipe_name
$(if $(filter %.SQL %.MSGF,$(1)),$(call get_target_type,$2)_RECIPE,$(call get_file_type,$1)_TO_$(call get_target_type,$2)_RECIPE)
endef

# target_name := $1
# source_name := $2
# dependencies := $3
define generate_rule
ifndef ${1}_CUSTOM_RECIPE
${1}: ${2} ${3} ; $$(eval @=$1)$$(eval <=$2)$$(eval tgt=$(basename $1))$$(eval ^=$2 $3)$${$(call get_recipe_name,$(2),$(1))}
endif
endef


# if we are using out of project build tree then there is no need to
# have dist_clean on per directory level and the one below is enough
ifneq ($(strip $(TOP_BUILD_DIR)),)
dist_clean :
	rm -rf $(TOP_BUILD_DIR)
endif

# Suck in the default rules
include $(MK)/def_rules.mk
