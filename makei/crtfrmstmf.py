#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import argparse
import os
from pathlib import Path
import sys
from typing import Any, Dict, Optional
from datetime import datetime
sys.path.append(str(Path(__file__).resolve().parent.parent))  # nopep8
from makei.ibm_job import IBMJob, save_joblog_json  # nopep8
from makei.utils import format_datetime, objlib_to_path  # nopep8


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
    env_settings: Dict[str, str]
    ccsid_c: str
    joblog_path: Optional[str]

    def __init__(self, srcstmf: str, obj: str, lib: str, cmd: str, parameters: Optional[str] = None, env_settings: Optional[Dict[str, str]] = None, joblog_path: Optional[str] = None, tmp_lib="QTEMP", tmp_src="QSOURCE") -> None:
        self.job = IBMJob()
        self.srcstmf = srcstmf
        self.obj = obj
        self.lib = lib
        self.cmd = cmd
        self.parameters = parameters
        self.env_settings = env_settings if env_settings is not None else {}
        self.joblog_path = joblog_path
        self.job.run_cl("CHGJOB LOG(4 00 *SECLVL)", log=False)
        self.tmp_lib = tmp_lib
        self.tmp_src = tmp_src
        ccsid = retrieve_ccsid(srcstmf)
        if ccsid == "1208" or ccsid == "819":
            self.ccsid_c = '*JOB'
        else:
            self.ccsid_c = str(ccsid)

    def run(self):
        self.setupEnv()

        run_datetime = datetime.now()
        # Delete the temp source file
        self.job.run_cl(f'DLTF FILE({self.tmp_lib}/{self.tmp_src})', True)
        # Create the temp source file
        self.job.run_cl(
            f'CRTSRCPF FILE({self.tmp_lib}/{self.tmp_src}) RCDLEN(198) MBR({self.obj}) CCSID({self.ccsid_c})')
        # Copy the source stream file to the temp source file
        self.job.run_cl(
            f'CPYFRMSTMF FROMSTMF("{self.srcstmf}") TOMBR("/QSYS.LIB/{self.tmp_lib}.LIB/{self.tmp_src}.FILE/{self.obj}.MBR") MBROPT(*REPLACE)')

        obj_type = COMMAND_MAP[self.cmd]
        # obj_name = f"{self.obj}.{obj_type}"

        back_up_job = IBMJob()
        back_up_job.run_cl(f"CRTSAVF FILE({self.tmp_lib}/SAVEFILE)")
        back_up_job.run_cl(
            f"SAVOBJ OBJ({self.obj}) LIB({self.lib}) DEV(*SAVF) OBJTYPE(*{obj_type}) SAVF({self.tmp_lib}/SAVEFILE)", True)
        back_up_job.run_cl(
            f"DLTOBJ OBJ({self.lib}/{self.obj}) OBJTYPE(*{obj_type})", True)

        # if check_object_exists(self.obj, self.lib, obj_type):
        #     print(f"Object ${self.lib}/${self.obj} already exists")
        #     if check_object_exists(self.obj, self.tmp_lib, obj_type):
        #         Path(objlib_to_path(self.tmp_lib, obj_name)).unlink()
        #     Path(objlib_to_path(self.lib, obj_name)).rename(
        #         objlib_to_path(self.tmp_lib, obj_name))

        cmd = f"{self.cmd} {obj_type}({self.lib}/{self.obj}) SRCFILE({self.tmp_lib}/{self.tmp_src}) SRCMBR({self.obj})"
        if self.parameters is not None:
            cmd = cmd + ' ' + self.parameters
        try:
            self.job.run_cl(cmd, False, True)
        except:
            print(f"Build not successful for {self.lib}/{self.obj}")
            back_up_job.run_cl(
                f"RSTOBJ OBJ({self.obj}) SAVLIB({self.lib}) DEV(*SAVF) OBJTYPE(*{obj_type}) SAVF({self.tmp_lib}/SAVEFILE)", True)
            # if check_object_exists(self.obj, self.tmp_lib, obj_type):
            # print("restoring...")
            # Path(objlib_to_path(self.tmp_lib, obj_name)).rename(
            #     objlib_to_path(self.lib, obj_name))
            # print("Done")

            # Process the event file
        if "*EVENTF" in cmd or "*SRCDBG" in cmd or "*LSTDBG" in cmd:
            if self.lib == "*CURLIB":
                self.lib = self._retrieve_current_library()
            if self.lib == "*NONE":
                self.lib = "*QGPL"
            self._update_event_file('37')

        if self.joblog_path is not None:
            save_joblog_json(cmd, format_datetime(
                run_datetime), self.job.job_id, self.joblog_path, filter_joblogs)

    def setupEnv(self):
        if "curlib" in self.env_settings and self.env_settings["curlib"]:
            self.job.run_cl(f"CHGCURLIB CURLIB({self.env_settings['curlib']})", log=True)

        if "preUsrlibl" in self.env_settings and self.env_settings["preUsrlibl"]:
            for libl in self.env_settings["preUsrlibl"].split().reverse():
                self.job.run_cl(f"ADDLIBLE LIB({libl}) POSITION(*FIRST)", log=True)

        if "postUsrlibl" in self.env_settings and self.env_settings["postUsrlibl"]:
            for libl in self.env_settings["postUsrlibl"].split().reverse():
                self.job.run_cl(f"ADDLIBLE LIB({libl}) POSITION(*LAST)", log=True)

        if "IBMiEnvCmd" in self.env_settings and self.env_settings["IBMiEnvCmd"]:
            for cmd in self.env_settings["IBMiEnvCmd"].split("\\n"):
                self.job.run_cl(cmd, log=True)

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
        metavar='<path to joblog json file>',
    )

    args = parser.parse_args()
    srcstmf_absolute_path = str(Path(args.stream_file.strip()).resolve())
    env_settings = {}
    if "curlib" in os.environ:
        env_settings["curlib"] = os.environ["curlib"]
    if "preUsrlibl" in os.environ:
        env_settings["preUsrlibl"] = os.environ["preUsrlibl"]
    if "postUsrlibl" in os.environ:
        env_settings["postUsrlibl"] = os.environ["postUsrlibl"]
    if "IBMiEnvCmd" in os.environ:
        env_settings["IBMiEnvCmd"] = os.environ["IBMiEnvCmd"]

    handle = CrtFrmStmf(srcstmf_absolute_path, args.object.strip(
    ), args.library.strip(), args.command.strip(), args.parameters, env_settings, args.save_joblog)

    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
    handle.run()
    print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")

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


