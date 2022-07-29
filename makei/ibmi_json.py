#!/QOpenSys/pkgs/bin/python3.6
# -*- coding: utf-8 -*-

import json
from pathlib import Path

class IBMiJson:
    """A class to represent the ibmi.json file"""

    version: str
    build: Dict[str, str]

    def __init__(self, version: str, build: Dict[str, str]):
        self.version = version
        self.build = build

    @staticmethod
    def construct(tgt_ccsid: str = None, version: str = None, objlib: str = None) -> IBMiJson:
        """Constructs an IBMiJson object"""
        ibmi_json = IBMiJson(version, {})
        build = ibmi_json["build"]
        if tgt_ccsid is not None:
            build["tgtCcsid"] = tgt_ccsid
        if objlib is not None:
            build["objlib"] = objlib
        ibmi_json["build"] = build
        return ibmi_json
    
    @staticmethod
    def from_file(file_path: str) -> IBMiJson:
        """Creates an IBMiJson object from a file"""
        with open(file_path, 'r') as f:
            data = json.load(f)
        return IBMiJson(data['version'], data['build'])

    def __dict__(self):
        return {
            "version": self.version,
            "build": self.build
        }

    def save(self, file_path: str) -> None:
        """Saves the IBMiJson object to a file"""
        if not Path(file_path).exists():
            Path(file_path).touch()
        with open(file_path, 'w') as f:
            json.dump(self.__dict__, f, indent=4)


        build = ibmi_json["build"] if "build" in ibmi_json else {}
        if tgt_ccsid is not None:
            build["tgtCcsid"] = tgt_ccsid
        if objlib is not None:
            build["objlib"] = objlib
        if version is not None:
            ibmi_json["version"] = version
        ibmi_json["build"] = build
        with ibmi_json_path.open("w") as file:
            json.dump(ibmi_json, file, indent=4)
