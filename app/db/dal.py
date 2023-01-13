from typing import Dict
from uuid import UUID

from pony.orm import commit, db_session

from app.db.db_entities import User


@db_session(immediate=True)
def get_user(id: UUID) -> Dict:

    user_obj = User[id].to_dict()
    return user_obj


@db_session(immediate=True)
def create_user(username: str, password: str) -> Dict:
    user_obj = User(username=username, password=password)
    commit()
    return user_obj
