{{- define "base.secrets" -}}
{{- if .Values.secrets }}
{{- $root := . -}}
{{- $defaultNamespaces := .Values.defaultNamespaces }}
{{- range $encodeMode, $secretValuesList := .Values.secrets }}
{{- range $secretValuesList }}
{{- $secretValues := . }}
{{- $rangeNamespaces := coalesce .namespaces (list .namespace) (list) }}
{{- $rangeNamespaces := ternary $defaultNamespaces $rangeNamespaces (.defaultNamespaces | default false) }}
{{- range $rangeNamespaces }}
---
apiVersion: v1
kind: Secret
type: {{ $secretValues.type | default "Opaque" }}
metadata:
  name: {{ $secretValues.name | quote }}
  {{- if . }}
  namespace: {{ . | quote }}
  {{- end }}
  labels:
    {{- include "base.commonLabels" $root | trim | nindent 4 }}
data:
{{- range $key, $value := $secretValues.values }}
  {{- if eq $encodeMode "decoded" }}
  {{ $key -}}: {{ $value | toString | b64enc | quote -}}
  {{- else if eq $encodeMode "encoded" }}
  {{ $key -}}: {{ $value | quote -}}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}