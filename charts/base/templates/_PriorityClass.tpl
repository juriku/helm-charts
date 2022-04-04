{{- define "base.PriorityClass" -}}
{{- if .Values.PriorityClass }}
{{- $root := . -}}
{{- range .Values.PriorityClass }}
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: {{ .name | default (include "base.fullname" $root) }}
value: {{ .value }}
preemptionPolicy: {{ .preemptionPolicy | default "PreemptLowerPriority" }}
globalDefault: {{ .globalDefault | default "false" }}
description: {{ .description | default (include "base.fullname" $root) }}
{{- end }}
{{- end }}
{{- end }}