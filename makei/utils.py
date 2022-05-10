#!/QOpenSys/pkgs/bin/python3.6

# Licensed Materials - Property of IBM
# 57XX-XXX
# (c) Copyright IBM Corp. 2021

""" The utility module"""

from datetime import datetime
from enum import Enum
from tempfile import mkstemp
import json
import os
from pathlib import Path
from shutil import move, copymode
import subprocess
import sys
from typing import Callable, Dict, List, Tuple, Union

from makei.const import DEFAULT_CURLIB, DEFAULT_OBJLIB, FILE_MAX_EXT_LENGTH, FILE_TARGET_MAPPING


class Colors(str, Enum):
    """ An enum of colors to be used for output"""
    BOLD = '\033[1m'
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
    """ Detects if the terminal supports color."""
    return sys.stdout.isatty()


def read_ibmi_json(path: Path, parent_value: Tuple[str, str]) -> Tuple[str, str]:
    """Read and return the value defined in the given .ibmi.json

    Args:
        path (Path): path to the ibmi.json
        parent_value (Tuple[str, str]): (objlib, tgtCcsid) as defined the the parent directory

    Returns:
        Tuple[str, str]: (objlib, tgtCcsid)
    """
    if path.exists():
        with path.open() as file:
            data = json.load(file)
            try:
                objlib = parse_all_variables(data['build']['objlib'])
            except KeyError:
                objlib = parent_value[0]
            try:
                tgt_ccsid = data['build']['tgtCcsid']
            except KeyError:
                tgt_ccsid = parent_value[1]
            return (objlib, tgt_ccsid)
    else:
        return parent_value


def parse_variable(var_name: str):
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
    if var_name.startswith("&") and len(var_name) > 1:
        var_name = var_name[1:]
        try:
            value = os.environ[var_name]
            return value
        except KeyError:
            print(colored(
                f"{var_name} must be defined first in the environment variable.", Colors.FAIL))
            sys.exit(1)
    else:
        return var_name


def parse_all_variables(input_str: str) -> str:
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
    parts = input_str.split("/")
    result = ""
    for part in parts:
        result = result + parse_variable(part) + "/"
    result = result[:-1]
    return result


def read_iproj_json(iproj_json_path: Path) -> Dict:
    """ Returns a dictionary representing the iproj.json file content
    If `objlib` or `curlib` is not defined, the default value for those
    will be used.
    """
    def with_default_value(key, default_value, dict):
        if key in dict:
            return dict[key]
        else:
            return default_value

    try:
        with iproj_json_path.open() as file:
            iproj_json = json.load(file)
            objlib = parse_all_variables(with_default_value(
                "objlib", DEFAULT_OBJLIB, iproj_json))
            curlib = parse_all_variables(with_default_value(
                "curlib", DEFAULT_CURLIB, iproj_json))
            if objlib == "*CURLIB":
                if curlib == "*CRTDFT":
                    objlib = "QGPL"
                else:
                    objlib = curlib

            iproj_json["preUsrlibl"] = " ".join(
                map(parse_all_variables, with_default_value("preUsrlibl", [], iproj_json)))

            iproj_json["postUsrlibl"] = " ".join(
                map(parse_all_variables, with_default_value("postUsrlibl", [], iproj_json)))
            iproj_json["includePath"] = " ".join(
                map(parse_all_variables, with_default_value("includePath",[], iproj_json)))
            iproj_json["objlib"] = objlib
            iproj_json["curlib"] = curlib
            iproj_json["tgtCcsid"] = with_default_value(
                "tgtCcsid", "*JOB", iproj_json)
            return iproj_json
    except FileNotFoundError:
        print(colored("iproj.json not found!", Colors.FAIL))
        sys.exit(1)


def objlib_to_path(lib, object=None) -> str:
    """Returns the path for the given objlib in IFS

    >>> objlib_to_path("TONGKUN")
    '/QSYS.LIB/TONGKUN.LIB'
    >>> objlib_to_path("TONGKUN", "SAMREF.FILE")
    '/QSYS.LIB/TONGKUN.LIB/SAMREF.FILE'
    """
    if not lib:
        raise ValueError()
    if object is not None:
        return f"/QSYS.LIB/{lib}.LIB/{object}"
    else:
        return f"/QSYS.LIB/{lib}.LIB"


def print_to_stdout(line: Union[str, bytes]):
    """Default stdoutHandler for run_command defined below to write the bytes to the stdout
    """
    if type(line) == str:
        line = line.encode(sys.getdefaultencoding())
    sys.stdout.buffer.write(line)
    sys.stdout.buffer.flush()

def run_command(cmd: str, stdoutHandler: Callable[[bytes], None]=print_to_stdout) -> int:
    """ Run a command in a shell environment and redirect its stdout and stderr
        and returns the exit code

    Args:
        cmd (str): The command to run
        stdoutHandler (Callable[[bytes], None]]): the handle function to process the stdout
    """
    print(colored(f"> {cmd}", Colors.OKGREEN))
    sys.stdout.flush()
    try:
        process = subprocess.Popen(
            ["bash", "-c", cmd], stdout=subprocess.PIPE, )
        for line in iter(process.stdout.readline, b''):
            stdoutHandler(line)
        return process.wait()
    except FileNotFoundError as error:
        print(colored(f'Cannot find command {error.filename}!', Colors.FAIL))
    finally:
        process.kill()


def get_compile_targets_from_filenames(filenames: List[str]) -> List[str]:
    """ Returns the possible target name for the given filename

    >>> get_compile_targets_from_filenames(["test.PGM.RPGLE"])
    ['test.PGM']
    >>> get_compile_targets_from_filenames(["test.RPGLE"])
    ['test.MODULE']
    >>> get_compile_targets_from_filenames(["functionsVAT/VAT300.RPGLE", "test.RPGLE"])
    ['VAT300.MODULE', 'test.MODULE']
    >>> get_compile_targets_from_filenames(["ART200-Work_with_article.PGM.SQLRPGLE", "SGSMSGF.MSGF"])
    ['ART200.PGM', 'SGSMSGF.MSGF']
    """
    result = []
    for filename in filenames:
        parts = os.path.basename(filename).split(".")

        ext_len = FILE_MAX_EXT_LENGTH
        while ext_len > 0:
            base, ext = '.'.join(
                parts[:-ext_len]), '.'.join(parts[-ext_len:]).upper()
            if ext in FILE_TARGET_MAPPING:
                # Split the object name and text attributes
                object_name = base.split("-")[0]
                result.append(f'{object_name}.{FILE_TARGET_MAPPING[ext]}')
                break
            ext_len -= 1
        if ext_len == 0:
            raise ValueError(f"Cannot get the target for {filename}")
    return result


def format_datetime(d: datetime) -> str:
    # 2022-03-25-09.33.34.064676
    return d.strftime("%Y-%m-%d-%H.%M.%S.%f")

def replace_file_content(file_path: Path, replace: Callable[[str], str]):
    #Create temp file
    fh, abs_path = mkstemp()
    with os.fdopen(fh,'w') as new_file:
        with open(file_path) as old_file:
            for line in old_file:
                new_file.write(replace(line))
    #Copy the file permissions from the old file to the new file
    copymode(file_path, abs_path)
    #Remove original file
    os.remove(file_path)
    #Move new file
    move(abs_path, file_path)


if __name__ == "__main__":
    import doctest
    doctest.testmod()
