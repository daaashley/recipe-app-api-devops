import os
import uuid

from pony.orm import Database, PrimaryKey, Required

db = Database()
db_uri = os.environ.get(
    "DATABASE_URL",
    "postgresql://postgres:local_db_password@localhost/postgres",
)


class User(db.Entity):
    _table_ = "user"
    id = PrimaryKey(uuid.UUID, default=uuid.uuid4, auto=True)
    username = Required(str, unique=True)
    password = Required(str)


db.bind("postgres", db_uri)
# set_sql_debug(True)
db.generate_mapping(create_tables=True)
