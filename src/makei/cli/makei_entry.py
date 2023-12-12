#!/usr/bin/env python3

# Licensed Materials - Property of IBM
# 57XX-XXX
# (c) Copyright IBM Corp. 2021
""" The CLI entry for BOB"""

import argparse
import os
import sys

from makei import __version__
from makei import init_project
from makei.build import BuildEnv
from makei.cvtsrcpf import CvtSrcPf
from makei.utils import Colors, colored, get_compile_targets_from_filenames


def cli():
    """
    makei program entry
    """
    parser = argparse.ArgumentParser(prog='makei')
    subparsers = parser.add_subparsers(
        title='These are common makei commands',
        metavar='command')

    add_init_parser(subparsers)
    add_info_parser(subparsers)
    add_compile_parser(subparsers)
    add_build_parser(subparsers)
    add_cvtsrcpf_parser(subparsers)

    parser.add_argument(
        '-v', '--version',
        help="print version information and exit",
        action='store_true'
    )

    args = parser.parse_args()
    if args.version:
        print(f"Bob version {__version__}")
    elif hasattr(args, 'handle'):
        args.handle(args)
    else:
        parser.print_help()


def add_build_parser(subparsers: argparse.ArgumentParser):
    """Add subparsers for build commands"""
    build_parser = subparsers.add_parser(
        'build',
        aliases=['b'],
        help='build the whole project',
    )
    build_target_group = build_parser.add_mutually_exclusive_group()
    build_target_group.add_argument(
        '-t',
        '--target',
        help='target to be built',
        metavar='<target>'
    )
    build_target_group.add_argument(
        '-d',
        '--subdir',
        help='subdirectory to be built',
        metavar='<subdir>'
    )
    build_parser.add_argument(
        '-o',
        '--make-options',
        help='options to pass to make',
        metavar='<options>',
    )
    build_parser.add_argument(
        '--bob-path',
        help='path to the bob directory',
        metavar='<path>',
    )
    build_parser.add_argument(
        '-e',
        '--env',
        help='override environment variables',
        metavar='<var>=<value>',
        action='append'
    )
    build_parser.set_defaults(handle=handle_build)


def add_compile_parser(subparsers: argparse.ArgumentParser):
    """Add subparsers for compile commands"""
    compile_parser = subparsers.add_parser(
        'compile',
        aliases=['c'],
        help='compile a single file')
    compile_target_group = compile_parser.add_mutually_exclusive_group(
        required=True)
    compile_target_group.add_argument(
        '-f',
        '--file',
        help='file to compile',
        metavar='<filename>')
    compile_target_group.add_argument(
        '--files',
        help='files to compile, separated by colon (:)',
        metavar='<filepaths>')
    compile_parser.add_argument(
        '-o',
        '--make-options',
        help='options to pass to make',
        metavar='<options>',
    )
    compile_parser.add_argument(
        '-e',
        '--env',
        help='override environment variables',
        metavar='<var>=<value>',
        action='append'
    )
    compile_parser.add_argument(
        '--bob-path',
        help='path to the bob directory',
        metavar='<path>',
    )
    compile_parser.set_defaults(handle=handle_compile)


def add_init_parser(subparsers: argparse.ArgumentParser):
    """Add subparsers for init commands"""
    init_parser = subparsers.add_parser(
        'init',
        help='set up a new or existing project')

    init_parser.add_argument('-f', '--force',
                             help='force overwrite any existing files',
                             action='store_true')
    init_parser.add_argument('-o', '--objlib',
                             help='update object library')
    init_parser.add_argument('-c', '--ccsid',
                             help='update target ccsid')
    init_parser.set_defaults(handle=handle_init)


