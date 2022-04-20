""" Constants """
from pathlib import Path

DEFAULT_TGT_CCSID = "*JOB"
DEFAULT_OBJLIB = "*CURLIB"
DEFAULT_CURLIB = "*CRTDFT"

BOB_PATH = Path(__file__).resolve().parent.parent

FILE_TARGET_MAPPING = {
    "PGM.SQLRPGLE": "PGM",
    "PGM.RPGLE": "PGM",
    "PGM.CLLE": "PGM",
    "PGM.C": "PGM",
    "CMDSRC": "CMD",
    "DSPF": "FILE",
    "LF": "FILE",
    "PF": "FILE",
    "PRTF": "FILE",
    "MENUSRC": "MENU",
    "C": "MODULE",
    "RPGLE": "MODULE",
    "CLLE": "MODULE",
    "SQLC": "MODULE",
    "SQLRPGLE": "MODULE",
    "MODULE": "PGM",
    "CBL": "PGM",
    "RPG": "PGM",
    "ILEPGM": "PGM",
    "PNLGRPSRC": "PNLGRP",
    "SQL": "QMQRY",
    "BND": "SRVPGM",
    "ILESRVPGM": "SRVPGM",
    "BNDDIR": "BNDD",
    "DTA": "DTA",
    "SYSTRG": "PGM",
    "SQLPRC": "PGM",
    "TABLE": "FILE",
    "VIEW": "FILE",
    "SQLSEQ": "DTAARA",
    "SQLUDF": "SRVPGM",
    "SQLTRG": "PGM",
    "MSGF": "MSGF",
    "WSCSTSRC": "WSCST",
}
# This is the maximum number of dot seperated parts in the file extensions defined above.
FILE_MAX_EXT_LENGTH = max(
    map(lambda ext: len(ext.split('.')), FILE_TARGET_MAPPING.keys()))
