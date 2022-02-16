#!/usr/bin/env python3
import argparse
import os
from pathlib import Path
import json
import sys

from scripts import init_project

def cli():
    """
    makei program entry
    """
    parser = argparse.ArgumentParser(prog='makei')
    subparsers = parser.add_subparsers(
        title='These are common makei commands',
        metavar='command')

    subparsers.add_parser('help')

    init_parser = subparsers.add_parser(
        'init',
        help='Set up a new or existing project.')
    init_parser.set_defaults(handle=handle_init)

    compile_parser = subparsers.add_parser(
        'compile',
        help='Compile a single file')
    compile_parser.add_argument(
        'sourcefile',
        help='Source file to compile',
        nargs='*'
    )
    compile_parser.set_defaults(handle=handle_compile)

    build_parser = subparsers.add_parser(
        'build',
        help='Build the whole project',
    )
    build_parser.add_argument(
        'positional',
        help='positional',
        nargs='*')
    build_parser.set_defaults(handle=handle_build)

    args, unknown = parser.parse_known_args()
    if hasattr(args, 'handle'):
        args.handle(args, unknown)
    else:
        parser.print_help()

def handle_init(args, unknown):
    """
    Handling the init command
    """
    init_project.init_project()

def handle_compile(args, unknown):
    """
    Processing the compile command
    """
    print(f'compile {args}')

def handle_build(args, unknown):
    """
    Processing the build command
    """
    print(f'build {args} {unknown}')

if __name__ == '__main__':
    cli()
