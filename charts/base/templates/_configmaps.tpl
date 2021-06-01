{{- define "base.configmaps" -}}
{{- if .Values.configmaps }}
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
data:
{{- range $key, $value := $configValuesList.values }}
  {{- if $value }}
  {{ $key -}}: {{ $value | quote -}}
  {{- end }}
{{- end }}
{{- range $key, $value := $configValuesList.valuesMultiLine }}
  {{ $key -}}: |-
{{ tpl $value $| indent 4 -}}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}