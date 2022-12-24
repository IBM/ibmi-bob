#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re
from pathlib import Path
from typing import Callable, Dict, List, Optional

from makei.const import FILE_TARGETGROUPS_MAPPING, TARGET_GROUPS, TARGET_TARGETGROUPS_MAPPING
from makei.utils import decompose_filename, is_source_file


class MKRule:
    """Class representing a make rule"""
    target: str
    dependencies: List[str]
    commands: List[str]
    variables: Dict[str, str]
    containing_dir: Path
    include_dirs: List[Path]

    source_file: Optional[str] = None

    def __init__(self, target: str, dependencies: List[str], commands: List[str], variables: Dict[str, str],
                 containing_dir: Path, include_dirs: List[Path]):
        self.target = target
        self.dependencies = dependencies
        self.commands = list(filter(lambda command: command.strip(), commands))
        self.variables = variables
        self.containing_dir = containing_dir
        self.include_dirs = include_dirs

        if len(self.commands) == 0:
            for dependency in self.dependencies:
                if is_source_file(dependency) and decompose_filename(dependency)[-1] == "":
                    if (self.containing_dir / dependency).exists():
                        self.source_file = '$(d)/' + dependency
                        self.dependencies.remove(dependency)
                        return
            try:
                self.source_file = self.dependencies[0]
                self.dependencies.remove(self.source_file)
            except IndexError:
                print(f"No source file found for {self.target} in {self.dependencies}")
        else:
            self.commands.insert(0, f"@$(call echo_cmd,=== Creating [{self.target}] from custom recipe)")
            self.commands.append(f"@$(call echo_success_cmd,End of creating {self.target})")

    def __str__(self):
        variable_assignment = ''.join(f"{self.target} : {key} = {value}\n" for key, value in self.variables.items())
        if len(self.commands) > 0:
            return f"{self.target}_CUSTOM_RECIPE=true" + '\n' + f"{self.target} : {' '.join(self._parse_dependencies())}" + '\n' + ''.join(
                ['\t' + cmd + '\n' for cmd in self.commands]) + variable_assignment
        else:
            try:
                target_type = self.target.split(".")[-1].upper()
                if target_type == "SQL" or target_type == "MSGF":
                    recipe_name = f"{target_type}_RECIPE"
                else:
                    recipe_name = decompose_filename(self.source_file)[2].upper() + '_TO_' + self.target.split(".")[
                        -1].upper() + '_RECIPE'
                return f"{self.target}_SRC={self.source_file}" + '\n' + f"{self.target}_DEP={' '.join(self.dependencies)}" + '\n' + f"{self.target}_RECIPE={recipe_name}" + '\n' + variable_assignment
            except AttributeError:
                print(f"No source file found for {self.target}")
                exit(1)

    def __repr__(self):
        return str(self)

    def _parse_dependencies(self) -> List[str]:
        """Parses the dependencies of a rule"""
        result = []
        for dependency in self.dependencies:
            if is_source_file(dependency) and decompose_filename(dependency)[-1] == "":
                if (self.containing_dir / dependency).exists():
                    result.append('$(d)/' + dependency)
                else:
                    for include_dir in self.include_dirs:
                        if (include_dir / dependency).exists():
                            result.append(str(include_dir / dependency))
                            break
                    result.append(dependency)
            else:
                result.append(dependency)
        return result

    @staticmethod
    def from_str(rule_str: str, containing_dir: Path, include_dirs: List[Path]) -> "MKRule":
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
            commands = list(
                filter(lambda cmd: cmd, map(lambda cmd: cmd.strip(), target_match.group("cmds").split('\n'))))
        else:
            raise ValueError(f"Invalid rule string '{rule_str}'")

        return MKRule(target, dependencies, commands, {}, containing_dir, include_dirs)


class RulesMk:
    """A Class representing the rules.mk structure
    """
    containing_dir: Path
    subdirs: List[str]
    targets: Dict[str, List[str]]
    rules: List[MKRule]
    build_context: Optional["BuildEnv"] = None

    def __init__(self, subdirs: List[str], rules: List[MKRule], containing_dir: Path) -> None:
        self.targets = {tgt_group + 's': [] for tgt_group in TARGET_GROUPS}
        for rule in rules:
            if rule.source_file is not None:
                tgt_group = FILE_TARGETGROUPS_MAPPING[decompose_filename(rule.source_file)[-2]]
                self.targets[tgt_group + 's'].append(rule.target)
            else:
                try:
                    tgt_group = TARGET_TARGETGROUPS_MAPPING[rule.target.split('.')[-1]]
                except KeyError:
                    print(f"Warning: Target '{rule.target}' is not supported")
                    exit(1)

                self.targets[tgt_group + 's'].append(rule.target)

        self.subdirs = subdirs
        self.rules = rules
        self.containing_dir = containing_dir

    # Read makefile and create a RulesMk object
    @classmethod
    def from_file(cls, rules_mk_path: Path, include_dirs: List[Path] = []) -> "RulesMk":
        with rules_mk_path.open("r") as f:
            rules_mk_str = f.read()
        rules_mk = RulesMk.from_str(rules_mk_str, rules_mk_path.parent, include_dirs)
        return rules_mk

    @classmethod
    def from_str(cls, rules_mk_str: str, containing_dir: Path, include_dirs: List[Path] = []) -> "RulesMk":
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
                    rules.append(MKRule.from_str(recipe_str, containing_dir, include_dirs))
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
                    # print(f"Skipped global variable {line}")
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
                # print(f"Skipped line {line}")
                continue

        if recipe_env:
            rules.append(MKRule.from_str(recipe_str, containing_dir, include_dirs))

        for target, variable in variables.items():
            matched_rules = filter(lambda rule: rule.target == target, rules)
            for rule in matched_rules:
                rule.variables[variable[0].strip()] = variable[1].strip()
        return RulesMk(subdir, rules, containing_dir)

    def __str__(self, rules_middleware: Callable[[MKRule], MKRule] = lambda rule: rule) -> str:
        """Returns a string representation of the RulesMk object
        """
        rules_str = ""
        if len(self.subdirs) > 0:
            rules_str += "SUBDIRS := " + " ".join(self.subdirs) + "\n\n"

        for target_group, targets in self.targets.items():
            if len(targets) > 0:
                rules_str += f"{target_group} := {' '.join(targets)}\n"
        rules_str += "\n\n"
        rules_str += ''.join(map(str, map(rules_middleware, self.rules)))
        return rules_str


if __name__ == "__main__":
    # print(RulesMk.from_file(Path("/Users/tongkun/git/bob-recursive-example/QDDSSRC/Rules.mk")))
    # print(str(RulesMk.from_file(Path("/Users/tongkun/git/bob-recursive-example/functionsVAT/Rules.mk"))))
    import doctest

    doctest.testmod()
