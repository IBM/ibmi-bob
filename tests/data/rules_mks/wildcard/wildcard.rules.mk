TGTVER := *PRV
# need to support when no blanks delimiting the equals
CURRENT:=V7R5
HEADER := some

# test base wildcard with variables
%.MODULE: %.rpgle $(HEADER).rpgleinc
# test case sensitivity and overriding
Foo.MODULE: TGTVER=$(CURRENT)
# # override different var
%.MODULE: TEXT := hardcoded for all mod
foo.MODule: private TEXT := foo is better
foo.MODULE: TGTVER := V7R2
# # now support multi line dependencies
%.PGM: %.pgm.rpgle \
# This comment should not impact this rule \
       DB1.FILE


