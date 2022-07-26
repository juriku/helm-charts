{{- define "base.argoRollouts" -}}
{{- if .Values.argo.rollouts.enabled }}
{{- if eq .Values.argo.rollouts.type "workloadRef" }}
---
apiVersion: {{ .Values.argo.rollouts.apiVersion }}
kind: {{ .Values.argo.rollouts.kind }}
metadata:
  name: {{ include "base.fullname" . }}
  labels:
    {{- include "base.labels" . | trim | nindent 4 }}
spec:
  {{- if .Values.autoscaling.enabled }}
  replicas: {{ .Values.autoscaling.minReplicas }}
  {{- else }}
  replicas: {{ .Values.replicas }}
  {{- end }}
  workloadRef:
    apiVersion: {{ .Values.apiVersion | default "apps/v1" }}
    kind: {{ .Values.kind | default "Deployment" }}
    name: {{ include "base.fullname" . }}
  {{- with .Values.argo.rollouts.strategy }}
  strategy:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}