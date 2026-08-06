{{- define "base.serviceMonitor" -}}
{{- $root := . }}
{{- range $index, $monitor := .Values.serviceMonitors }}
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  {{- if $monitor.name }}
  name: {{ $monitor.name }}
  {{- else if eq $index 0 }}
  name: {{ include "base.fullname" $root }}
  {{- else }}
  name: {{ printf "%s-%s" (include "base.fullname" $root) (toString (add $index 1)) }}
  {{- end }}
  {{- if $monitor.namespace }}
  namespace: {{ $monitor.namespace }}
  {{- else if $root.Values.namespace }}
  namespace: {{ $root.Values.namespace }}
  {{- end }}
  labels:
    {{- include "base.labels" $root | trim | nindent 4 }}
    {{- with $monitor.labels }}
    {{- toYaml . | trim | nindent 4 }}
    {{- end }}
spec:
  selector:
    {{- if $monitor.selector }}
    {{- toYaml $monitor.selector | nindent 4 }}
    {{- else }}
    matchLabels:
      {{- include "base.selectorLabels" $root | trim | nindent 6 }}
    {{- end }}
  endpoints:
    {{- if $monitor.endpoints }}
    {{- toYaml $monitor.endpoints | nindent 4 }}
    {{- else }}
    - port: {{ $monitor.port | default "http" }}
      path: {{ $monitor.path | default "/metrics" }}
      interval: {{ $monitor.interval | default "30s" }}
    {{- end }}
  {{- with $monitor.namespaceSelector }}
  namespaceSelector:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
