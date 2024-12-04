# docker-invenio-base

invenioRDM base images

This images serves as base image, usable in production environments like Kubernetes or OpenShift, for: [InvenioRDM](https://github.com/inveniosoftware/invenio-app-rdm)


The *current images* is based on the **alpine** version edge and contains:

- Python v3.12 set as default Python interpreter with upgraded versions of pip, uv.
- Node.js > v20.x
- NPM > v10
- Working directory for an Invenio instance.
