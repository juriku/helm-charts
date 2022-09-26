{{- define "base.prometheusRules" -}}
{{- if or .Values.additionalPrometheusRules .Values.additionalPrometheusRulesMap}}
{{- $root := . -}}
---
apiVersion: v1
kind: List
items:
{{- if .Values.additionalPrometheusRulesMap }}
{{- range $prometheusRuleName, $prometheusRule := .Values.additionalPrometheusRulesMap }}
  - apiVersion: monitoring.coreos.com/v1
    kind: PrometheusRule
    metadata:
      name: {{ include "base.fullname" $root }}
      {{- if $prometheusRule.namespace }}
      namespace: {{ $prometheusRule.namespace }}
      {{- end }}
      labels:
        {{- include "base.labels" $root | trim | nindent 8 }}
    {{- if $prometheusRule.additionalLabels }}
{{ toYaml $prometheusRule.additionalLabels | indent 8 }}
    {{- end }}
    spec:
      groups:
{{ toYaml $prometheusRule.groups| indent 8 }}
{{- end }}
{{- else }}
{{- range .Values.additionalPrometheusRules }}
  - apiVersion: monitoring.coreos.com/v1
    kind: PrometheusRule
    metadata:
      name: {{ include "base.fullname" $root }}
      {{- if .namespace }}
      namespace: {{ .namespace }}
      {{- end }}
      labels:
        {{- include "base.labels" $root | trim | nindent 8 }}
{{ include "prometheus-operator.labels" $ | indent 8 }}
    {{- if .additionalLabels }}
{{ toYaml .additionalLabels | indent 8 }}
    {{- end }}
    spec:
      groups:
{{ toYaml .groups| indent 8 }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}