TGTVER := *PRV
# need to support when no blanks delimiting the equals
CURRENT:=V7R5
HEADER := some
COMMIT = *NONE
VERSION=V7R3

# test base wildcard with variables
%.MODULE: %.rpgle $(HEADER).rpgleinc
# test case sensitivity and overriding
Foo.MODULE: TGTVER=$(CURRENT)
# test overriding different vars
%.MODULE: TEXT := hardcoded for all mod
foo.MODule: private TEXT := foo is better
foo.MODULE: TGTVER := V7R2
# test regular equals in vars
bar.MODULE: COMMIT = $(COMMIT)
bar.MODULE: TGTVER:=$(VERSION)
# test support of multi line dependencies
bar.MODULE: bar.rpgle \
			bar.TABLE
# test if this very \
cool multiline comment \
is ignored