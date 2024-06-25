FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
ENV PG_VERSION=12
# https://github.com/cgwire/zou/tags
ARG ZOU_VERSION=0.19.43
# https://github.com/cgwire/kitsu/tags
ARG KITSU_VERSION=0.19.44

USER root

RUN apt-get update && \
    apt-get install --no-install-recommends -q -y \
    bzip2 \
    build-essential \
    ffmpeg \
    git \
    gcc \
    nginx \
    postgresql-client \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    libjpeg-dev \
    libpq-dev \
    redis-server \
    software-properties-common \
    supervisor \
    wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip install sendria && \
    rm -rf /root/.cache/pip/


RUN sed -i "s/bind .*/bind 127.0.0.1/g" /etc/redis/redis.conf

RUN mkdir -p /opt/zou /var/log/zou /opt/zou/previews

RUN git config --global --add advice.detachedHead false
RUN wget -q -O /tmp/kitsu.tgz https://github.com/cgwire/kitsu/releases/download/v${KITSU_VERSION}/kitsu-${KITSU_VERSION}.tgz && \
	mkdir -p /opt/zou/kitsu && tar xvzf /tmp/kitsu.tgz -C /opt/zou/kitsu && rm /tmp/kitsu.tgz

# setup.py will read requirements.txt in the current directory
WORKDIR /opt/zou/zou
RUN python3 -m venv /opt/zou/env && \
    /opt/zou/env/bin/pip install --upgrade pip setuptools wheel && \
    /opt/zou/env/bin/pip install zou==${ZOU_VERSION} && \
    rm -rf /root/.cache/pip/

WORKDIR /opt/zou

COPY ./docker/gunicorn.py /etc/zou/gunicorn.py
COPY ./docker/gunicorn-events.py /etc/zou/gunicorn-events.py

COPY ./docker/nginx.conf /etc/nginx/sites-available/zou
RUN ln -s /etc/nginx/sites-available/zou /etc/nginx/sites-enabled/
RUN rm /etc/nginx/sites-enabled/default

ADD ./docker/supervisord.conf /etc/supervisord.conf

COPY ./docker/init_zou.sh /opt/zou/
COPY ./docker/start_zou.sh /opt/zou/
RUN chmod +x /opt/zou/init_zou.sh /opt/zou/start_zou.sh

# Init of zou will be done afterwards
#RUN echo Initialising Zou... && /opt/zou/init_zou.sh

EXPOSE 80
EXPOSE 1080
VOLUME ["/opt/zou/previews"]
CMD ["/opt/zou/start_zou.sh"]
