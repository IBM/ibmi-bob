#!/QOpenSys/pkgs/bin/python3.6
# -*- coding: utf-8 -*-

from pathlib import Path
import re
from typing import Callable, Dict, List, Optional, Tuple
import sys
sys.path.append(str(Path(__file__).resolve().parent.parent))  # nopep8

from makei.const import FILE_TARGETGROUPS_MAPPING, TARGET_GROUPS
from makei.utils import decoposite_filename

class MKRule:
    """Class representing a make rule"""
    target: str
    dependencies: List[str]
    commands: List[str]
    variables: Dict[str, str]

    def __init__(self, target: str, dependencies: List[str], commands: List[str], variables: Dict[str, str]):
        self.target = target
        self.dependencies = dependencies
        self.commands = commands
        self.variables = variables

    def __str__(self):
        variable_assignment = ''.join(f"{self.target} : {key} = {value}\n" for key, value in self.variables.items())
        return f"{self.target} : {' '.join(self.dependencies)}" + '\n' + ''.join(['\t' + cmd + '\n' for cmd in self.commands]) + variable_assignment

    def __repr__(self):
        return str(self)

    @staticmethod
    def from_str(rule_str: str) -> "MKRule":
        r"""Creates a MKRule object from a string
        
        >>> rule_str = "target : dependency1 dependency2\n\tcommand1 param1 param2\n\tcommand2 param3 param4\n"
        >>> rule = MKRule.from_str(rule_str)
        >>> rule.target
        'target'
        >>> rule.dependencies
        ['dependency1', 'dependency2']
        >>> rule.commands
        ['command1 param1 param2', 'command2 param3 param4']
        >>> str(rule)
        'target : dependency1 dependency2\n\tcommand1 param1 param2\n\tcommand2 param3 param4\n'
        """
        rule_str = rule_str.strip()
        rule_regex = re.compile(r"^(?P<target>\S+)\s*:(?!=)\s*(?P<dependencies>\S+.*)(?P<cmds>(\n[^\S\r\n]+\S.*)*)$")
        target_match = rule_regex.match(rule_str)
        if target_match:
            target = target_match.group("target")
            dependencies = target_match.group("dependencies").split()
            commands = list(filter(lambda cmd: cmd, map(lambda cmd: cmd.strip(), target_match.group("cmds").split('\n'))))
        else:
            raise ValueError(f"Invalid rule string '{rule_str}'")
        
        return MKRule(target, dependencies, commands, {})

    def get_src_file(self) -> Optional[Tuple[str,str,str]]:
        # TODO: Note in the documentation that the src file is the first in the denpendencies list
        if len(self.dependencies) > 0:
            try:
                return decoposite_filename(self.dependencies[0])
            except ValueError:
                return None

class RulesMk:
    """A Class representing the rules.mk structure
    """
    subdirs: List[str]
    targets: Dict[str, List[str]]
    rules: List[MKRule]

    def __init__(self, subdirs: List[str], rules: List[MKRule]) -> None:
        self.targets = { tgt_group + 's': [] for tgt_group in TARGET_GROUPS }
        for rule in rules:
            if rule.get_src_file() is not None:
                tgt_group = FILE_TARGETGROUPS_MAPPING[rule.get_src_file()[-1]]
                self.targets[tgt_group + 's'].append(rule.target)
            else:
                print(f"Warning: Rule '{rule}' has no source file")
        self.subdirs = subdirs
        self.rules = rules
        
    # Read makefile and create a RulesMk object
    @staticmethod
    def from_file(rules_mk_path: Path) -> "RulesMk":
        with rules_mk_path.open("r") as f:
            rules_mk_str = f.read()
        rules_mk = RulesMk.from_str(rules_mk_str)
        return rules_mk

    @staticmethod
    def from_str(rules_mk_str: str) -> "RulesMk":
        """Creates a RulesMk object from a string
        
        >>> rules_mk_str = "subdir1 subdir2\n\n\ttarget1 target2\n\n\ttarget3 target4\n\n\ttarget5 target6\n"
        >>> rules_mk = RulesMk.from_str(rules_mk_str)
        >>> rules_mk.subdirs
        ['subdir1', 'subdir2']
        >>> rules_mk.targets
        {'all': ['target1', 'target2', 'target3', 'target4', 'target5', 'target6'], 'install': ['target1', 'target2', 'target3', 'target4', 'target5', 'target6']}
        """
        rules_mk_str = rules_mk_str.strip()

        rules = []
        variables = {}
        subdir = []

        recipe_env = False
        recipe_str = ""
        for line in rules_mk_str.split('\n'):
            if recipe_env:
                if re.match(r'\s', line):
                    recipe_str += line + '\n'
                    continue
                else:
                    rules.append(MKRule.from_str(recipe_str))
                    recipe_env = False
                    recipe_str = ""

            if line.startswith('#'):
                # Comment line
                continue
            if ":=" in line or ("=" in line and ":" not in line):
                # Variable assignment
                if line.strip().startswith('SUBDIRS'):
                    # Subdir definition
                    subdir = line.strip().split('=')[1].split()
                    continue
                else:
                    print(f"Skipped global variable {line}")
                    continue
            elif ':' in line:
                # Recipe declaration
                if '=' in line:
                    # private variable definition
                    target, variable = line.strip().split(':')
                    var_name, var_value = variable.split('=')
                    variables[target.strip()] = (var_name.strip(), var_value.strip())
                else:
                    # recipe
                    recipe_env = True
                    recipe_str = line + '\n'
                continue
            else:
                print(f"Skipped line {line}")
                continue
            
        if recipe_env:
            rules.append(MKRule.from_str(recipe_str))

        for target, variable in variables.items():
            matched_rules = filter(lambda rule: rule.target == target, rules)
            for rule in matched_rules:
                rule.variables[variable[0].strip()] = variable[1].strip()
        return RulesMk(subdir, rules)

    def __str__(self, rules_middleware: Callable[[MKRule], MKRule] = lambda rule: rule) -> str:
        """Returns a string representation of the RulesMk object
        """
        rules_str = ""
        if len(self.subdirs) > 0:
            rules_str += "SUBDIRS = " + " ".join(self.subdirs) + "\n\n"
        
        for target_group, targets in self.targets.items():
            if len(targets) > 0:
                rules_str += f"{target_group} := {' '.join(targets)}\n"
        rules_str += "\n\n"
        rules_str += ''.join(map(str, map(rules_middleware, self.rules)))
        return rules_str

if __name__ == "__main__":
    print(RulesMk.from_file(Path("/Users/tongkun/git/bob-recursive-example/QDDSSRC/Rules.mk")))
    # print(str(RulesMk.from_file(Path("/Users/tongkun/git/bob-recursive-example/functionsVAT/Rules.mk"))))
    # import doctest
    # doctest.testmod()