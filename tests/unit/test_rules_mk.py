from makei.rules_mk import RulesMk, MKRule
from tests.lib.const import DATA_PATH

data_dir = DATA_PATH / "rules_mks"


def test_from_file():
    # Test loading from a valid file
    rules_mk = RulesMk.from_file(data_dir / "a.rules.mk")
    expected_targets = {'TRGs': [], 'DTAs': [], 'SQLs': [], 'BNDDs': [], 'PFs': [], 'LFs': [], 'DSPFs': [],
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
    expected_targets = {'TRGs': [], 'DTAs': [], 'SQLs': [], 'BNDDs': [], 'PFs': ['CRTSBSD.FILE'], 'LFs': [],
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
CRTSBSD.FILE : 
\t@$(call echo_cmd,=== Creating [CRTSBSD.FILE] from custom recipe)
\tsystem -i "CRTSBSD SBSD(BATCHWL/BATCHSBSD) POOLS((1 *SHRPOOL3 *N *MB))"
\t@$(call echo_success_cmd,End of creating CRTSBSD.FILE)
'''
    assert str(rules_mk) == '''PFs := CRTSBSD.FILE


CRTSBSD.FILE_CUSTOM_RECIPE=true
CRTSBSD.FILE : 
\t@$(call echo_cmd,=== Creating [CRTSBSD.FILE] from custom recipe)
\tsystem -i "CRTSBSD SBSD(BATCHWL/BATCHSBSD) POOLS((1 *SHRPOOL3 *N *MB))"
\t@$(call echo_success_cmd,End of creating CRTSBSD.FILE)
'''
