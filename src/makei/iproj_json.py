#!/usr/bin/env python3.9
# -*- coding: utf-8 -*-

import json
import sys
from pathlib import Path
from typing import Dict, List, Optional, Union

from makei.const import DEFAULT_CURLIB, DEFAULT_OBJLIB
from makei.utils import parse_all_variables, Colors, colored

JsonType = Union[None, int, str, bool, List["JsonType"], Dict["JsonType", "JsonType"]]


class IProjJson:
    """A class to represent the iproj.json file"""
    # pylint: disable=too-many-instance-attributes

    description: str
    version: Optional[str]
    license: str
    repository: Optional[str]
    include_path: List[str]
    objlib: str
    curlib: str
    pre_usr_libl: List[str]
    post_usr_libl: List[str]
    set_ibm_i_env_cmd: List[str]
    tgt_ccsid: str
    extensions: Optional[Dict[str, "JsonType"]]

    def __init__(self, description: str = "",
                 version: Optional[str] = None,
                 license: str = "",
                 repository: Optional[str] = None,
                 include_path: List[str] = None,
                 objlib: str = DEFAULT_OBJLIB,
                 curlib: str = DEFAULT_CURLIB,
                 pre_usr_libl: List[str] = None,
                 post_usr_libl: List[str] = None,
                 set_ibm_i_env_cmd: List[str] = None,
                 tgt_ccsid: str = "*JOB",
                 extensions: Optional[Dict[str, JsonType]] = None):
        # pylint: disable=too-many-arguments

        self.description = description
        self.version = version
        self.license = license
        self.repository = repository
        self.include_path = include_path if include_path else []
        self.objlib = objlib
        self.curlib = curlib
        self.pre_usr_libl = pre_usr_libl if pre_usr_libl else []
        self.post_usr_libl = post_usr_libl if post_usr_libl else []
        self.set_ibm_i_env_cmd = set_ibm_i_env_cmd if set_ibm_i_env_cmd else []
        self.tgt_ccsid = tgt_ccsid
        self.extensions = extensions if extensions else {}

    @classmethod
    def from_file(cls, file_path: Path) -> "IProjJson":
        """Creates an IBMiJson object from a file"""

        def with_default_value(key, default_value, src_dict):
            if key in src_dict:
                return src_dict[key]
            return default_value

        try:
            with file_path.open() as file:
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

                pre_usr_libl = list(map(parse_all_variables, with_default_value("preUsrlibl", [], iproj_json)))

                post_usr_libl = list(map(parse_all_variables, with_default_value("postUsrlibl", [], iproj_json)))
                include_path = list(map(parse_all_variables, with_default_value("includePath", [], iproj_json)))

                tgt_ccsid = with_default_value("tgtCcsid", "*JOB", iproj_json)
                set_ibm_i_env_cmd = list(map(parse_all_variables, with_default_value("setIBMiEnvCmd", [], iproj_json)))
                extensions = with_default_value("extensions", {}, iproj_json)
                return IProjJson(
                    description=with_default_value("description", "", iproj_json),
                    version=with_default_value("version", None, iproj_json),
                    license=with_default_value("license", "", iproj_json),
                    repository=with_default_value("repository", None, iproj_json),
                    include_path=include_path,
                    objlib=objlib,
                    curlib=curlib,
                    pre_usr_libl=pre_usr_libl,
                    post_usr_libl=post_usr_libl,
                    set_ibm_i_env_cmd=set_ibm_i_env_cmd,
                    tgt_ccsid=tgt_ccsid,
                    extensions=extensions
                )
        except FileNotFoundError:
            print(colored("iproj.json not found!", Colors.FAIL))
            sys.exit(1)

    def __dict__(self):
        return {
            "description": self.description,
            "version": self.version,
            "license": self.license,
            "repository": self.repository,
            "includePath": self.include_path,
            "objlib": self.objlib,
            "curlib": self.curlib,
            "preUsrLibl": self.pre_usr_libl,
            "postUsrLibl": self.post_usr_libl,
            "setIBMiEnvCmd": self.set_ibm_i_env_cmd,
            "tgtCcsid": self.tgt_ccsid,
            "extensions": self.extensions
        }

    def save(self, file_path: str) -> None:
        """Saves the IBMiJson object to a file"""
        if not Path(file_path).exists():
            Path(file_path).touch()
        with open(file_path, 'w', encoding="utf-8") as f:
            json.dump(self.__dict__, f, indent=4)


if __name__ == "__main__":
    import doctest

    doctest.testmod()
