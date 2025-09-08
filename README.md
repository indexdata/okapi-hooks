# About

This project provides Okapi deployment automation when deploying Okapi modules on Kubernetes.

`okapi-hooks` is a helper container for Okapi module registration (deploy + install/uninstall + undeploy)
and a corresponding Helm chart that binds to Helm's `post-instal` and `post-upgrade`
[lifecycle hooks](https://helm.sh/docs/topics/charts_hooks/).

While the container and the chart can be used independently, the intended use is as a subchart dependency
in a parent Okapi module Helm chart, like so:

```yaml filename=Chart.yaml
name: mod-x
description: X Okapi module
type: application

dependencies:
  - name: okapi-hooks
    repository: oci://ghcr.io/indexdata/charts
    version: ">0.1.0-0" #or a specific version
    condition: okapi-hooks.enabled
```

the subchart must be configured with the following minimal values, note that the chart is disabled by default:

```yaml filename=values.yaml
enabled: true
moduleUrl: "http://mod-x:80"
moduleDescriptor: |
  {
    "id" : "mod-x-0.1.0",
    "name" : "X Okapi module"
  }
tenants:
- mytenant

```
It's recommended that the module version in the ModuleDescriptor follows the parent chart version.

see [values.yaml](./chart/values.yaml) for a complete list of configuration options.

The parent chart is then build with:

```bash
cd /path/to/parent/chart
helm dependency build
helm package .
```

The chart expects a deployed secret called `okapi-secret` with `OKAPI_USER/OKAPI_PASS` or `OKAPI_TOKEN` keys.

## Environment variables

The container can be configured with the following environment variables:

| env                  | Description                                                 |
|----------------------|-------------------------------------------------------------|
| `MODULE_URL`         | URL of running module instance                              |
| `OKAPI_MD`           | Module descriptor content                                   |
| `OKAPI_TENANTS`      | Glob list of tenants separated by comma or space            |
| `OKAPI_ADMIN_TENANT` | Glob list of admin tenants - default is `supertenant`       |
| `OKAPI_URL`          | Okapi URL                                                   |
| `OKAPI_USER`         | Username for admin tenant                                   |
| `OKAPI_PASS`         | Password for admin tenant                                   |
| `OKAPI_TOKEN`        | Token for admin tenant                                      |
