# docker-invenio-base

invenioRDM base images

This images serves as base image, usable in production environments like Kubernetes or OpenShift, for: [InvenioRDM](https://github.com/inveniosoftware/invenio-app-rdm)


The *current images* is based on the **alpine** version edge and contains:

- Python v3.12 set as default Python interpreter with upgraded versions of pip, uv.
- Node.js > v20.x
- PNPM > v10
- Working directory for an Invenio instance.

The reason why we use Alpine as the base image is to reduce the image size.
Combined with the multistage approach it is possible to have a size of around
187.35 MiB (compressed). PNPM, rspack and uv are reducing the build time to less
than 4 minutes.

The builder image builds lxml and xmlsec which increases the build time for the
image but this step is necessary because of ABI problems between lxml and
xmlsec. Those problems enforce a rebuild of builder and frontend base image on
every release of lxml or xmlsec. see
[here](https://github.com/xmlsec/python-xmlsec/issues/320)

## Usage

### Create ``Dockerfile``

A simple ``Dockerfile`` using these base images could look like this:

```dockerfile
# STAGE 1
FROM ghcr.io/tu-graz-library/docker-invenio-base:main-builder AS builder

COPY pyproject.toml uv.lock ./

RUN uv sync --frozen

# this is an experimental feature, which enables to override javascript translations
RUN invenio i18n distribute-js-translations --input-directory ${VIRTUAL_ENV}/lib/python3.12/site-packages/invenio_translations_de/ui

ENV INVENIO_WEBPACKEXT_PROJECT="invenio_assets.webpack:rspack_project"

RUN invenio collect --verbose
RUN invenio webpack create

COPY ./app_data/ ${INVENIO_INSTANCE_PATH}/app_data/
COPY ./assets/ ${INVENIO_INSTANCE_PATH}/assets/
COPY ./static/ ${INVENIO_INSTANCE_PATH}/static/
COPY ./translations ${INVENIO_INSTANCE_PATH}/translations/
COPY ./templates ${INVENIO_INSTANCE_PATH}/templates/


WORKDIR ${INVENIO_INSTANCE_PATH}/assets
RUN pnpm install --legacy-peer-deps
RUN pnpm run build

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
RUN chown invenio:invenio .

USER invenio

ENTRYPOINT [ "bash", "-c"]
```

### Create ``pyproject.toml``

A pyproject.toml file could look like:

```
[project]
name = "NAME"
requires-python = ">= 3.12"
dynamic = ["version"]

dependencies = [
  "invenio-app-rdm[opensearch2]~=13.0.0b2.dev3",
  "uwsgi>=2.0",
  "uwsgitop>=0.11",
  "uwsgi-tools>=1.1.1",

  # translation bundle
  # as the package name suggests, it is a experimental package
  # this package provde the translations for python and javascript code
  # the python code will be available by installation over an entrypoint
  # for javascript the command in the dockerfile is necessary
  "invenio-translations-de-tugraz-experiment"
]

[tool.setuptools]
py-modules = []

[tool.uv.sources]
invenio-translations-de-tugraz-experiment = { git = "https://path/to/invenio-translations-de-tugraz-experiment", branch = "main" }
```
