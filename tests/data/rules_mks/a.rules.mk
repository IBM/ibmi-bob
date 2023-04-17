SUBDIRS=adir bdir

VAT300.MODULE: vat300.rpgle some.rpgleinc
VAT300.MODULE: private DFTACTGRP = *NO
VAT300.MODULE: private TEXT := Andy is cool
VAT300.MODULE: private VARSHELL ?= SHELL
VAT300.MODULE: private VARAPPEND += TOAPPEND
VAT300.MODULE: private VARAPPEND+=APPEND2 # we support end of line comments
VAT300.MODULE: private VARIMMED ::= IMMED
VAT300.MODULE: private VARESCAPE :::= ESCAPE