#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
from pathlib import Path
from typing import List, Optional, Tuple

from makei.ibm_job import IBMJob
from makei.utils import create_ibmi_json, objlib_to_path, validate_ccsid

class CvtSrcPf:
    """convert from source physical file
    """
    # pylint: disable=too-few-public-methods
    job: IBMJob

    lib: str
    srcfile: str
    save_path: Path
    default_ccsid: Optional[str]
    tolower: bool
    ibmi_json_path: Optional[Path]
    store_member_text: bool

    def __init__(
        self, srcfile: str, lib: str, tolower: bool, default_ccsid: str = None, text: bool = False, save_path: Path = Path.cwd()
    ) -> None:
        self.job = IBMJob()

        self.lib = lib
        self.srcfile = srcfile
        self.save_path = save_path
        if default_ccsid is not None and validate_ccsid(default_ccsid):
            self.default_ccsid = default_ccsid
        else:
            self.default_ccsid = None

        self.tolower = tolower
        self.ibmi_json_path = save_path / ".ibmi.json"
        self.store_member_text = text

    def check_keyword_in_file(self, file_path: str, keyword: str, line_limit: str) -> bool:
        with open(file_path, 'r') as file:
            for line_number, line in enumerate(file, start=1):
                if keyword.lower() in line.lower():
                    return True
                if line_number == line_limit:
                    break
        return False
    
    # for free form rpg, write_on_line = 1
    def insert_line(self, file_path, content, start_comment_characters: str, end_comment_characters: str, write_on_line: int = 0, start_column: int = 7, end_column: int = 71) -> bool:
        try:
            if end_column <= start_column: return False
            with open(file_path, 'r+') as file:
                lines = file.readlines()
                lines.insert(write_on_line, '\n')

                starting_whitespace = 0 if start_column == 0 else start_column - 1
                ending_whitespace = (end_column - 1) - (starting_whitespace + len(content))

                lines[write_on_line] = (' ' * starting_whitespace) + start_comment_characters + content + (' ' * ending_whitespace) + end_comment_characters + '\n'
                file.seek(0)
                file.writelines(lines)
            return True
        except:
            return False
        
    def import_member_text(self, file_path: str, member_text: str, member_extension: str) -> bool:
        text_comment_exists = self.check_keyword_in_file(file_path, 'TEXT', 15)

        if not text_comment_exists:
            # Fixed-form RPG
            is_free_form = self.check_keyword_in_file(file_path, 'FREE', 1)
            if is_free_form:
                self.insert_line(file_path, '%EMETADATA ', '//', '*', write_on_line=1)
                self.insert_line(file_path, ' %TEXT ' + member_text, '//', '*', write_on_line=1)
                self.insert_line(file_path, '%METADATA ', '//', '*', write_on_line=1)
            else:
                self.insert_line(file_path, '%EMETADATA ', '*', '*', 0, 7, 71)
                self.insert_line(file_path, ' %TEXT ' + member_text, '*', '*', 0, 7, 71)
                self.insert_line(file_path, '%METADATA ', '*', '*', 0, 7, 71)


    def run(self) -> int:
        srcpath = Path(objlib_to_path(self.lib, f"{self.srcfile}.FILE"))
        if not srcpath.exists():
            raise Exception(f"Source file '{srcpath}' does not exist")
        src_mbrs = self._get_src_mbrs()
        src_ccsid = retrieve_ccsid(str(srcpath), self._default_ccsid())
        if validate_ccsid(src_ccsid):
            self.default_ccsid = src_ccsid
        else:
            self.default_ccsid = "*JOB"

        print(f"{len(src_mbrs)} source members found.")
        cvt_count = 0
        for src_mbr in src_mbrs:
            src_mbr_name = self._get_src_mbr_name(src_mbr)
            src_mbr_ext = self._get_src_mbr_ext(src_mbr)
            dst_mbr_name = self._get_dst_mbr_name(src_mbr_name, src_mbr_ext, self.tolower)
            dst_mbr_path = self._get_dst_mbr_path(dst_mbr_name, src_mbr_name, src_mbr_ext)

            if self._cvr_src_mbr(src_mbr_name, srcpath, dst_mbr_name, dst_mbr_path):
                cvt_count += 1
                if self.store_member_text:
                    result = self._get_member_text(src_mbr_name, srcpath)
                    member_text = result[0][0][0]

                    # If member has no text
                    if member_text != None:
                        self.import_member_text(dst_mbr_path, member_text, src_mbr_ext)
            
                    
        if self.ibmi_json_path:
            create_ibmi_json(self.ibmi_json_path, tgt_ccsid=self.default_ccsid)
        
        return cvt_count

    def _default_ccsid(self) -> str:
        if self.default_ccsid is None:
            return "*JOB"
        else:
            return self.default_ccsid
    
    # Returns the source member's name without the extension
    def _get_src_mbr_name(self, src_mbr) -> str: 
        return src_mbr[0]

    # Returns the source member's extension
    def _get_src_mbr_ext(self, src_mbr) -> str:
        src_mbr_ext = src_mbr[1]
        if src_mbr_ext == ".src":
            src_mbr_ext = ".pf"
        return src_mbr_ext

    def _get_dst_mbr_name(self, src_mbr_name, src_mbr_ext, tolower: bool) -> str:
        dst_mbr_name = f"{src_mbr_name}.{src_mbr_ext}"
        if tolower:
            dst_mbr_name = dst_mbr_name.lower()
        return dst_mbr_name
    
    def _get_dst_mbr_path(self, dst_mbr_name, src_mbr_name, src_mbr_ext) -> str:
        dst_mbr_path = self.save_path / dst_mbr_name
        dups = 0
        while dst_mbr_path.exists():
            # if dst_mbr_name exists, rename it
            dups += 1
            dst_mbr_name = f"{src_mbr_name}_{dups}.{src_mbr_ext}"
            dst_mbr_path = self.save_path / dst_mbr_name
        return dst_mbr_path

    def _cvr_src_mbr(self, src_mbr_name, srcpath, dst_mbr_name, dst_mbr_path) -> bool:
        """Convert the source member
        """
        print(f"Converting {src_mbr_name} to {dst_mbr_name}")
        return self.job.run_cl(
            f"CPYTOSTMF FROMMBR('{srcpath}/{src_mbr_name}.MBR') "
            f"TOSTMF('{dst_mbr_path}') ENDLINFMT(*LF) STMFCCSID(1208) STMFOPT(*REPLACE)",
            ignore_errors=True, log=True)
    
    def _get_member_text(self, src_mbr_name, srcpath):
        """Convert the source member
        """
        return self.job.run_sql(
            f"SELECT TEXT_DESCRIPTION FROM TABLE(qsys2.ifs_object_statistics('{srcpath}/{src_mbr_name}.MBR'))",
            ignore_errors=True, log=False)


    def _get_src_mbrs(self) -> List[Tuple[str, str]]:
        """Get the source members of the source file
        """
        library = self.lib.upper()
        srcpf = self.srcfile.upper()
        results = self.job.run_sql(
            f"select SYSTEM_TABLE_MEMBER, SOURCE_TYPE from qsys2.syspartitionstat "
            f"where SYSTEM_TABLE_SCHEMA='{library}' and SYSTEM_TABLE_NAME='{srcpf}'")
        if results:
            src_mbrs = []
            for row in results[0]:
                mbr_name = row[0].strip()
                if isinstance(row[1], str):
                    mbr_type = row[1].strip()
                else:
                    mbr_type = ''
                src_mbrs.append((mbr_name, mbr_type))
            return src_mbrs
        return []


def _get_attr(filepath: str, defaultCcsid: str):
    stream = os.popen(f'/QOpenSys/usr/bin/attr {filepath}')
    output = stream.read().strip()
    attrs = {"CCSID": defaultCcsid}
    if not output.__contains__("="):
        raise Exception(f"Unable to access '{filepath}' make sure file exists and that the user has permissions to it")
    else:
        for attr in output.split("\n"):
            [key, value] = attr.split("=")
            attrs[key] = value
    return attrs


def retrieve_ccsid(filepath: str, defaultCcsid: str) -> str:
    return _get_attr(filepath, defaultCcsid)["CCSID"]


if __name__ == "__main__":
    import doctest

    doctest.testmod()
