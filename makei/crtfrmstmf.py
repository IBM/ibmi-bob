#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import argparse
from pathlib import Path
from typing import Optional

from makei.ibm_job import IBMJob

COMMAND_MAP = {'CRTCMD': 'CMD',
               'CRTBNDCL': 'PGM',
               'CRTCLMOD': 'MODULE',
               'CRTDSPF': 'FILE',
               'CRTPRTF': 'FILE',
               'CRTLF': 'FILE',
               'CRTPF': 'FILE',
               'CRTMNU': 'MENU',
               'CRTPNLGRP': 'PNLGRP',
               'CRTQMQRY': 'QMQRY',
               'CRTSRVPGM': 'SRVPGM',
               'CRTWSCST': 'WSCST',
               'CRTRPGPGM': 'PGM',
               'CRTSQLRPG': 'PGM'}


class CrtFrmStmf():
    job: IBMJob
    srcstmf: str
    obj: str
    lib: str
    cmd: str
    parameters: Optional[str]
    ccsid_c: str

    def __init__(self, srcstmf: str, obj: str, lib: str, cmd: str, parameters: Optional[str] = None, tmp_lib="QTEMP", tmp_src="QSOURCE") -> None:
        self.job = IBMJob()
        self.srcstmf = srcstmf
        self.obj = obj
        self.lib = lib
        self.cmd = cmd
        self.parameters = parameters
        self.job.run_cl("CHGJOB LOG(4 00 * SECLVL)", True)
        self.tmp_lib = tmp_lib
        self.tmp_src = tmp_src
        ccsid = retreive_ccsid(srcstmf)
        if ccsid == "1208" or ccsid == "819":
            self.ccsid_c = '*JOB'
        else:
            self.ccsid_c = str(ccsid)

    def run(self):
        # Delete the temp source file
        self.job.run_cl(f'DLTF FILE({self.tmp_lib}/{self.tmp_src})', True)
        # Create the temp source file
        self.job.run_cl(
            f'CRTSRCPF FILE({self.tmp_lib}/{self.tmp_src}) RCDLEN(198) MBR({self.obj}) CCSID({self.ccsid_c})')
        # Copy the source stream file to the temp source file
        self.job.run_cl(
            f'CPYFRMSTMF FROMSTMF("{self.srcstmf}") TOMBR("/QSYS.LIB/{self.tmp_lib}.LIB/{self.tmp_src}.FILE/{self.obj}.MBR") MBROPT(*REPLACE)')

        obj_type = COMMAND_MAP[self.cmd]

        cmd = f"{self.cmd} {obj_type}({self.lib}/{self.obj}) SRCFILE({self.tmp_lib}/{self.tmp_src}) SRCMBR({self.obj})"
        if self.parameters is not None:
            cmd = cmd + ' ' + self.parameters
        self.job.run_cl(cmd)

        # Process the event file
        if "*EVENTF" in cmd or "*SRCDBG" in cmd or "*LSTDBG" in cmd:
            if self.lib == "*CURLIB":
                self.lib = self._retrieve_current_library()
            if self.lib == "*NONE":
                self.lib = "*QGPL"
            self._update_event_file('37')

    def _retrieve_current_library(self):
        records, _ = self.job.run_sql(
            "SELECT SYSTEM_SCHEMA_NAME AS LIBRARY FROM QSYS2.LIBRARY_LIST_INFO WHERE TYPE='CURRENT'")
        row = records[0]
        if row:
            return row[0]
        else:
            return "*NONE"

    def _update_event_file(self, ccsid):
        job = IBMJob()
        job.run_sql(
            f"CREATE OR REPLACE ALIAS {self.tmp_lib}.{self.obj} FOR {self.lib}.EVFEVENT ({self.obj});")
        results = job.run_sql(" ".join(["SELECT",
                                        f"CAST(EVFEVENT AS VARCHAR(300) CCSID {ccsid}) AS FULL",
                                        f"FROM {self.tmp_lib}.{self.obj}",
                                        f"WHERE Cast(evfevent As Varchar(300) Ccsid {ccsid}) LIKE 'FILEID%{self.tmp_lib}/{self.tmp_src}({self.obj})%'",
                                        ]))[0]

        parts = results[0][0].split()
        job.run_sql(" ".join([f"Update {self.tmp_lib}.{self.obj}",
                              "Set evfevent =",
                              "(",
                              f"SELECT Cast(evfevent As Varchar(24) Ccsid {ccsid}) CONCAT '{len(self.srcstmf):03} {self.srcstmf} {parts[-2]} {parts[-1]}'",
                              f"FROM {self.tmp_lib}.{self.obj}",
                              f"WHERE Cast(evfevent As Varchar(300) Ccsid {ccsid}) LIKE 'FILEID%{self.tmp_lib}/{self.tmp_src}({self.obj})%'",
                              "FETCH First 1 Row Only)",
                              f"WHERE Cast(evfevent As Varchar(300) Ccsid {ccsid}) LIKE 'FILEID%{self.tmp_lib}/{self.tmp_src}({self.obj})%'"]))

        job.run_sql(f"DROP ALIAS {self.tmp_lib}.{self.obj}")


def cli():
    """
    crtfrmstmf program cli entry
    """
    parser = argparse.ArgumentParser(prog='crtfrmstmf')

    parser.add_argument(
        "-f",
        '--stream-file',
        help='Specifies the path name of the stream file containing the source code to be compiled.',
        metavar='<srcstmf>',
        required=True
    )

    parser.add_argument(
        "-o",
        "--object",
        help='Enter the name of the object.',
        metavar='<object>',
        required=True
    )

    parser.add_argument(
        "-l",
        '--library',
        help='Enter the name of the library. If no library is specified, the created object is stored in the current library.',
        metavar='<library>',
        default="*CURLIB"
    )

    parser.add_argument(
        "-c",
        '--command',
        help='Specifies the compile command used to create the object.',
        metavar='<cmd>',
        required=True,
        choices=COMMAND_MAP.keys(),

    )

    parser.add_argument(
        "-p",
        '--parameters',
        help='Specifies the parameters added to the compile command.',
        metavar='<parms>',
        nargs='?'
    )

    parser.add_argument(
        "--save-joblog",
        help='Output the joblog to the specified json file.',
        metavar='{path to joblog json file}',
    )

    args = parser.parse_args()
    srcstmf_absolute_path = str(Path(args.stream_file.strip()).resolve())
    handle = CrtFrmStmf(srcstmf_absolute_path, args.object.strip(
    ), args.library.strip(), args.command.strip(), args.parameters)
    handle.run()

# Helper functions


def _get_attr(srcstmf: str):
    import os
    stream = os.popen(f'/QOpenSys/usr/bin/attr {srcstmf}')
    output = stream.read().strip()
    attrs = {}
    for attr in output.split("\n"):
        [key, value] = attr.split("=")
        attrs[key] = value
    return attrs


def retreive_ccsid(srcstmf: str) -> str:
    return _get_attr(srcstmf)["CCSID"]


if __name__ == "__main__":
    cli()
