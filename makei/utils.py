#!/QOpenSys/pkgs/bin/python3.6

# Licensed Materials - Property of IBM
# 57XX-XXX
# (c) Copyright IBM Corp. 2021

""" The utility module"""

from datetime import datetime
from enum import Enum
from tempfile import mkstemp
import os
from pathlib import Path
from shutil import move, copymode
import subprocess
import sys
from typing import Callable, List, Optional, Tuple, Union

from makei.const import FILE_MAX_EXT_LENGTH, FILE_TARGET_MAPPING


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

def decompose_filename(filename: str) -> Tuple[str, Optional[str], str, str]:
    """Returns the (name, text-attribute, extension, dirname) of the file name
    >>> decompose_filename("SAMREF.PF")
    ('SAMREF', None, 'PF', '')
    >>> decompose_filename("/SAMREF.PF")
    ('SAMREF', None, 'PF', '/')
    >>> decompose_filename("SAMREF-TEXT.PF")
    ('SAMREF', 'TEXT', 'PF', '')
    >>> decompose_filename("test-Text.PGM.RPGLE")
    ('test', 'Text', 'PGM.RPGLE', '')
    >>> decompose_filename("../dir1/dir2/test-Text.PGM.RPGLE")
    ('test', 'Text', 'PGM.RPGLE', '../dir1/dir2')
    """
    if not filename:
        raise ValueError()

    parts = os.path.basename(filename).split(".")

    ext_len = FILE_MAX_EXT_LENGTH
    while ext_len > 0:
        base, ext = '.'.join(parts[:-ext_len]), '.'.join(parts[-ext_len:]).upper()
        if ext in FILE_TARGET_MAPPING:
            # Split the object name and text attributes
            if len(base.split("-")) == 2:
                name, text_attribute = base.split("-")
            else:
                name = base
                text_attribute = None
            return name, text_attribute, ext, os.path.dirname(filename)
        ext_len -= 1
    if ext_len == 0:
        raise ValueError(f"Cannot decomposite filename: {filename}")

def is_source_file(filename: str) -> bool:
    """Returns true if the file is a source file
    >>> is_source_file("SAMREF.PF")
    True
    >>> is_source_file("SAMREF-TEXT.PF")
    True
    >>> is_source_file("test-Text.PGM.RPGLE")
    True
    >>> is_source_file("../dir1/dir2/test-Text.PGM.RPGLE")
    True
    >>> is_source_file("Test.PGM.RPGLE")
    True
    >>> is_source_file("Test.PGM")
    False
    """
    try:
        _, _, ext, _ = decompose_filename(filename)
        return ext in FILE_TARGET_MAPPING
    except ValueError:
        return False

def get_target_from_filename(filename: str) -> str:
    """Returns the target from the filename
    """
    name, _, ext, _ = decompose_filename(filename)
    return f'{name}.{FILE_TARGET_MAPPING[ext]}'

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
        result.append(get_target_from_filename(filename))
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
