from makei.rules_mk import RulesMk, MKRule
from tests.lib.const import DATA_PATH

data_dir = DATA_PATH / "rules_mks"


def test_from_file():
    # Test loading from a valid file
    rules_mk = RulesMk.from_file(data_dir / "a.rules.mk")
    expected_targets = {'TRGs': [], 'DTAARAs': [], 'SQLs': [], 'BNDDs': [], 'PFs': [], 'LFs': [], 'DSPFs': [],
                        'PRTFs': [], 'CMDs': [], 'MODULEs': ['VAT300.MODULE'], 'SRVPGMs': [], 'PGMs': [], 'MENUs': [],
                        'PNLGRPs': [], 'QMQRYs': [], 'WSCSTs': [], 'MSGs': []}
    variables1 = ['private DFTACTGRP = *NO', 'private TEXT := Andy is cool', 'private VARSHELL ?= SHELL',
                  'private VARAPPEND += TOAPPEND', 'private VARAPPEND+=APPEND2 # we support end of line comments',
                  'private VARIMMED ::= IMMED', 'private VARESCAPE :::= ESCAPE']
    mkrule1 = MKRule('VAT300.MODULE', ['vat300.rpgle', 'some.rpgleinc'], [], variables1, data_dir, [])
    expected_rules = [mkrule1]
    assert rules_mk.containing_dir == data_dir
    assert rules_mk.subdirs == ['adir', 'bdir']
    assert rules_mk.targets == expected_targets
    assert rules_mk.rules[0].variables == variables1
    assert rules_mk.rules[0] == expected_rules[0]
    assert rules_mk.build_context is None
    assert str(mkrule1) == '''VAT300.MODULE_SRC=vat300.rpgle\nVAT300.MODULE_DEP=some.rpgleinc
VAT300.MODULE_RECIPE=RPGLE_TO_MODULE_RECIPE
VAT300.MODULE: private DFTACTGRP = *NO
VAT300.MODULE: private TEXT := Andy is cool
VAT300.MODULE: private VARSHELL ?= SHELL
VAT300.MODULE: private VARAPPEND += TOAPPEND
VAT300.MODULE: private VARAPPEND+=APPEND2 # we support end of line comments
VAT300.MODULE: private VARIMMED ::= IMMED
VAT300.MODULE: private VARESCAPE :::= ESCAPE
'''
    assert str(rules_mk) == '''SUBDIRS := adir bdir

MODULEs := VAT300.MODULE


VAT300.MODULE_SRC=vat300.rpgle
VAT300.MODULE_DEP=some.rpgleinc
VAT300.MODULE_RECIPE=RPGLE_TO_MODULE_RECIPE
VAT300.MODULE: private DFTACTGRP = *NO
VAT300.MODULE: private TEXT := Andy is cool
VAT300.MODULE: private VARSHELL ?= SHELL
VAT300.MODULE: private VARAPPEND += TOAPPEND
VAT300.MODULE: private VARAPPEND+=APPEND2 # we support end of line comments
VAT300.MODULE: private VARIMMED ::= IMMED
VAT300.MODULE: private VARESCAPE :::= ESCAPE
'''


def test_custom_recipe():
    # Test loading from a valid file
    rules_mk = RulesMk.from_file(data_dir / "custom.rules.mk")
    expected_targets = {'TRGs': [], 'DTAARAs': [], 'SQLs': [], 'BNDDs': [], 'PFs': ['CRTSBSD.FILE'], 'LFs': [],
                        'DSPFs': [], 'PRTFs': [], 'CMDs': [], 'MODULEs': [], 'SRVPGMs': [], 'PGMs': [],
                        'MENUs': [], 'PNLGRPs': [], 'QMQRYs': [], 'WSCSTs': [], 'MSGs': []}
    commands0 = ['@$(call echo_cmd,=== Creating [CRTSBSD.FILE] from custom recipe)',
                 'system -i "CRTSBSD SBSD(BATCHWL/BATCHSBSD) POOLS((1 *SHRPOOL3 *N *MB))"',
                 '@$(call echo_success_cmd,End of creating CRTSBSD.FILE)']
    assert rules_mk.containing_dir == data_dir
    assert rules_mk.subdirs == []
    assert rules_mk.targets == expected_targets
    assert rules_mk.rules[0].variables == []
    assert rules_mk.rules[0].commands == commands0
    assert rules_mk.rules[0].dependencies == []
    assert rules_mk.rules[0].include_dirs == []
    assert rules_mk.rules[0].target == 'CRTSBSD.FILE'
    assert rules_mk.rules[0].source_file is None
    assert rules_mk.build_context is None
    assert str(rules_mk.rules[0]) == '''CRTSBSD.FILE_CUSTOM_RECIPE=true
CRTSBSD.FILE : \n\t@$(call echo_cmd,=== Creating [CRTSBSD.FILE] from custom recipe)
\tsystem -i "CRTSBSD SBSD(BATCHWL/BATCHSBSD) POOLS((1 *SHRPOOL3 *N *MB))"
\t@$(call echo_success_cmd,End of creating CRTSBSD.FILE)
'''
    assert str(rules_mk) == '''PFs := CRTSBSD.FILE


CRTSBSD.FILE_CUSTOM_RECIPE=true
CRTSBSD.FILE : \n\t@$(call echo_cmd,=== Creating [CRTSBSD.FILE] from custom recipe)
\tsystem -i "CRTSBSD SBSD(BATCHWL/BATCHSBSD) POOLS((1 *SHRPOOL3 *N *MB))"
\t@$(call echo_success_cmd,End of creating CRTSBSD.FILE)
'''


