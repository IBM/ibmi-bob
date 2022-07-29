#!/QOpenSys/pkgs/bin/python3.6
# -*- coding: utf-8 -*-

import json
from pathlib import Path
from typing import Dict, List, Optional, Union


JsonType = Union[None, int, str, bool, List["JsonType"], Dict["JsonType"]]

class IProjJson:
    """A class to represent the iproj.json file"""

    description: str
    version: Optional[str]
    license: str
    repository: Optional[str]
    includePath: List[str]
    objlib: str
    curlib: str
    pre_usr_libl: List[str]
    post_usr_libl: List[str]
    set_ibm_i_env_cmd: List[str]
    tgt_ccsid: str
    extensions: Optional[Dict[str, "JsonType"]]
    
    def __init__(self, build: Dict[str, str]):
        self.version = version
        self.build = build
    
    @staticmethod
    def from_file(file_path: str) -> IBMiJson:
        """Creates an IBMiJson object from a file"""
        with open(file_path, 'r') as f:
            data = json.load(f)
        return IProjJson(data['version'], data['build'])

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
            "setIBMiEnvCmd": self.set_ibm_i_env_cmd
        }

    def save(self, file_path: str) -> None:
        """Saves the IBMiJson object to a file"""
        if not Path(file_path).exists():
            Path(file_path).touch()
        with open(file_path, 'w') as f:
            json.dump(self.__dict__, f, indent=4)

