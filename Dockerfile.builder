FROM alpine:edge

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

ENV PYTHONUNBUFFERED=1
ENV PIPENV_VERBOSITY=-1
ENV VIRTUAL_ENV=/opt/env
ENV UV_PROJECT_ENVIRONMENT=/opt/env
ENV WORKING_DIR=/opt/invenio
ENV INVENIO_INSTANCE_PATH=${WORKING_DIR}/var/instance
ENV PYTHONUSERBASE=$VIRTUAL_ENV
ENV PATH=$VIRTUAL_ENV/bin:$PATH
ENV PYTHONPATH=$VIRTUAL_ENV/lib/python3.12:$PATH

RUN apk update
RUN apk add --update --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
    "python3>3.12" \
    "python3-dev>3.12" \
    "nodejs>20" \
    "npm>10" \
    git \
    cairo \
    autoconf \
    automake \
    bash \
    build-base \
    file \
    gcc \
    libtool \
    libxml2-dev \
    libxslt-dev \
    linux-headers \
    xmlsec-dev \
    xmlsec \
    uv \
    pnpm

RUN uv venv ${VIRTUAL_ENV}
RUN source ${VIRTUAL_ENV}/bin/activate

# necessary because of https://github.com/xmlsec/python-xmlsec/pull/325
ENV CFLAGS="-Wno-error=incompatible-pointer-types"

# not more necessary after new release of xmlsec
# https://github.com/xmlsec/python-xmlsec/issues/316
# --only-binary is not working!!!! it builds but it fails on runtime
RUN uv pip install --no-binary=xmlsec --no-binary=lxml lxml xmlsec

WORKDIR ${WORKING_DIR}/src

RUN mkdir -p ${INVENIO_INSTANCE_PATH}

ENTRYPOINT [ "bash", "-c"]
