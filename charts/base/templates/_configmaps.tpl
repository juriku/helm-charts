{{- define "base.configmaps" -}}
{{- if .Values.configmaps }}
{{- $root := . -}}
{{- $defaultNamespaces := .Values.defaultNamespaces }}
{{- range $configValuesList := .Values.configmaps }}
{{- $rangeNamespaces := coalesce $configValuesList.namespaces (list $configValuesList.namespace) (list) }}
{{- $rangeNamespaces := ternary $defaultNamespaces $rangeNamespaces ($configValuesList.defaultNamespaces | default false) }}
{{- range $rangeNamespaces }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $configValuesList.name | quote }}
  {{- if . }}
  namespace: {{ . | quote }}
  {{- end }}
  labels:
    {{- include "base.commonLabels" $root | trim | nindent 4 }}
  {{- if $configValuesList.annotations }}
  annotations:
    {{- include "base.valuesPairs" $configValuesList.annotations | trim | nindent 4 }}
  {{- end}}
data:
{{- range $key, $value := $configValuesList.values }}
{{- $valueStr := $value | toString }}
  {{ $key -}}: {{ if eq $valueStr "<nil>" }}""{{ else }}{{ $valueStr | quote }}{{ end }}
{{- end }}
{{- range $key, $value := $configValuesList.valuesMultiLine }}
  {{ $key -}}: |-
{{ tpl $value $| indent 4 -}}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
