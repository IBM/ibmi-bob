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
    stmf_ccsid: str
    tgt_ccsid: str
    ibmi_json_path: Optional[Path]


    def __init__(self, srcfile: str, lib: str, stmf_ccsid: str = "1208", should_create_ibmi_json: bool = True, tgtccsid: str = "*JOB", save_path: Path = Path.cwd()) -> None:
        self.job = IBMJob()

        self.lib = lib
        self.srcfile = srcfile
        self.save_path = save_path
        if validate_ccsid(stmf_ccsid):
            self.stmf_ccsid = stmf_ccsid
        else:
            raise Exception(f"Invalid ccsid {stmf_ccsid}")
        if validate_ccsid(tgtccsid):
            self.tgt_ccsid = tgtccsid
        else:
            raise Exception(f"Invalid ccsid {tgtccsid}")
        self.ibmi_json_path = save_path / ".ibmi.json" if should_create_ibmi_json else None

    def run(self) -> int:
        srcpath = Path(objlib_to_path(self.lib, f"{self.srcfile}.FILE"))
        if not srcpath.exists():
            raise Exception(f"Source file '{srcpath}' does not exist")
        src_mbrs = self._get_src_mbrs(srcpath)
        print(f"{len(src_mbrs)} source members found.")
        cvt_count = 0
        for src_mbr in src_mbrs:
            if self._cvr_src_mbr(src_mbr, srcpath):
                cvt_count += 1
        if self.ibmi_json_path:
            create_ibmi_json(self.ibmi_json_path, tgt_ccsid = self.tgt_ccsid)
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
        return self.job.run_cl(f"CPYTOSTMF FROMMBR('{srcpath}/{src_mbr_name}.MBR') TOSTMF('{dst_mbr_path}') ENDLINFMT(*LF) STMFCCSID({self.stmf_ccsid}) STMFOPT(*REPLACE)", ignore_errors=True, log=True)


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

