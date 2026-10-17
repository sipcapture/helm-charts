# sipcapture

HOMER/SIPCAPTURE stack for Kubernetes: `heplify-server`, `homer-app`, InfluxDB,
Telegraf, Grafana and PostgreSQL.

## Installing

```bash
helm repo add sipcapture https://sipcapture.github.io/helm-charts/
helm repo update
helm install my-homer sipcapture/sipcapture --namespace homer --create-namespace
```

The default values create a working stack, but you should override the ingress
hostnames and passwords below for anything beyond a local test.

## Components

Every bundled component except `heplify-server` can be turned off so you can use
an external service instead:

| Value                        | Default | Description                                  |
| ---------------------------- | ------- | -------------------------------------------- |
| `grafana.installOnCluster`   | `true`  | deploy the bundled Grafana subchart          |
| `postgresql.installOnCluster`| `true`  | deploy the bundled PostgreSQL subchart       |
| `influxdb.installOnCluster`  | `true`  | deploy the bundled InfluxDB                  |
| `telegraf.installOnCluster`  | `true`  | deploy the bundled Telegraf                  |

## Values

| Key | Type | Default | Description |
| --- | ---- | ------- | ----------- |
| `global.create_namespace` | bool | `true` | create the target namespace |
| `homer.image.registry` | string | `ghcr.io` | homer-app image registry |
| `homer.image.repository` | string | `sipcapture/homer-app` | homer-app image repository |
| `homer.image.tag` | string | `1.5.15` | homer-app image tag |
| `homer.containerPort` | int | `8080` | homer-app container port |
| `homer.service.type` | string | `ClusterIP` | webapp Service type |
| `homer.ingress.enabled` | bool | `true` | create an Ingress for the webapp |
| `homer.ingress.hostname` | string | `webapp.myimaginaryhost.com` | webapp Ingress host |
| `homer.ingress.ingressClassName` | string | `nginx` | webapp Ingress class |
| `homer.ingress.tls` | list | `[]` | webapp Ingress TLS blocks |
| `homer.grafana.url` | string | `""` | Grafana URL used by the webapp; empty derives it from the bundled subchart |
| `homer.auth.oauth.enabled` | bool | `false` | enable OAuth2 login |
| `heplifyServer.image.tag` | string | `1.60.1` | heplify-server image tag |
| `heplifyServer.service.type` | string | `ClusterIP` | heplify-server Service type |
| `heplifyServer.service.ports.udp` | int | `9060` | HEP UDP port |
| `heplifyServer.service.ports.tcp` | int | `9096` | Prometheus metrics port |
| `heplifyServer.serviceMonitor.enabled` | bool | `false` | create a Prometheus Operator ServiceMonitor |
| `heplifyServer.config.*` | map | see `values.yaml` | heplify-server tunables |
| `influxdb.hostname` | string | `""` | external InfluxDB host; empty uses the bundled subchart |
| `influxdb.storage` | string | `10Gi` | bundled InfluxDB PVC size |
| `postgresql.hostname` | string | `sipcapture-postgresql` | PostgreSQL host used by the apps |
| `postgresql.provisioningHostname` | string | `""` | superuser host when it differs (e.g. pgbouncer) |
| `postgresql.sslmode` | string | `disable` | `disable`\|`allow`\|`prefer`\|`require`\|`verify-ca`\|`verify-full` |
| `postgresql.auth.postgresPassword` | string | `homerSeven` | bundled PostgreSQL superuser password |
| `postgresql.auth.existingSecretHomer` | string | `postgres-homer-credentials` | secret holding the HOMER DB user credentials |
| `grafana.adminPassword` | string | `admin` | Grafana admin password |
| `extraObjects` | list | `[]` | additional manifests, rendered with `tpl` |

`heplify-server.config.*`, service settings and resource blocks also accept the
usual `nodeSelector`, `tolerations`, `affinity`, `resources`, `podSecurityContext`
and `securityContext` keys.

## External services

Point the apps at an external InfluxDB or Grafana by disabling the bundled
component and setting the endpoint:

```yaml
influxdb:
  installOnCluster: false
  hostname: influxdb.monitoring.svc.cluster.local
grafana:
  installOnCluster: false
homer:
  grafana:
    url: http://grafana.monitoring.svc.cluster.local:3000
```

For an external PostgreSQL, disable `postgresql.installOnCluster`, set
`postgresql.hostname`, and provide `postgresql.auth.existingSecret` (superuser)
and `postgresql.auth.existingSecretHomer` (HOMER application user).

## Namespace

Resources live in `global.monitoring.namespace` when set, and otherwise in the
release namespace. All bundled templates share the same `homer.namespace`
helper, so the generated secrets stay with the workloads.

## Notes

- The default passwords (`homerSeven`, `admin`) and the placeholder ingress
  hostnames are for local testing only.
- The generated `homer-ui-credentials` secret holds the initial password for the
  `admin` and `support` users.