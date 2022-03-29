#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from typing import Any, List, Tuple
import ibm_db_dbi
from contextlib import closing


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
        except Exception:
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
            f"QSYS2.JOBLOG_INFO('{self.job_id}')" + \
            ") A"
        results = self.run_sql(sql)
        joblog_dict = self._dump_results_to_dict(results)
        return joblog_dict
