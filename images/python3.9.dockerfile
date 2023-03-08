FROM python:3.9

ARG \
    WORK_DIR=/srv/app \
    POETRY_HOME=/opt/poetry \
    USER=sysadmin \
    USER_UID=1001 \
    USER_GID=1001

ENV \
    DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_ROOT_USER_ACTION=ignore \
    REQ_HEADER_BUFFER_SIZE=12288 \
    C_FORCE_ROOT=1 \
    PORT=80

COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

RUN \
    set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends curl; \
    curl -sSL https://install.python-poetry.org | POETRY_HOME=${POETRY_HOME} python;\
    cd /usr/local/bin && ln -s /opt/poetry/bin/poetry; \
    apt-get -y remove curl; \
    apt-get -y autoremove; \
    apt-get -y clean; \
    apt-get update; \
    rm -rf /var/lib/apt/lists/* && rm -rf /src/*.deb; \
    groupadd -rg $USER_GID $USER; \
    useradd -mru $USER_UID -g $USER_GID $USER; \
    mkdir -p -m0770 $WORK_DIR $WORK_DIR/logs $WORK_DIR/data; \
    chown -R $USER:0 $WORK_DIR $WORK_DIR/logs $WORK_DIR/data $POETRY_HOME /usr/local /tmp/requirements.txt

ENV PYTHONPATH=$WORK_DIR
WORKDIR $WORK_DIR
USER $USER

ADD --chown=$USER:0 ./start-dev.sh ./gunicorn_conf.py ./start-prod.sh $WORK_DIR/
ADD --chown=$USER:0 . $WORK_DIR/

RUN \
    chmod +x ./start-dev.sh; \
    chmod +x ./start-prod.sh; \
    poetry config virtualenvs.create false

CMD ["./start-dev.sh"]