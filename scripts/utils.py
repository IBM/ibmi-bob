#! /usr/bin/env python3

from enum import Enum

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
    return f"{color}{message}{Colors.ENDC}"
