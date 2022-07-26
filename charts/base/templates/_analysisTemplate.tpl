{{- define "base.analysisTemplate" -}}
{{- if .Values.argo.analysis.enabled -}}
---
kind: AnalysisTemplate
apiVersion: argoproj.io/v1alpha1
metadata:
  {{- if .Values.argo.analysis.name }}
  name: {{ .Values.argo.analysis.name }}
  labels:
    {{- include "base.commonLabels" . | trim | nindent 4 }}
  {{- else }}
  name: {{ include "base.fullname" . }}
  {{- end }}
spec:
  {{- with .Values.argo.analysis.metrics }}
  metrics:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