def add_cvtsrcpf_parser(subparsers: argparse.ArgumentParser):
    cvtsrcpf_parser = subparsers.add_parser(
        'cvtsrcpf',
        help='convert source physical file members to UTF8 IFS files',
        description='Converts all members in a source physical file to properly-named \
                        (Better Object Builder-compatible), UTF8-encoded, LF-terminated source files \
                        in the current directory in the IFS. An .ibmi.json will also be created at the same directory.'
    )

    cvtsrcpf_parser.add_argument(
        "file",
        help='the name of the source file',
        metavar='<file>',
    )

    cvtsrcpf_parser.add_argument(
        "library",
        help='the name of the library',
        metavar='<library>',
    )

    cvtsrcpf_parser.add_argument(
        "-c",
        "--ccsid",
        help='The target EBCDIC CCSID that the source in this directory should be compiled with. If not specified, '
             'then the CCSID of the SRC-PF being converted will be used. '
             'If that CCSID is 65535 or an invalid CCSID is encountered than the CCSID of the JOB running '
             'the build will be used.',
        metavar='<ccsid>',
        type=str
    )

    cvtsrcpf_parser.add_argument(
        "-l",
        "--tolower",
        help='The generated source file name will be in lowercase.',
        action='store_true'
    )

    cvtsrcpf_parser.add_argument(
        "-t",
        "--text",
        help='The generated source file will include the member text as a comment.',
        action='store_true'
    )

    cvtsrcpf_parser.set_defaults(tolower=False)
    cvtsrcpf_parser.set_defaults(handle=handle_cvtsrcpf)


def add_info_parser(subparsers: argparse.ArgumentParser):
    """Add subparsers for info commands"""
    info_parser = subparsers.add_parser(
        'info',
        help='get information about the current project')

    info_parser.set_defaults(handle=handle_info)


def handle_init(args):
    """
    Handling the init command
    """
    init_project.init_project(force=args.force, objlib=args.objlib, tgtCcsid=args.ccsid)


def handle_info(_args):
    """
    Handling the info command
    """
    print("Not implemented!")


def handle_compile(args):
    """
    Processing the compile command
    """
    set_environment_vars(args)
    if args.file:
        filenames = [args.file]
    elif args.files:
        filenames = map(os.path.basename, args.files.split(':'))
    else:
        filenames = []
    targets = []
    source_names = []
    for name in filenames:
        if os.path.isdir(name):
            targets.append(make_dir_target(name))
        else:
            source_names.append(name)
    # print("source:"+' '.join(source_names))
    # print("compile targets:"+' '.join(get_compile_targets_from_filenames(source_names)))
    targets.extend(get_compile_targets_from_filenames(source_names))
    print(colored("targets: " + ' '.join(targets), Colors.OKBLUE))
    build_env = BuildEnv(targets, args.make_options, get_override_vars(args))
    if build_env.make():
        sys.exit(0)
    else:
        sys.exit(1)


def handle_build(args):
    """
    Processing the build command
    """
    set_environment_vars(args)
    if args.target:
        target = args.target
    elif args.subdir:
        target = make_dir_target(args.subdir)
    else:
        target = "all"
    build_env = BuildEnv([target], args.make_options, get_override_vars(args))
    if build_env.make():
        sys.exit(0)
    else:
        sys.exit(1)


def make_dir_target(filename):
    return f"dir_{os.path.basename(filename.strip(os.sep))}"


def handle_cvtsrcpf(args):
    """
    Processing the cvtsrcpf command
    """
    CvtSrcPf(args.file, args.library, args.tolower, args.ccsid, args.text).run()


def get_override_vars(args):
    """ Get the override variables from the arguments"""
    if args.bob_path:
        return {"bob_path": args.bob_path}
    return {}


def set_environment_vars(args):
    """ Set the environment variables defined in the arguments"""
    if "env" in args and args.env:
        for env in args.env:
            kv_pair = env.split("=")
            if len(kv_pair) != 2:
                print(colored(f"invalid format: {env}", Colors.FAIL))
                sys.exit(1)
            key, value = kv_pair[0], kv_pair[1]
            os.environ[key] = value
            print(colored(f"Set variable <{key}> to '{value}'", Colors.OKBLUE))


if __name__ == '__main__':
    cli()
