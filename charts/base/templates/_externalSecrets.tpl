{{- define "base.externalSecrets" -}}
{{- $root := . }}
{{- range $index, $secret := .Values.externalSecrets }}
---
apiVersion: {{ $secret.apiVersion | default "external-secrets.io/v1" }}
kind: ExternalSecret
metadata:
  name: {{ $secret.name }}
  {{- if $secret.namespace }}
  namespace: {{ $secret.namespace }}
  {{- else if $root.Values.namespace }}
  namespace: {{ $root.Values.namespace }}
  {{- end }}
  labels:
    {{- include "base.commonLabels" $root | trim | nindent 4 }}
    {{- with $secret.labels }}
    {{- toYaml . | trim | nindent 4 }}
    {{- end }}
  {{- with $secret.annotations }}
  annotations:
    {{- toYaml . | trim | nindent 4 }}
  {{- end }}
spec:
  refreshInterval: {{ $secret.refreshInterval | default "1h" }}
  secretStoreRef:
    name: {{ $secret.secretStoreRef.name }}
    kind: {{ $secret.secretStoreRef.kind | default "SecretStore" }}
  {{- $target := $secret.target | default dict }}
  target:
    name: {{ $target.name | default $secret.name }}
    {{- with $target.creationPolicy }}
    creationPolicy: {{ . }}
    {{- end }}
    {{- with $target.template }}
    template:
      {{- toYaml . | nindent 6 }}
    {{- end }}
  {{- with $secret.data }}
  data:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $secret.dataFrom }}
  dataFrom:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
