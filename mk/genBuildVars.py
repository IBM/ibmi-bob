import argparse
import os
from pathlib import Path
from glob import glob
import json


def parse_args():
    parser = argparse.ArgumentParser(description='Generate a single makefile of build variables from ibmi.json')
    parser.add_argument('target_file', help='The generated file path')
    parser.add_argument('proj_dir', help='The project path')
    parsed_args = parser.parse_args()
    return parsed_args


def read_ibmi_json(path, parent_value):
    if path.exists():
        with path.open() as f:
            data = json.load(f)
            try:
                objlib = parse_placeholder(data['build']['objlib'])
                
            except Exception:
                objlib = parent_value[0]
            try:
                tgtCcsid = data['build']['tgtCcsid']
            except Exception:
                tgtCcsid = parent_value[1]
            return (objlib, tgtCcsid)
    else:
        return parent_value

def parse_placeholder(varName):
    if varName.startswith("&") and len(varName) > 1:
        varName = varName[1:]
        try:
            value = os.environ[varName]
            return value
        except Exception:
            print(f"{varName} must be defined first in the environment variable.")
    else:
        return varName

def read_iproj_json(iproj_json_path):
    with iproj_json_path.open() as f:
        iproj_json = json.load(f)
        objlib = parse_placeholder(iproj_json["objlib"]) if "objlib" in iproj_json else ""
        curlib = parse_placeholder(iproj_json["curlib"]) if "curlib" in iproj_json else ""
        if objlib == "*CURLIB":
            if curlib == "*CRTDFT":
                objlib="QGPL"
            else:
                objlib=curlib

        return {
            "objlib": objlib,
            "curlib": curlib,
            "tgtCcsid": iproj_json["tgtCcsid"] if "tgtCcsid" in iproj_json else "*JOB",
        }

def objlib_to_path(objlib):
    return f"/QSYS.LIB/{objlib}.LIB"


def main(args):
    target_file_path = Path(args.target_file)
    proj_dir_path = Path(args.proj_dir)
    os.chdir(proj_dir_path)

    iproj_json = read_iproj_json(proj_dir_path / "iproj.json")

    # ibmi_jsons = list(Path(".").rglob(".ibmi.json"))
    rules_mks = list(Path(".").rglob("Rules.mk"))
    subdirs = list(map(lambda x: x.parents[0], rules_mks))

    subdirs.sort(key=lambda x: len(x.parts))
    dir_var_map = {Path('.'): (iproj_json['objlib'], iproj_json['tgtCcsid'])}


    def map_ibmi_json_var(path):
        if path != Path("."):
            dir_var_map[path] = read_ibmi_json(path / ".ibmi.json", dir_var_map[path.parents[0]])

    list(map(map_ibmi_json_var, subdirs))

    with target_file_path.open("a") as f:
        for subdir in subdirs:
            f.write(f"TGTCCSID_{subdir.absolute()} := {dir_var_map[subdir][1]}\n")
            f.write(f"OBJPATH_{subdir.absolute()} := {objlib_to_path(dir_var_map[subdir][0])}\n")

        for rules_mk in rules_mks:
            with rules_mk.open('r') as r:
                ls = r.readlines()
                for l in ls:
                    l = l.strip()
                    if l and not l.startswith("#") and not "=" in l:
                        f.write(f"{l.split(':')[0]}_d := {rules_mk.parents[0].absolute()}\n")
                


if __name__ == "__main__":
    args = parse_args()
    main(args)
