#! /usr/bin/env python3

# Licensed Materials - Property of IBM
# 57XX-XXX
# (c) Copyright IBM Corp. 2021

from enum import Enum
import json
import os
import subprocess
import sys
from typing import List

from scripts.const import DEFAULT_CURLIB, DEFAULT_OBJLIB, FILE_MAX_EXT_LENGTH, FILE_TARGET_MAPPING


class Colors(str, Enum):
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'


def colored(message: str, color: Colors) -> str:
    """Returns a colored message if supported
    """
    if support_color():
        return f"{color}{message}{Colors.ENDC}"
    else:
        return f"{message}"


def support_color():
    return True


def read_ibmi_json(path, parent_value):
    if path.exists():
        with path.open() as f:
            data = json.load(f)
            try:
                objlib = parse_all_variables(data['build']['objlib'])

            except Exception:
                objlib = parent_value[0]
            try:
                tgtCcsid = data['build']['tgtCcsid']
            except Exception:
                tgtCcsid = parent_value[1]
            return (objlib, tgtCcsid)
    else:
        return parent_value


def parse_variable(varName):
    """ Returns the value of the given variable name in the system environment,
        or the input value itself if it is not a variable name.

    >>> os.environ["key1"] = "value1"
    >>> parse_variable("key1")
    'key1'
    >>> parse_variable("&key1")
    'value1'
    >>> parse_variable("&key1")
    'value1'
    """
    if varName.startswith("&") and len(varName) > 1:
        varName = varName[1:]
        try:
            value = os.environ[varName]
            return value
        except Exception:
            print(colored(
                f"{varName} must be defined first in the environment variable.", Colors.FAIL))
            exit(1)
    else:
        return varName


def parse_all_variables(input: str) -> str:
    """ Resolve and return the input string with all variables being replaced

    >>> os.environ["key1"] = "value1"
    >>> os.environ["key2"] = "value2"
    >>> os.environ["key3"] = "value3"
    >>> os.environ["dependency_dir"] = "dep_dir_value"
    >>> parse_all_variables("key1")
    'key1'
    >>> parse_all_variables("key1/key2")
    'key1/key2'
    >>> parse_all_variables("&key1")
    'value1'
    >>> parse_all_variables("&key1/key2")
    'value1/key2'
    >>> parse_all_variables("key1/&key2")
    'key1/value2'
    >>> parse_all_variables("key1/")
    'key1/'
    >>> parse_all_variables("/key1/")
    '/key1/'
    >>> parse_all_variables("/&key1/")
    '/value1/'
    >>> parse_all_variables("/&key1///&key2/&key3")
    '/value1///value2/value3'
    >>> parse_all_variables("&dependency_dir/includes")
    'dep_dir_value/includes'
    """
    parts = input.split("/")
    result = ""
    for part in parts:
        result = result + parse_variable(part) + "/"
    result = result[:-1]
    return result


def read_iproj_json(iproj_json_path):
    """ Returns a dictionary representing the iproj.json file content
    If `objlib` or `curlib` is not defined, the default value for those
    will be used.
    """
    try:
        with iproj_json_path.open() as f:
            iproj_json = json.load(f)
            objlib = parse_all_variables(
                iproj_json["objlib"]) if "objlib" in iproj_json else DEFAULT_OBJLIB
            curlib = parse_all_variables(
                iproj_json["curlib"]) if "curlib" in iproj_json else DEFAULT_CURLIB
            if objlib == "*CURLIB":
                if curlib == "*CRTDFT":
                    objlib = "QGPL"
                else:
                    objlib = curlib
            iproj_json["preUsrlibl"] = " ".join(
                map(lambda lib: parse_all_variables(lib), iproj_json["preUsrlibl"]))
            iproj_json["postUsrlibl"] = " ".join(
                map(lambda lib: parse_all_variables(lib), iproj_json["postUsrlibl"]))
            iproj_json["includePath"] = " ".join(
                map(lambda path: parse_all_variables(path), iproj_json["includePath"]))
            iproj_json["objlib"] = objlib
            iproj_json["curlib"] = curlib
            iproj_json["tgtCcsid"] = iproj_json["tgtCcsid"] if "tgtCcsid" in iproj_json else "*JOB"
            return iproj_json
    except FileNotFoundError:
        print(colored("iproj.json not found!", Colors.FAIL))
        exit(1)


def objlib_to_path(objlib):
    """Returns the path for the given objlib in IFS

    >>> objlib_to_path("TONGKUN")
    '/QSYS.LIB/TONGKUN.LIB'
    """
    if not objlib:
        raise ValueError()
    return f"/QSYS.LIB/{objlib}.LIB"


def run_command(cmd: str):
    print(colored(f"> {cmd}", Colors.OKGREEN))
    sys.stdout.flush()
    try:
        process = subprocess.Popen(
            ["bash", "-c", cmd], stdout=subprocess.PIPE, )
        for c in iter(lambda: process.stdout.readline(), b''):
            sys.stdout.buffer.write(c)
            sys.stdout.flush()
    except FileNotFoundError as e:
        print(colored(f'Cannot find command {e.filename}!', Colors.FAIL))


def get_compile_targets_from_filenames(filenames: List[str]) -> List[str]:
    """ Returns the possible target name for the given filename

    >>> get_compile_targets_from_filenames(["test.PGM.RPGLE"])
    ['test.PGM']
    >>> get_compile_targets_from_filenames(["test.RPGLE"])
    ['test.MODULE']
    >>> get_compile_targets_from_filenames(["functionsVAT/VAT300.RPGLE", "test.RPGLE"])
    ['VAT300.MODULE', 'test.MODULE']
    """
    result = []
    for filename in filenames:
        parts = os.path.basename(filename).split(".")

        ext_len = FILE_MAX_EXT_LENGTH
        while ext_len > 0:
            base, ext = '.'.join(
                parts[:-ext_len]), '.'.join(parts[-ext_len:]).upper()
            if ext in FILE_TARGET_MAPPING.keys():
                result.append(f'{base}.{FILE_TARGET_MAPPING[ext]}')
                break
            ext_len -= 1
    return result


if __name__ == "__main__":
    import doctest
    doctest.testmod()
