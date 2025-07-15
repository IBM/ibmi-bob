#!/usr/bin/env python3.9

""" The module used to build a project"""
import sys
import os
from pathlib import Path
from tempfile import mkstemp
from typing import Any, Dict, List, Optional

from makei.const import BOB_PATH, MK_PATH
from makei.ibmi_json import IBMiJson
from makei.iproj_json import IProjJson
from makei.rules_mk import RulesMk
from makei.utils import objlib_to_path, \
    run_command, support_color, print_to_stdout, Colors, colored


class BuildEnv:
    """ The Build Environment used to build or compile a project. """
    # pylint: disable=too-many-instance-attributes

    color_tty: bool
    src_dir: Path
    targets: List[str]
    make_options: Optional[str]
    bob_path: Path
    bob_makefile: Path
    build_vars_path: Path
    build_vars_handle: Path
    curlib: str
    pre_usr_libl: str
    post_usr_libl: str
    iproj_json_path: Path
    iproj_json: IProjJson
    ibmi_env_cmds: str

    tmp_files: List[Path] = []

    success_targets: List[str]
    failed_targets: List[str]

    def __init__(self, targets: List[str] = None, make_options: Optional[str] = None,
                 overrides: Dict[str, Any] = None):
        overrides = overrides or {}
        self.src_dir = Path.cwd()
        self.targets = targets if targets is not None else ["all"]
        self.make_options = make_options if make_options else ""
        self.bob_path = Path(
            overrides["bob_path"]) if "bob_path" in overrides else BOB_PATH
        self.bob_makefile = MK_PATH / 'Makefile'
        self.build_vars_handle, path = mkstemp()
        self.build_vars_path = Path(path)
        self.iproj_json_path = self.src_dir / "iproj.json"
        self.iproj_json = IProjJson.from_file(self.iproj_json_path)
        self.color = support_color()

        if len(self.iproj_json.set_ibm_i_env_cmd) > 0:
            cmd_list = self.iproj_json.set_ibm_i_env_cmd
            self.ibmi_env_cmds = "\\n".join(cmd_list)
        else:
            self.ibmi_env_cmds = ""

        self.success_targets = []
        self.failed_targets = []

        self._create_build_vars()

    def __del__(self):
        self.build_vars_path.unlink()

    def generate_make_cmd(self):
        """ Returns the make command used to build the project."""
        cmd = f'/QOpenSys/pkgs/bin/make -k BUILDVARSMKPATH="{self.build_vars_path}"' + \
              f' -k BOB="{self.bob_path}" -f "{self.bob_makefile}"'
        if self.make_options:
            cmd = f"{cmd} {self.make_options}"
        cmd = f"{cmd} {' '.join(self.targets)}"
        return cmd

    def _create_build_vars(self):
        target_file_path = self.build_vars_path

        rules_mk_paths = list(Path(".").rglob("Rules.mk"))
        real_targets = []
        # Create Rules.mk.build for each Rules.mk
        for rules_mk_path in rules_mk_paths:
            rules_mk = RulesMk.from_file(rules_mk_path,  self.src_dir, map(Path, self.iproj_json.include_path))
            rules_mk_src_obj_mapping = rules_mk.src_obj_mapping.copy()
            if self.targets and self.targets[0] != "all":
                for target in self.targets:
                    if target.startswith("dir_") and target not in real_targets:
                        real_targets.append(target)
                    else:
                        # Target is relative path. i.e. QRPGLESRC/TEST.RPGLE
                        if len(Path(target).parts) > 1:
                            tgt_dir = os.path.dirname(target)
                            tgt = os.path.basename(target)
                        # Target is a file name
                        else:
                            tgt_dir = "."
                            tgt = target

                        # Target exist in the current Rules.mk and target's rule exists
                        if tgt_dir == str(rules_mk.containing_dir) and tgt.upper() in rules_mk_src_obj_mapping:
                            real_targets.append(rules_mk_src_obj_mapping.pop(tgt.upper()))
            rules_mk.build_context = self
            rules_mk_build_path = rules_mk_path.parent / ".Rules.mk.build"
            rules_mk_build_path.write_text(str(rules_mk))
            self.tmp_files.append(rules_mk_build_path)
        self.targets = real_targets if real_targets else self.targets

        subdirs = list(map(lambda x: x.parents[0], rules_mk_paths))

        subdirs.sort(key=lambda x: len(x.parts))
        dir_var_map = {Path('.'): IBMiJson.from_values(self.iproj_json.tgt_ccsid, self.iproj_json.objlib)}

        def map_ibmi_json_var(path):
            if path != Path("."):
                dir_var_map[path] = IBMiJson.from_file(path / ".ibmi.json", dir_var_map[path.parents[0]])

        list(map(map_ibmi_json_var, subdirs))

        # set build env variables based on iproj.json
        # if not include_path specified just use INCDIR(*NONE)
        #  otherwise use INCDIR('dir1' 'dir2')
        incdir = "*NONE"
        include_path = self.iproj_json.include_path
        # if include path is not empty or *NONE then wrap in single quotes
        if len(include_path) > 0 and [v.upper() for v in include_path] != ["*NONE"]:
            incdir = '\'' + '\' \''.join(include_path) + '\''
        elif len(include_path) == 1:
            incdir = include_path[0].upper()
        with target_file_path.open("w", encoding="utf8") as file:
            file.write(f"""# This file is generated by makei, DO NOT EDIT.
# Modify .ibmi.json to override values

curlib := {self.iproj_json.curlib}
preUsrlibl := {' '.join(self.iproj_json.pre_usr_libl)}
postUsrlibl := {' '.join(self.iproj_json.post_usr_libl)}
INCDIR := {incdir}
unquotedINCDIR := {' '.join(include_path)}
doublequotedINCDIR := {incdir.replace("'", "''")}
IBMiEnvCmd := {self.ibmi_env_cmds}
COLOR_TTY := {'true' if self.color else 'false'}

""")
            for subdir in subdirs:
                # print(dir_var_map[subdir].build)
                file.write(
                    f"TGTCCSID_{subdir.absolute()} := {dir_var_map[subdir].build['tgt_ccsid']}\n")
                file.write(
                    f"OBJPATH_{subdir.absolute()} := {objlib_to_path(dir_var_map[subdir].build['objlib'])}\n")

            # for rules_mk in rules_mks:
            #     with rules_mk.open('r') as rules_mk_file:
            #         lines = rules_mk_file.readlines()
            #         for line in lines:
            #             line = line.rstrip()
            #             if line and not line.startswith("#") \
            #                     and not "=" in line and not line.startswith((' ', '\t')):
            #                 file.write(
            #                     f"{line.split(':')[0]}_d := {rules_mk.parents[0].absolute()}\n")

    def make(self):
        """ Generate and execute the make command."""
        if (self.src_dir / ".logs" / "joblog.json").exists():
            (self.src_dir / ".logs" / "joblog.json").unlink()
        if (self.src_dir / ".logs" / "output.log").exists():
            (self.src_dir / ".logs" / "output.log").unlink()

        def handle_make_output(line_bytes: bytes):
            if isinstance(line_bytes, bytes):
                line = line_bytes.decode(sys.getdefaultencoding())
            if "Failed to create" in line:
                self.failed_targets.append(line.split()[-1].split("!")[0])
            if "was created successfully!" in line:
                self.success_targets.append(line.split()[1])
            print_to_stdout(line)

        run_command(self.generate_make_cmd(), handle_make_output)
        self._post_make()
        return not self.failed_targets

    def _post_make(self):
        for tmp_file in self.tmp_files:
            tmp_file.unlink()
        print(colored("Objects:            ", Colors.BOLD), colored(f"{len(self.failed_targets)} failed", Colors.FAIL),
              colored(f"{len(self.success_targets)} succeed", Colors.OKGREEN),
              f"{len(self.success_targets) + len(self.failed_targets)} total")
        if self.failed_targets:
            print(" > Failed objects:   ", " ".join(self.failed_targets))
        print(colored("Build Completed!", Colors.BOLD))
        # event_files = list(Path(".evfevent").rglob("*.evfevent"))

        # def replace_abs_path(line: str) -> str:
        #     if str(Path.cwd()) in line:
        #         line = line.replace(f'{Path.cwd()}/', '')
        #         new_len = len(line.split()[5])
        #         # Replace length
        #         line = line[:24] + f"{new_len:03d}" + line[27:]
        #         return line
        #     else:
        #         return line

        # for filepath in event_files:
        #     replace_file_content(filepath, replace_abs_path)
