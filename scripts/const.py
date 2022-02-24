from pathlib import Path


BOB_PATH = Path('/QOpenSys/pkgs/lib/bob/')
GET_BOB_MK = lambda : BOB_PATH / 'mk'
GET_BOB_MAKEFILE = lambda : BOB_PATH / 'Makefile'


FILE_TARGET_MAPPING = {
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
    "SQLTRG": "SQL",
    "MSGF": "MSG",
    "WSCSTSRC": "WSCST",
}
# This is the maximum number of dot seperated parts in the file extensions defined above.
FILE_MAX_EXT_LENGTH = max(map(lambda ext: len(ext.split('.')), FILE_TARGET_MAPPING.keys()))