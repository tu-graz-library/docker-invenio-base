FROM python:3.14-alpine

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

ENV PYTHONUNBUFFERED=1 \
    # https://stackoverflow.com/a/60797635
    PYTHONDONTWRITEBYTECODE=1

ENV UV_FROZEN=1 \
    # https://docs.astral.sh/uv/reference/cli/#uv-run--compile-bytecode
    # UV_COMPILE_BYTECODE=1 \
    # https://docs.astral.sh/uv/reference/cli/#uv-run--link-mode
    UV_LINK_MODE=copy \
    # https://docs.astral.sh/uv/reference/cli/#uv-run--no-managed-python
    UV_NO_MANAGED_PYTHON=1 \
    # https://docs.astral.sh/uv/reference/cli/#uv-python-find--system
    UV_SYSTEM_PYTHON=1 \
    # https://docs.astral.sh/uv/reference/environment/#uv_python_downloads
    UV_PYTHON_DOWNLOADS=never \
    UV_PROJECT_ENVIRONMENT=/usr/local

ENV WORKING_DIR=/opt/invenio \
    INVENIO_INSTANCE_PATH=${WORKING_DIR}/var/instance

# ENV PATH=$UV_PROJECT_ENVIRONMENT/bin:$PATH

RUN apk update
RUN apk add --update --no-cache \
    nodejs \
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
    pnpm \
    openssl

# necessary because of https://github.com/xmlsec/python-xmlsec/pull/325
ENV CFLAGS="-Wno-error=incompatible-pointer-types"

# not more necessary after new release of xmlsec
# https://github.com/xmlsec/python-xmlsec/issues/316
# --only-binary is not working!!!! it builds but it fails on runtime
RUN uv pip install --no-binary=xmlsec --no-binary=lxml lxml xmlsec

WORKDIR ${WORKING_DIR}/src

RUN mkdir -p ${INVENIO_INSTANCE_PATH}

ENTRYPOINT [ "bash", "-c"]
