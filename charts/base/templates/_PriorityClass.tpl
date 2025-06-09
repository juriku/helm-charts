{{- define "base.PriorityClass" -}}
{{- if .Values.PriorityClass }}
{{- $root := . -}}
{{- range .Values.PriorityClass }}
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: {{ .name | default (include "base.fullname" $root) }}
  {{- if .namespace }}
  namespace: {{ .namespace }}
  {{- else if $root.Values.namespace }}
  namespace: {{ $root.Values.namespace }}
  {{- end }}
  labels:
    {{- include "base.commonLabels" $root | trim | nindent 4 }}
value: {{ .value }}
preemptionPolicy: {{ .preemptionPolicy | default "PreemptLowerPriority" }}
globalDefault: {{ .globalDefault | default "false" }}
description: {{ .description | default (include "base.fullname" $root) }}
{{- end }}
{{- end }}
{{- end }}