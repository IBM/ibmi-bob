from typing import Any, Dict, List, Optional


class Connection:
    def set_option(self, option: Optional[Dict[str, Any]] = None):
        pass

    def cursor(self):
        return Cursor()

    def close(self):
        pass

class Cursor:
    def callproc(self, procedure: str, arguments: List[str]):
        pass

    def execute(self, sql: str):
        pass

    def description(self):
        return [("column_name", "type_code", None, None, None, None, None)]

    def fetchall(self):
        return [("value1", "value2")]

def connect(dsn=None, user='', password='', host='', database='', conn_options=None):
    return Connection()
    
SQL_ATTR_TXN_ISOLATION = "SQL_ATTR_TXN_ISOLATION"
SQL_TXN_NO_COMMIT= "SQL_TXN_NO_COMMIT"
