FROM python:3.8

ENV APP_HOME /usr/src/app
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apt-get update && \
    apt-get install -y locales && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    echo LANG=en_US.utf8 > /etc/default/locale && \
    apt-get install -yy gcc wget curl && \
    apt-get clean  && \
    rm -rf /var/lib/apt/lists/*

WORKDIR $APP_HOME

COPY requirements.txt ./

RUN pip install --upgrade pip \
    && pip install -r requirements.txt
