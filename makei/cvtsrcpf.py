#!/QOpenSys/pkgs/bin/python3.6
# -*- coding: utf-8 -*-
import argparse
from fileinput import filename
import os
from pathlib import Path
import re
import shutil
import sys
from typing import Any, Dict, List, Optional, Tuple
from unittest import result

sys.path.append(str(Path(__file__).resolve().parent.parent))  # nopep8
from makei.utils import Colors, colored, create_ibmi_json, objlib_to_path, validate_ccsid
from makei.ibm_job import IBMJob  # nopep8


class CvtSrcPf():
    """convert from source physical file
    """
    job: IBMJob

    lib: str
    srcfile: str
    save_path: Path
    defaultCcsid: Optional[str]
    ibmi_json_path: Optional[Path]


    def __init__(self, srcfile: str, lib: str, defaultCcsid: str = None, save_path: Path = Path.cwd()) -> None:
        self.job = IBMJob()

        self.lib = lib
        self.srcfile = srcfile
        self.save_path = save_path
        if defaultCcsid is not None and validate_ccsid(defaultCcsid):
            self.defaultCcsid = defaultCcsid

        self.ibmi_json_path = save_path / ".ibmi.json"

    def run(self) -> int:
        srcpath = Path(objlib_to_path(self.lib, f"{self.srcfile}.FILE"))
        if not srcpath.exists():
            raise Exception(f"Source file '{srcpath}' does not exist")
        src_mbrs = self._get_src_mbrs(srcpath)
        src_ccsid = retrieve_ccsid(srcpath)
        if self.defaultCcsid is None:
            if validate_ccsid(src_ccsid):
                self.defaultCcsid = src_ccsid
            else:
                self.defaultCcsid = "*JOB"

        print(f"{len(src_mbrs)} source members found.")
        cvt_count = 0
        for src_mbr in src_mbrs:
            if self._cvr_src_mbr(src_mbr, srcpath):
                cvt_count += 1
        if self.ibmi_json_path:
            create_ibmi_json(self.ibmi_json_path, tgt_ccsid = self.defaultCcsid)
        return cvt_count

    def _cvr_src_mbr(self, src_mbr, srcpath) -> bool:
        """Convert the source member
        """
        src_mbr_name = src_mbr[0]
        src_mbr_ext = src_mbr[1]
        if src_mbr_ext == ".src":
            src_mbr_ext = ".pf"
        dst_mbr_name = f"{src_mbr_name}.{src_mbr_ext}"
        dst_mbr_path = self.save_path / dst_mbr_name
        dups = 0
        while dst_mbr_path.exists():
            # if dst_mbr_name exists, rename it
            dups += 1
            dst_mbr_name = f"{src_mbr_name}_{dups}.{src_mbr_ext}"
            dst_mbr_path = self.save_path / dst_mbr_name

        print(f"Converting {src_mbr_name} to {dst_mbr_name}")
        return self.job.run_cl(f"CPYTOSTMF FROMMBR('{srcpath}/{src_mbr_name}.MBR') TOSTMF('{dst_mbr_path}') ENDLINFMT(*LF) STMFCCSID(1208) STMFOPT(*REPLACE)", ignore_errors=True, log=True)


    def _get_src_mbrs(self, srcpath: Path) -> List[Tuple[str, str]]:
        """Get the source members of the source file
        """
        results = self.job.run_sql(f"select SYSTEM_TABLE_MEMBER, SOURCE_TYPE from qsys2.syspartitionstat where SYSTEM_TABLE_SCHEMA='{self.lib}' and SYSTEM_TABLE_NAME='{self.srcfile}'")
        if results:
            src_mbrs = []
            for row in results[0]:
                mbr_name = row[0].strip()
                mbr_type = row[1].strip()
                src_mbrs.append((mbr_name, mbr_type))
            return src_mbrs
        else:
            return []


def _get_attr(filepath: str):
    import os
    stream = os.popen(f'/QOpenSys/usr/bin/attr {filepath}')
    output = stream.read().strip()
    attrs = {}
    for attr in output.split("\n"):
        [key, value] = attr.split("=")
        attrs[key] = value
    return attrs


def retrieve_ccsid(filepath: str) -> str:
    return _get_attr(filepath)["CCSID"]


if __name__ == "__main__":
    import doctest
    doctest.testmod()

