# syntax = docker/dockerfile:experimental
FROM python:3.9.10-slim as python-base
LABEL maintainer="David Ashley"

# python
ENV PYTHONUNBUFFERED=1 \
      # prevents python creating .pyc files
      PYTHONDONTWRITEBYTECODE=1 \
      \
      # pip
      PIP_NO_CACHE_DIR=off \
      PIP_DISABLE_PIP_VERSION_CHECK=on \
      PIP_DEFAULT_TIMEOUT=100 \
      \
      # poetry
      # https://python-poetry.org/docs/configuration/#using-environment-variables
      POETRY_VERSION=1.2.0 \
      # make poetry install to this location
      POETRY_HOME="/opt/poetry" \
      # make poetry create the virtual environment in the project's root
      # it gets named `.venv`
      POETRY_VIRTUALENVS_IN_PROJECT=true \
      # do not ask any interactive question
      POETRY_NO_INTERACTION=1 \
      \
      # paths
      # this is where our requirements + virtual environment will live
      PYSETUP_PATH="/opt/pysetup" \
      VENV_PATH="/opt/pysetup/.venv"


# prepend poetry and venv to path
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

# builder base used for deps and virtual env
FROM python-base as builder-base

# LINUX
RUN apt-get update \
      && apt-get install --no-install-recommends -y \
      # deps for installing poetry
      curl \
      postgresql-client \
      jpeg-dev \
      gcc \
      libc-dev \
      linux-headers \
      postgresql-dev  \
      musl-dev \
      zlib \
      zlib-dev


# POETRY
RUN curl -sSLcurl -sSL https://install.python-poetry.org | python3 -

# copy project requirement files here to ensure they will be cached.
WORKDIR $PYSETUP_PATH
COPY poetry.lock pyproject.toml ./

RUN poetry run pip install --upgrade pip
RUN poetry install

###################################### Runtime Image ##########################################
FROM python-base as fastapi-app

COPY --from=builder-base $poetry_home $poetry_home
COPY --from=builder-base /usr/lib/x86_64-linux-gnu/ /usr/lib/x86_64-linux-gnu/

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get install -y nodejs
RUN npm install --global yarn

WORKDIR /app/client

COPY client/.npmrc client/yarn.lock client/tsconfig.json client/package.json /app/client/
RUN  yarn

COPY client /app/client/
RUN  yarn build

COPY yoyo.ini /app/
COPY migrations /app/migrations
COPY src /app/src


CMD ["uvicorn", "--host", "0.0.0.0", "--port", "5000", "src.app:app"]
