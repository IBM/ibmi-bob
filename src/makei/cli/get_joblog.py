#!/usr/bin/env python3.9
# -*- coding: utf-8 -*-

import argparse

from makei.ibm_job import save_joblog_json


def cli():
    parser = argparse.ArgumentParser(prog='getJobLog')

    parser.add_argument("cmd",
                        metavar='<cmd>',
                        )

    parser.add_argument(
        "cmdtime",
        metavar='<cmdtime>',
    )

    parser.add_argument(
        'jobid',
        metavar='<jobid>',
    )

    parser.add_argument(
        'object',
        metavar='<object>',
        default=""
    )

    parser.add_argument(
        'source',
        metavar='<source>',
    )

    parser.add_argument(
        'output',
        metavar='<output>',
    )

    parser.add_argument(
        'failed',
        metavar='<failed>',
    )

    parser.add_argument(
        "-f",
        metavar='<file>',
    )

    args = parser.parse_args()
    save_joblog_json(args.cmd, args.cmdtime, args.jobid, args.object, args.source, args.output,
                     False if args.failed == "False" else True, args.f)


if __name__ == "__main__":
    cli()
