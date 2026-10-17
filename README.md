<img src="https://user-images.githubusercontent.com/1423657/55069501-8348c400-5084-11e9-9931-fefe0f9874a7.png" width=200/>

## HOMER helm charts

Helm chart for the **HOMER/SIPCAPTURE** stack on Kubernetes. A single release
deploys:

| Component       | Role                                              |
| --------------- | ------------------------------------------------- |
| `heplify-server`| HEP collector, writes SIP/RTP to PostgreSQL       |
| `homer-app`     | HOMER web UI / API                                |
| PostgreSQL      | HOMER configuration and data storage              |
| InfluxDB        | optional metrics store for Telegraf               |
| Telegraf        | host/application metrics and heplify stats        |
| Grafana         | dashboards for the metrics above                  |

To add this Helm chart repository to your Helm client:

```bash
helm repo add sipcapture https://sipcapture.github.io/helm-charts/
helm repo update
helm install my-homer sipcapture/sipcapture
```

See [charts/sipcapture/README.md](charts/sipcapture/README.md) for the values
reference, external database configuration and how to disable bundled
components.

### Development

```bash
# chart repositories required by the dependencies
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add bitnami https://raw.githubusercontent.com/bitnami/charts/archive-full-index/bitnami

helm dependency build charts/sipcapture
helm lint charts/sipcapture --with-subcharts

# unit tests
helm plugin install https://github.com/helm-unittest/helm-unittest.git --version v1.2.1
helm unittest charts/sipcapture

# render + schema validation
helm template ci charts/sipcapture | kubeconform -strict -ignore-missing-schemas -
```

#### Credits

Charts kindly contributed by the [Jambonz](https://github.com/jambonz) project