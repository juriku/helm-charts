# Helm Charts

Collection of charts that can be used for any type of deployemnt


## Base Chart

`./charts/base`

This chart used as a collection of tempaltes and functions

## other charts

All other charts include `base` chart as dependancy
```
dependencies:
  - name: base
    repository: file://../base
```

Needed templates are beeing loaded with:
```
{{ include "base.configmaps" . }}
{{ include "base.secrets" . }}
{{ include "base.service" . }}
{{ include "base.ingress" . }}
{{ include "base.deployment" . }}
```

## How to use helm repo

Create values.yaml file
```
image:
  repository: "juriku/curl-jq-bash-alpine-docker"

command:
  - "sh"
  - "-c"
  - "sleep 60"

ports:
  - containerPort: 8080
```

```
helm repo add baseCharts https://juriku.github.io/helm-charts
```

```
helm install my-release baseCharts/app -f my-release/values.yaml
```

## Extra options

Check default `values.yaml` file for extra parameters