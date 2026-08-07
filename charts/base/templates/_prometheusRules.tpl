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
      name: {{ printf "%s-%s" (include "base.fullname" $root) $prometheusRuleName }}
      {{- if $prometheusRule.namespace }}
      namespace: {{ $prometheusRule.namespace }}
      {{- else if $root.Values.namespace }}
      namespace: {{ $root.Values.namespace }}
      {{- end }}
      labels:
        {{- include "base.labels" $root | trim | nindent 8 }}
        {{- with $prometheusRule.additionalLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      groups:
        {{- toYaml $prometheusRule.groups | nindent 8 }}
{{- end }}
{{- else }}
{{- range $index, $prometheusRule := .Values.additionalPrometheusRules }}
  - apiVersion: monitoring.coreos.com/v1
    kind: PrometheusRule
    metadata:
      {{- if $prometheusRule.name }}
      name: {{ $prometheusRule.name }}
      {{- else if eq $index 0 }}
      name: {{ include "base.fullname" $root }}
      {{- else }}
      name: {{ printf "%s-%s" (include "base.fullname" $root) (toString (add $index 1)) }}
      {{- end }}
      {{- if $prometheusRule.namespace }}
      namespace: {{ $prometheusRule.namespace }}
      {{- else if $root.Values.namespace }}
      namespace: {{ $root.Values.namespace }}
      {{- end }}
      labels:
        {{- include "base.labels" $root | trim | nindent 8 }}
        {{- with $prometheusRule.additionalLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      groups:
        {{- toYaml $prometheusRule.groups | nindent 8 }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}