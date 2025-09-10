TGTVER := *PRV
# need to support when no blanks delimiting the equals
CURRENT :=V7R5
HEADER := some
COMMIT :=*NONE
VERSION :=V7R3

# test base wildcard with variables
%.MODULE: %.rpgle $(HEADER).rpgleinc
# test case sensitivity and overriding
# test overriding different vars
%.MODULE: TEXT := hardcoded for all mod

AB2001_B.MODULE: AB2001_B.rpgle
AB2001_B.MODULE: TGTVER := V7R4

AB2001.B.MODULE: AB2001.B.rpgle
AB2001.B.MODULE: TGTVER := V7R4

bar.MODULE: COMMIT :=$(COMMIT)
bar.MODULE: TGTVER :=$(VERSION)
# test support of multi line dependencies
bar.MODULE: bar.rpgle \
			bar.TABLE
Foo.MODULE: TGTVER :=$(CURRENT)
# test overriding different vars
foo.MODule: private TEXT := foo is better
foo.MODULE: TGTVER := V7R2
# test if this very \
cool multiline comment \
is ignored