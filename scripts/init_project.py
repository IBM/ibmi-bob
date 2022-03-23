#! /usr/bin/env python3

# Licensed Materials - Property of IBM
# 57XX-XXX
# (c) Copyright IBM Corp. 2021

import json
import signal
import sys
from scripts.utils import colored, Colors
from typing import List, Optional
from pathlib import Path
import re


class ProjSpec():
    description: str
    version: str
    include_path: List[str]
    repository: Optional[str]
    objlib: str
    curlib: str
    pre_usr_libl: List[str]
    post_usr_libl: List[str]
    license: Optional[str]
    set_IBM_i_env_cmd: Optional[str]
    tgt_ccsid: str

    def __init__(self):
        try:
            self.description = prompt(
                f'descriptive application name', Path.cwd().name)
            self.version = "1.0.0"
            self.repository = prompt(f'git repository', self._get_repository())
            self.include_path = self._input_str_to_list(
                prompt(f'include path, separated by commas', ""))
            self.objlib = prompt(
                f'What library should objects be compiled into (objlib)', "*CURLIB")
            self.tgt_ccsid = prompt(
                f'What EBCDIC CCSID should the source be compiled in', "*JOB")
            self.curlib = prompt(f'curlib', "")
            self.pre_usr_libl = self._input_str_to_list(
                prompt(f'Pre user libraries, separated by commas', ""))
            self.post_usr_libl = self._input_str_to_list(
                prompt(f'Post user libraries, separated by commas', ""))
            self.set_IBM_i_env_cmd = self._input_str_to_list(prompt(
                f'Set up commands to be executed, separated by commas', ""))
            self.license = prompt(f'license', "")

        except Exception:
            print(colored("\nInvalid input", Colors.FAIL))
            init_cancelled()

    def _get_repository(self) -> str:
        try:
            with (Path.cwd() / '.git' / 'config').open() as f:
                gconf = f.read().splitlines()
                i = gconf.index('[remote "origin"]')
                u = gconf[i + 1]
                if not re.match(r"^\s*url =", u):
                    u = gconf[i + 2]
                if not re.match(r"^\s*url =", u):
                    u = None
                else:
                    u = re.sub(r"^\s*url = ", '', u)
                if u != None and re.match(r"^git@github.com:", u):
                    u = re.sub(r"^git@github.com:", 'https://github.com/', u)
                return u
        except Exception as e:
            return ""

    def _input_str_to_list(self, input_str: str) -> List[str]:
        return list(map(lambda s: s.strip(), input_str.split(",")))

    def generate_iproj_json(self) -> str:
        iproj = {
            "description": self.description,
            "version": self.version,
            "license": self.license,
            "repository": self.repository,
            "includePath": self.include_path,
            "objlib": self.objlib,
            "curlib": self.curlib,
            "preUsrLibl": self.pre_usr_libl,
            "postUsrLibl": self.post_usr_libl,
            "setIBMiEnvCmd": self.set_IBM_i_env_cmd
        }
        return json.dumps(iproj, indent=4)

    def generate_ibmi_json(self) -> str:
        ibmi = {
            "version": self.version,
            "build": {
                "objlib": self.objlib,
                "tgtCcsid": self.tgt_ccsid
            }
        }
        return json.dumps(ibmi, indent=4)

    def generate_rules_mk(self) -> str:
        return '\n'.join(['# Check out the documentation on creating the rules at https://github.com/IBM/ibmi-bob/wiki/Create-Rules.mk',
                          "SUBDIRS :=",
                          "",
                          "TRGs :=",
                          "DTAs :=",
                          "SQLs :=",
                          "BNDDs :=",
                          "PFs :=",
                          "LFs :=",
                          "DSPFs :=",
                          "PRTFs :=",
                          "CMDs :=",
                          "SQLs :=",
                          "MODULEs :=",
                          "SRVPGMs :=",
                          "PGMs :=",
                          "MENUs :=",
                          "PNLGRPs :=",
                          "QMQRYs :=",
                          "WSCSTs :=",
                          "MSGs :=",
                          ])


def signal_handler(sig, frame):
    init_cancelled()


def yes(input_str: str):
    """
    >>> yes("yes")
    True
    >>> yes("y")
    True
    >>> yes("Yes")
    True
    >>> yes("No")
    False
    """
    return input_str.strip().lower() == "yes" or \
        input_str.strip().lower() == "y" or \
        input_str.strip() == ""


def init_cancelled():
    print(colored('\nInit cancelled!', Colors.WARNING))
    sys.exit(0)


def prompt(description, default_vaule) -> str:
    prompt_text = f'{description}:'
    if default_vaule:
        prompt_text += f' ({default_vaule})'
    input_str = input(f'{prompt_text} ')
    if not input_str:
        input_str = default_vaule
    return input_str


def create_file(file_path: Path, content: str, force: bool = False) -> None:
    if not force and file_path.exists():
        if not yes(prompt(colored(f'* {file_path} already exists, overwrite?', Colors.WARNING), 'no')):
            return
    with file_path.open('w') as f:
        f.write(content)


def init_project(force: bool = False) -> None:
    signal.signal(signal.SIGINT, signal_handler)

    print('\n'.join([
        'This utility will walk you through creating a project.',
        'It only covers some common items.',
        '',
        'Press ^C at any time to quit.',
    ]))

    proj_spec = ProjSpec()

    iproj_json_path = Path.cwd() / 'iproj.json'
    ibmi_json_path = Path.cwd() / '.ibmi.json'
    rules_mk_path = Path.cwd() / 'Rules.mk'

    print('\n'.join(['',
                     "The following files will be added to the project",
                     f"+ {iproj_json_path}",
                     f"+ {ibmi_json_path}",
                     f"+ {rules_mk_path}",
                     ]))
    if force or yes(input('Continue? (yes) ')):
        create_file(iproj_json_path, proj_spec.generate_iproj_json(), force)
        create_file(ibmi_json_path, proj_spec.generate_ibmi_json(), force)
        create_file(rules_mk_path, proj_spec.generate_rules_mk(), force)
    else:
        init_cancelled()


if __name__ == "__main__":
    import doctest
    doctest.testmod()