def test_dtaara_recipe():
    # Test loading from a valid file
    rules_mk = RulesMk.from_file(data_dir / "dtaara.rules.mk")
    expected_targets = {'TRGs': [], 'DTAARAs': ['LASTORDNO.DTAARA'], 'SQLs': [], 'BNDDs': [], 'PFs': [], 'LFs': [],
                        'DSPFs': [], 'PRTFs': [], 'CMDs': [], 'MODULEs': [], 'SRVPGMs': [], 'PGMs': [],
                        'MENUs': [], 'PNLGRPs': [], 'QMQRYs': [], 'WSCSTs': [], 'MSGs': []}

    assert rules_mk.containing_dir == data_dir
    assert rules_mk.subdirs == []
    assert rules_mk.targets == expected_targets
    assert rules_mk.rules[0].variables == []
    assert rules_mk.rules[0].commands == []
    assert rules_mk.rules[0].dependencies == []
    assert rules_mk.rules[0].include_dirs == []
    assert rules_mk.rules[0].target == 'LASTORDNO.DTAARA'
    assert rules_mk.rules[0].source_file == 'LASTORDNO.DTAARA'
    assert str(rules_mk.rules[0]) == '''LASTORDNO.DTAARA_SRC=LASTORDNO.DTAARA
LASTORDNO.DTAARA_DEP=
LASTORDNO.DTAARA_RECIPE=DTAARA_TO_DTAARA_RECIPE\n'''
    assert str(rules_mk) == '''DTAARAs := LASTORDNO.DTAARA\n\n
LASTORDNO.DTAARA_SRC=LASTORDNO.DTAARA
LASTORDNO.DTAARA_DEP=
LASTORDNO.DTAARA_RECIPE=DTAARA_TO_DTAARA_RECIPE
'''

def test_dtaq_recipe():
    # Test loading from a valid file
    rules_mk = RulesMk.from_file(data_dir / "dtaq.rules.mk")
    expected_targets = {'TRGs': [], 'DTAARAs': [], 'DTAQs': ['ORDERS.DTAQ'], 'SQLs': [], 'BNDDs': [], 'PFs': [], 'LFs': [],
                        'DSPFs': [], 'PRTFs': [], 'CMDs': [], 'MODULEs': [], 'SRVPGMs': [], 'PGMs': [],
                        'MENUs': [], 'PNLGRPs': [], 'QMQRYs': [], 'WSCSTs': [], 'MSGs': []}

    assert rules_mk.containing_dir == data_dir
    assert rules_mk.subdirs == []
    assert rules_mk.targets == expected_targets
    assert rules_mk.rules[0].variables == []
    assert rules_mk.rules[0].commands == []
    assert rules_mk.rules[0].dependencies == []
    assert rules_mk.rules[0].include_dirs == []
    assert rules_mk.rules[0].target == 'ORDERS.DTAQ'
    assert rules_mk.rules[0].source_file == 'ORDERS.DTAQ'
    assert str(rules_mk.rules[0]) == '''ORDERS.DTAQ_SRC=ORDERS.DTAQ
ORDERS.DTAQ_DEP=
ORDERS.DTAQ_RECIPE=DTAQ_TO_DTAQ_RECIPE\n'''
    assert str(rules_mk) == '''DTAQs := ORDERS.DTAQ\n\n
ORDERS.DTAQ_SRC=ORDERS.DTAQ
ORDERS.DTAQ_DEP=
ORDERS.DTAQ_RECIPE=DTAQ_TO_DTAQ_RECIPE
'''



