# docker-invenio-base

invenioRDM base images

This images serves as base image, usable in production environments like Kubernetes or OpenShift, for: [InvenioRDM](https://github.com/inveniosoftware/invenio-app-rdm)


The *current images* is based on the **alpine** version edge and contains:

- Python v3.12 set as default Python interpreter with upgraded versions of pip, uv.
- Node.js > v20.x
- NPM > v10
- Working directory for an Invenio instance.

## Usage

### Create a ``Dockerfile``

A simple ``Dockerfile`` using these base images could look like this:

```dockerfile
# STAGE 1
FROM ghcr.io/tu-graz-library/docker-invenio-base:main-builder AS builder

COPY pyproject.toml uv.lock ./

RUN uv sync --frozen


COPY ./app_data/ ${INVENIO_INSTANCE_PATH}/app_data/
COPY ./assets/ ${INVENIO_INSTANCE_PATH}/assets/
COPY ./static/ ${INVENIO_INSTANCE_PATH}/static/
COPY ./translations ${INVENIO_INSTANCE_PATH}/translations/
COPY ./templates ${INVENIO_INSTANCE_PATH}/templates/

RUN invenio collect --verbose && invenio webpack create

WORKDIR ${INVENIO_INSTANCE_PATH}/assets
RUN npm install --legacy-peer-deps
RUN npm run build

# STAGE 2
FROM ghcr.io/tu-graz-library/docker-invenio-base:main-frontend AS frontend

COPY --from=builder ${VIRTUAL_ENV}/lib ${VIRTUAL_ENV}/lib
COPY --from=builder ${VIRTUAL_ENV}/bin ${VIRTUAL_ENV}/bin
COPY --from=builder ${INVENIO_INSTANCE_PATH}/app_data ${INVENIO_INSTANCE_PATH}/app_data
COPY --from=builder ${INVENIO_INSTANCE_PATH}/static ${INVENIO_INSTANCE_PATH}/static
COPY --from=builder ${INVENIO_INSTANCE_PATH}/translations ${INVENIO_INSTANCE_PATH}/translations
COPY --from=builder ${INVENIO_INSTANCE_PATH}/templates ${INVENIO_INSTANCE_PATH}/templates

WORKDIR ${WORKING_DIR}/src

COPY ./docker/uwsgi/ ${INVENIO_INSTANCE_PATH}
COPY ./invenio.cfg ${INVENIO_INSTANCE_PATH}


USER invenio

ENTRYPOINT [ "bash", "-c"]
```
