# okapi-hooks

Helper container for for deploy+install/uninstall+undeploy a module

The container can be used as a
[Helm chart hook](https://helm.sh/docs/topics/charts_hooks/).

| env                  | Description                                                 |
|----------------------|-------------------------------------------------------------|
| `MD_URL`             | URL of running module instance                              |
| `OKAPI_MD`           | Module descriptor content                                   |
| `OKAPI_TENANTS`      | Glob list of tenants separated by command or whitespace     |
| `OKAPI_ADMIN_TENANT` | Glob list of admin tenants - default is `supertenant`       |
| `OKAPI_URL`          | Okapi URL                                                   |
| `OKAPI_USER`         | Username for admin tenant                                   |
| `OKAPI_PASS`         | Password for admin tenant                                   |
| `OKAPI_TOKEN`        | Token for admin tenant                                      |