def retrieve_ccsid(srcstmf: str) -> str:
    return _get_attr(srcstmf)["CCSID"]


def check_object_exists(obj: str, lib: str, obj_type: str) -> bool:
    obj_path = Path(f"/QSYS.LIB/{lib}.LIB/{obj}.{obj_type}")
    return obj_path.exists()

def delete_physical_dependencies(obj: str, lib: str, delete_pf: bool, verbose: bool=False):
    lib_path = Path(f'/QSYS.LIB/{lib}.lib')
    pf_path = lib_path / f"{obj}.file"
    if not pf_path.exists():
        if verbose:
            print(f"delete_physical_dependencies: {pf_path} does not exist.")
        return
    
    job = IBMJob()
    dep_files, _ = job.run_sql(f"Select DBFFDP, DBFLDP From QSYS.QADBFDEP Where DBFLIB='{lib}' and DBFFIL='{obj}' and DBFLDP='{lib}'")
    for dep_file in dep_files:
        dep_obj, dep_lib = dep_file
        dep_path = Path(objlib_to_path(dep_lib.strip(), f"{dep_obj.strip()}.FILE"))
        if verbose:
            print(f"delete_physical_dependencies: attempt to delete {dep_path}.")
        if dep_path.exists():
            dep_path.unlink()
            print(f"delete_physical_dependencies: {dep_path} deleted.")
    
    if delete_pf and pf_path.exists():
        if verbose:
            print(f"delete_physical_dependencies: attempt to delete {pf_path}.")
        pf_path.unlink()
        if verbose and pf_path.exists():
            print(f"delete_physical_dependencies: {pf_path} deleted.")
        else:
            print(f"delete_physical_dependencies: {pf_path} not deleted.")


def filter_joblogs(record: Dict[str, Any]) -> bool:
    msgid = record["MESSAGE_ID"]
    if msgid is None:
        return False
    if msgid == "CPD0912":
        # Printer device errors
        return False
    if msgid == "CPF1301":
        # Journaling errors
        return False
    if msgid == "CPF9898":
        # https://techchannel.com/SMB/02/2019/qsqsrvr-job-considerations
        return False
    if msgid == "CPF2105":
        # DLTF errors: no object found
        return False
    if msgid == "CPF1336":
        # TODO: Errors on CHGJOB command
        return False
    if "SQL" in msgid:
        # Ignore all SQL errors
        return False
    return True

if __name__ == "__main__":
    cli()