def test_dds_recipe():
    # Test loading from a valid file
    rules_mk = RulesMk.from_file(data_dir / "dds.rules.mk")
    expected_targets = {'TRGs': [], 'DTAARAs': [], 'SQLs': [], 'BNDDs': [], 'PFs': ['ARTICLE.FILE',
                        'DETORD.FILE', 'TMPDETORD.FILE'], 'LFs': [], 'DSPFs': ['ART301D.FILE'],
                        'PRTFs': ['ORD500O.FILE'], 'CMDs': [], 'MODULEs': [], 'SRVPGMs': [], 'PGMs': [],
                        'MENUs': [], 'PNLGRPs': [], 'QMQRYs': [], 'WSCSTs': [], 'MSGs': []}

    assert rules_mk.containing_dir == data_dir
    assert rules_mk.subdirs == []
    assert rules_mk.targets == expected_targets
    assert rules_mk.rules[0].variables == []
    assert rules_mk.rules[0].commands == []
    assert rules_mk.rules[0].dependencies == ['SAMREF.FILE']
    assert rules_mk.rules[0].include_dirs == []
    assert rules_mk.rules[0].target == 'ARTICLE.FILE'
    assert rules_mk.rules[0].source_file == 'ARTICLE-Article_File.PF'
    assert str(rules_mk.rules[0]) == '''ARTICLE.FILE_SRC=ARTICLE-Article_File.PF\nARTICLE.FILE_DEP=SAMREF.FILE
ARTICLE.FILE_RECIPE=PF_TO_FILE_RECIPE\n'''

    assert rules_mk.rules[1].variables == []
    assert rules_mk.rules[1].commands == []
    assert rules_mk.rules[1].dependencies == ['ARTICLE.FILE', 'VATDEF.FILE']
    assert rules_mk.rules[1].include_dirs == []
    assert rules_mk.rules[1].target == 'ART301D.FILE'
    assert rules_mk.rules[1].source_file == 'ART301D-Function_Select_an_article.DSPF'
    assert str(rules_mk.rules[1]) == '''ART301D.FILE_SRC=ART301D-Function_Select_an_article.DSPF
ART301D.FILE_DEP=ARTICLE.FILE VATDEF.FILE\nART301D.FILE_RECIPE=DSPF_TO_FILE_RECIPE\n'''

    assert rules_mk.rules[4].variables == []
    assert rules_mk.rules[4].commands == ['@$(call echo_cmd,=== Creating [TMPDETORD.FILE] from custom recipe)',
                                          'system -i "CPYF FROMFILE($(OBJLIB)/DETORD) TOFILE($(OBJLIB)/TMPDETORD) \\',
                                          'CRTFILE(*YES)"',
                                          '@$(call echo_success_cmd,End of creating TMPDETORD.FILE)']
    assert rules_mk.rules[4].dependencies == []
    assert rules_mk.rules[4].include_dirs == []
    assert rules_mk.rules[4].target == 'TMPDETORD.FILE'
    assert rules_mk.rules[4].source_file is None
    assert str(rules_mk.rules[4]) == '''TMPDETORD.FILE_CUSTOM_RECIPE=true
TMPDETORD.FILE : \n\t@$(call echo_cmd,=== Creating [TMPDETORD.FILE] from custom recipe)
\tsystem -i "CPYF FROMFILE($(OBJLIB)/DETORD) TOFILE($(OBJLIB)/TMPDETORD) \\
\tCRTFILE(*YES)"\n\t@$(call echo_success_cmd,End of creating TMPDETORD.FILE)\n'''

    assert str(rules_mk) == '''PFs := ARTICLE.FILE DETORD.FILE TMPDETORD.FILE
DSPFs := ART301D.FILE
PRTFs := ORD500O.FILE\n\n
ARTICLE.FILE_SRC=ARTICLE-Article_File.PF\nARTICLE.FILE_DEP=SAMREF.FILE
ARTICLE.FILE_RECIPE=PF_TO_FILE_RECIPE
ART301D.FILE_SRC=ART301D-Function_Select_an_article.DSPF
ART301D.FILE_DEP=ARTICLE.FILE VATDEF.FILE
ART301D.FILE_RECIPE=DSPF_TO_FILE_RECIPE\nDETORD.FILE_SRC=DETORD.PF
DETORD.FILE_DEP=SAMREF.FILE
DETORD.FILE_RECIPE=PF_TO_FILE_RECIPE\nORD500O.FILE_SRC=ORD500O.PRTF
ORD500O.FILE_DEP=ORDER.FILE CUSTOMER.FILE DETORD.FILE ARTICLE.FILE
ORD500O.FILE_RECIPE=PRTF_TO_FILE_RECIPE\nTMPDETORD.FILE_CUSTOM_RECIPE=true
TMPDETORD.FILE : \n\t@$(call echo_cmd,=== Creating [TMPDETORD.FILE] from custom recipe)
\tsystem -i "CPYF FROMFILE($(OBJLIB)/DETORD) TOFILE($(OBJLIB)/TMPDETORD) \\
\tCRTFILE(*YES)"
\t@$(call echo_success_cmd,End of creating TMPDETORD.FILE)
'''
