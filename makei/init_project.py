#!/QOpenSys/pkgs/bin/python3.6

# Licensed Materials - Property of IBM
# 57XX-XXX
# (c) Copyright IBM Corp. 2021

"""This module is """

import json
from pathlib import Path
import re
import signal
import sys
from typing import List, Optional

from makei.const import DEFAULT_CURLIB, DEFAULT_TGT_CCSID, DEFAULT_OBJLIB
from makei.utils import colored, Colors


class ProjSpec():
    """ Class containing information about a project. """

    description: str
    version: str
    include_path: List[str]
    repository: Optional[str]
    objlib: str
    curlib: str
    pre_usr_libl: List[str]
    post_usr_libl: List[str]
    license: Optional[str]
    set_ibm_i_env_cmd: Optional[str]
    tgt_ccsid: str

    def __init__(self):
        # try:
        self.description = prompt(
            'descriptive application name', Path.cwd().name)
        self.version = "1.0.0"
        self.repository = prompt('git repository', self._get_repository())
        self.include_path = self._input_str_to_list(
            prompt('include path, separated by commas', ""))
        self.objlib = prompt(
            'What library should objects be compiled into (objlib)', DEFAULT_OBJLIB)
        self.tgt_ccsid = prompt(
            'What EBCDIC CCSID should the source be compiled in', DEFAULT_TGT_CCSID)
        self.curlib = prompt('curlib', DEFAULT_CURLIB)
        self.pre_usr_libl = self._input_str_to_list(
            prompt('Pre user libraries, separated by commas', ""))
        self.post_usr_libl = self._input_str_to_list(
            prompt('Post user libraries, separated by commas', ""))
        self.set_ibm_i_env_cmd = self._input_str_to_list(prompt(
            'Set up commands to be executed, separated by commas', ""))
        self.license = prompt('license', "")
        # except Exception:
        #     print(colored("\nInvalid input", Colors.FAIL))
        #     _init_cancelled()

    def _get_repository(self) -> str:
        try:
            with (Path.cwd() / '.git' / 'config').open() as file:
                gconf = file.read().splitlines()
                i = gconf.index('[remote "origin"]')
                line = gconf[i + 1]
                if not re.match(r"^\s*url =", line):
                    line = gconf[i + 2]
                if not re.match(r"^\s*url =", line):
                    line = None
                else:
                    line = re.sub(r"^\s*url = ", '', line)
                if line is not None and re.match(r"^git@github.com:", line):
                    line = re.sub(r"^git@github.com:",
                                  'https://github.com/', line)
                return line
        except Exception:
            return ""

    def _input_str_to_list(self, input_str: str) -> List[str]:
        return list(filter(len, map(lambda s: s.strip(), input_str.split(","))))

    def generate_iproj_json(self) -> str:
        """ Returns a string representation of the iproj.json file of current project"""

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
            "setIBMiEnvCmd": self.set_ibm_i_env_cmd
        }
        return json.dumps(iproj, indent=4)

    def generate_ibmi_json(self) -> Optional[str]:
        """ Returns a string representation of the .ibmi.json file of current project"""

        build = {}
        # if self.objlib != DEFAULT_OBJLIB:
        #     build["objlib"] = self.objlib

        if self.tgt_ccsid != DEFAULT_TGT_CCSID:
            build["tgtCcsid"] = self.tgt_ccsid

        if len(build.keys()) > 0:
            ibmi = {
                "version": self.version,
                "build": build
            }
            return json.dumps(ibmi, indent=4)
        else:
            return None

    def generate_rules_mk(self) -> str:
        """ Generates a Rules.mk template"""
        return '\n'.join(['# Check out the documentation on creating the rules at' +
                          'https://github.com/IBM/ibmi-bob/wiki/Create-Rules.mk',
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


def _signal_handler(_sig, _frame):
    _init_cancelled()


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


def _init_cancelled():
    print(colored('\nInit cancelled!', Colors.WARNING))
    sys.exit(0)


def prompt(description, default_value) -> str:
    """ Prompt with description for user input, a default value can be provided"""
    prompt_text = f'{description}:'
    if default_value:
        prompt_text += f' ({default_value})'
    input_str = input(f'{prompt_text} ')
    if not input_str:
        input_str = default_value
    return input_str


def create_file(file_path: Path, content: Optional[str], force: bool = False) -> None:
    """ Create a new file with the given content,

    Args:
        file_path (Path): Path to the file to be created
        content (Optional[str]): the content of the file
        force (bool, optional): Force overwrite of existing file; Defaults to False.
    """
    if content is None:
        return
    if not force and file_path.exists():
        if not yes(prompt(colored(f'* {file_path} already exists, overwrite?',
                                  Colors.WARNING), 'no')):
            return
    with file_path.open('w') as file:
        file.write(content)


def init_project(force: bool = False) -> None:
    """ A CLI utility to create a project"""
    signal.signal(signal.SIGINT, _signal_handler)

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

    iproj_json_content = proj_spec.generate_iproj_json()
    ibmi_json_content = proj_spec.generate_ibmi_json()
    rules_mk_content = proj_spec.generate_rules_mk()

    print('\n'.join(['',
                     "The following files will be added to the project"] + list(filter(None, [
                         f"+ {iproj_json_path}" if iproj_json_content else None,
                         f"+ {ibmi_json_path}" if ibmi_json_content else None,
                         f"+ {rules_mk_path}" if rules_mk_content else None,
                     ]))))
    if force or yes(input('Continue? (yes) ')):
        create_file(iproj_json_path, proj_spec.generate_iproj_json(), force)
        create_file(ibmi_json_path, proj_spec.generate_ibmi_json(), force)
        create_file(rules_mk_path, proj_spec.generate_rules_mk(), force)
    else:
        _init_cancelled()


if __name__ == "__main__":
    import doctest
    doctest.testmod()
