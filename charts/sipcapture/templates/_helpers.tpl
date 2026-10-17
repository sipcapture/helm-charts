{{/*
Common labels
*/}}

{{- define "common.labels" -}} 
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "homer.fullname" -}}
{{- print (include "common.names.fullname" .) "-homer" -}}
{{- end -}}

{{- define "heplify.fullname" -}}
{{- print (include "common.names.fullname" .) "-heplify" -}}
{{- end -}}

{{- define "influxdb.fullname" -}}
{{- print (include "common.names.fullname" .) "-influxdb" -}}
{{- end -}}

{{- define "telegraf.fullname" -}}
{{- print (include "common.names.fullname" .) "-telegraf" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "homer.postgresql.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "postgresql" "chartValues" .Values.postgresql "context" $) -}}
{{- end -}}

{{/*
Generate Postgres credentials or reuse existing ones
*/}}

{{- define "gen.postgres.secret" -}}
{{- $secret := lookup "v1" "Secret" .Release.Namespace "postgres-homer-credentials" -}}
postgres-password: {{ if $secret }} {{ index $secret.data "postgres-password" }} {{ else }} {{ randAlphaNum 32 | b64enc | quote }} {{ end }}
postgres-user: {{ "homer_user" | b64enc | quote }}
{{- end -}}

{{- define "gen.defaultpassword.secret" -}}
{{- $secret := lookup "v1" "Secret" .Release.Namespace "homer-ui-credentials" -}}
default-password: {{ if $secret }} {{ index $secret.data "default-password" }} {{ else }} {{ randAlphaNum 32 | b64enc | quote }} {{ end }}
{{- end -}}

{{/*
PostgreSQL hostname for provisioning (superuser) when runtime host differs (e.g. pgBouncer).
*/}}
{{- define "postgresql.provisioningHostname" -}}
{{- .Values.postgresql.provisioningHostname | default .Values.postgresql.hostname | default "sipcapture-postgresql" -}}
{{- end -}}

{{/*
Namespace used for the monitoring stack. Falls back to the release namespace.
*/}}
{{- define "homer.namespace" -}}
{{- dig "global" "monitoring" "namespace" .Release.Namespace (.Values | merge (dict)) -}}
{{- end -}}

{{/*
Grafana fullname. The grafana subchart templates cannot be included from the
parent chart, so this mirrors the naming logic used by the grafana chart.
*/}}
{{- define "homer.grafana.fullname" -}}
{{- if .Values.grafana.fullnameOverride -}}
{{- .Values.grafana.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "grafana" .Values.grafana.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Hostname used to reach InfluxDB. Defaults to the bundled subchart service, but
can be overridden with `influxdb.hostname` when using an external instance.
*/}}
{{- define "influxdb.host" -}}
{{- default (include "influxdb.fullname" .) .Values.influxdb.hostname -}}
{{- end -}}

{{/*
Homer pull secrets
*/}}
{{- define "homer.imagePullSecrets" -}}
{{- if .Values.homer.image.pullSecrets }}
imagePullSecrets:
{{- with .Values.homer.image.pullSecrets }}
  {{- . | toYaml | nindent 2 }}
{{- end }}
{{- end -}}
{{- end -}}

{{/*
HeplifyServer pull secrets
*/}}
{{- define "heplifyServer.imagePullSecrets" -}}
{{- if .Values.heplifyServer.image.pullSecrets }}
imagePullSecrets:
{{- with .Values.heplifyServer.image.pullSecrets }}
  {{- . | toYaml | nindent 2 }}
{{- end }}
{{- end -}}
{{- end -}}

{{/*
Influxdb pull secrets
*/}}
{{- define "influxdb.imagePullSecrets" -}}
{{- if .Values.influxdb.image.pullSecrets }}
imagePullSecrets:
{{- with .Values.influxdb.image.pullSecrets }}
  {{- . | toYaml | nindent 2 }}
{{- end }}
{{- end -}}
{{- end -}}

{{/*
Telegraf pull secrets
*/}}
{{- define "telegraf.imagePullSecrets" -}}
{{- if .Values.telegraf.image.pullSecrets }}
imagePullSecrets:
{{- with .Values.telegraf.image.pullSecrets }}
  {{- . | toYaml | nindent 2 }}
{{- end }}
{{- end -}}
{{- end -}}

