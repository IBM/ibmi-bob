#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
from pathlib import Path
from typing import Any, Callable, Dict, List, Optional, Tuple
import ibm_db_dbi
from contextlib import closing
from makei.utils import format_datetime


class IBMJob():
    job_id: str
    conn: ibm_db_dbi.Connection

    def __init__(self):
        try:
            self.conn = ibm_db_dbi.connect()
            # https://kadler.io/2018/09/20/using-python-ibm-db-with-un-journaled-files.html#
            self.conn.set_option({ibm_db_dbi.SQL_ATTR_TXN_ISOLATION:
                                  ibm_db_dbi.SQL_TXN_NO_COMMIT})
            self.job_id = self.run_sql("VALUES(QSYS2.JOB_NAME)")[0][0][0]
        except Exception as e:
            print(e)
            print("Cannot connect to the database")
            exit(1)

    def __del__(self):
        print("closing the connection...")
        self.conn.close()
        print("Done")

    def run_cl(self, cmd: str, ignore_errors: bool = False):
        print(f"▶️  {cmd}")
        with closing(self.conn.cursor()) as cursor:
            try:
                cursor.callproc("qsys2.qcmdexc", [cmd])
            except Exception as e:
                if not ignore_errors:
                    print(f"❌ ", end="")
                    raise

    def run_sql(self, sql, ignore_errors=False):
        with closing(self.conn.cursor()) as cursor:
            try:
                print(f"🔎 {sql}")
                cursor.execute(sql)
                try:
                    column_names = [column[0] for column in cursor.description]
                    rows = cursor.fetchall()
                except:
                    return None
                return (rows, column_names)
            except Exception as e:
                if not ignore_errors:
                    print(f"❌ ", end="")
                    raise

    def _dump_results_to_dict(self, results: Tuple[List[str], List[List[Any]]]):
        record_dicts = []
        records, column_names = results
        for record in records:
            record_dicts.append(dict(zip(column_names, record)))
        return record_dicts

    def dump_joblog(self):
        return get_joblog_for_job(self.job_id)


def get_joblog_for_job(id: str) -> List[Dict[str, Any]]:
    query_job = IBMJob()
    sql = f"SELECT MESSAGE_ID," + \
        "MESSAGE_TEXT," + \
        "MESSAGE_SECOND_LEVEL_TEXT," + \
        "MESSAGE_TYPE," + \
        "SEVERITY," + \
        "MESSAGE_TIMESTAMP," + \
        "FROM_PROGRAM," + \
        "FROM_LIBRARY," + \
        "FROM_INSTRUCTION," + \
        "TO_PROGRAM," + \
        "TO_LIBRARY," + \
        "TO_MODULE," + \
        "TO_PROCEDURE," + \
        "TO_INSTRUCTION" + \
        " " + \
        "FROM TABLE(" + \
        f"QSYS2.JOBLOG_INFO('{id}')" + \
        ") A"
    results = query_job.run_sql(sql)
    joblog_dict = query_job._dump_results_to_dict(results)
    return joblog_dict


def save_joblog_json(cmd: str, cmd_time: str, jobid: str, joblog_json: Optional[str], filter: Callable[[Dict[str, Any]], bool] = None):
    records = get_joblog_for_job(jobid)
    messages = []
    for record in records:
        if filter is not None and not filter(record):
            continue
        if "not safe for a multithreaded job" in record["MESSAGE_TEXT"]:
            continue
        messages.append({"msgid": record["MESSAGE_ID"],
                         "type": record["MESSAGE_TYPE"],
                         "severity": record["SEVERITY"],
                         "message_time": format_datetime(record["MESSAGE_TIMESTAMP"]),
                         "message_text": record["MESSAGE_TEXT"],
                         "second_level": record["MESSAGE_SECOND_LEVEL_TEXT"],
                         "from_program": record["FROM_PROGRAM"],
                         "from_library": record["FROM_LIBRARY"],
                         "from_instruction": record["FROM_INSTRUCTION"],
                         "to_program": record["TO_PROGRAM"],
                         "to_library": record["TO_LIBRARY"],
                         "to_module": record["TO_MODULE"],
                         "to_procedure": record["TO_PROCEDURE"],
                         "to_instruction": record["TO_INSTRUCTION"]})

    dumped_joblog = {
        "cmd": cmd,
        "cmd_time": cmd_time,
        "msgs": messages
    }

    if joblog_json is not None:
        joblog_json_path = Path(joblog_json)
        if (joblog_json_path.is_file()):
            with joblog_json_path.open() as json_file:
                data = json.load(json_file)
                data.append(dumped_joblog)
        else:
            data = [dumped_joblog]

        with joblog_json_path.open('w') as json_file:
            json.dump(data, json_file, indent=4)
    else:
        print(json.dumps([dumped_joblog], indent=4))
