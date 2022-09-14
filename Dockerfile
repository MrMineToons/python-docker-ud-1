FROM python:3.9-alpine3.13
LABEL maintainer="mmt"

ENV PYTHONUNBUFFERED 1


COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
COPY ./scripts /scripts
WORKDIR /app
EXPOSE 8000

ARG DEV=false
RUN apk add --update --no-cache postgresql-client jpeg-dev && \
    apk add --update --no-cache --virtual .tmp-build-deps \
    gcc libc-dev linux-headers postgresql-dev musl-dev zlib zlib-dev \
    build-base postgresql-dev musl-dev zlib zlib-dev linux-headers && \
    python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then pip install -r /tmp/requirements.dev.txt ; \
    fi 
RUN rm -rf /tmp && \
    apk del .tmp-build-deps

RUN adduser \
        --disabled-password \
        --no-create-home \
        user && \
    mkdir -p /app && \ 
    mkdir -p /vol/web/media && \
    mkdir -p /vol/web/static && \
    chown -R user:user /app && \
    chmod -R 755 /app && \
    chown -R user:user /vol && \
    chmod -R 755 /vol && \
    chmod -R +x /scripts
ENV PATH="/scripts:/py/bin:$PATH"

CMD ["run.sh"]




